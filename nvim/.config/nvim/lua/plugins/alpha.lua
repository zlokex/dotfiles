return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'ahmedkhalf/project.nvim',
    'folke/persistence.nvim',
  },

  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    dashboard.section.header.val = {
      [[                                                    ]],
      [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
      [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
      [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
      [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
      [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
      [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
      [[                                                    ]],
    }

    local devicons = require 'nvim-web-devicons'

    local function action_button(sc, icon, text, keybind, hl_group)
      local btn = dashboard.button(sc, icon .. '  ' .. text, keybind)
      btn.opts.hl = { { hl_group, 0, #icon } }
      return btn
    end

    dashboard.section.buttons.val = {
      action_button('.', '󰉓', 'Open directory', '<cmd>edit .<CR>', 'Directory'),
      action_button('e', '󰈙', 'New file', '<cmd>ene <BAR> startinsert <CR>', 'String'),
      action_button('f', '', 'Find file', '<cmd>Telescope find_files<CR>', 'Function'),
      action_button('g', '󰈬', 'Find text', '<cmd>Telescope live_grep<CR>', 'Keyword'),
      action_button('r', '󰊄', 'Recent files', '<cmd>Telescope oldfiles<CR>', 'Number'),
      action_button('P', '󰥨', 'Find projects', '<cmd>lua _G.AlphaFindProjects()<CR>', 'Label'),
      action_button('p', '󰉋', 'Recent projects', '<cmd>Telescope projects<CR>', 'Constant'),
      action_button('s', '󰑓', 'Restore last session', [[<cmd>lua require("persistence").load({ last = true })<CR>]], 'Type'),
      action_button('S', '󰍉', 'Browse sessions', [[<cmd>lua require("persistence").select()<CR>]], 'Type'),
      action_button('q', '󰐥', 'Quit', '<cmd>qa<CR>', 'Error'),
    }

    local function shorten_path(path)
      local home = vim.fn.expand '~'
      if vim.startswith(path, home) then
        path = '~' .. path:sub(#home + 1)
      end
      return path
    end

    local function truncate_path(path, max_width)
      if vim.fn.strdisplaywidth(path) <= max_width then
        return path
      end
      while vim.fn.strdisplaywidth(path) > max_width - 1 do
        path = path:sub(2)
      end
      return '…' .. path
    end

    local function find_projects()
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'
      local conf = require('telescope.config').values

      pickers
        .new({}, {
          prompt_title = 'Find projects',
          finder = finders.new_oneshot_job({
            'fd',
            '--hidden',
            '--no-ignore',
            '--type', 'd',
            '--prune',
            '--max-depth', '9',
            '--exclude', 'node_modules',
            '--exclude', '.cache',
            '--exclude', '.local/share',
            '--exclude', '.cargo',
            '--exclude', '.rustup',
            '--exclude', '.npm',
            '--exclude', '.nvm',
            '--exclude', 'go/pkg',
            '--exclude', '.venv',
            '--exclude', '.mozilla',
            [[^\.git$]],
            vim.fn.expand '~',
          }, {
            entry_maker = function(line)
              local path = line:gsub('/%.git/?$', '')
              return {
                value = path,
                display = shorten_path(path),
                ordinal = path,
              }
            end,
          }),
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if selection then
                vim.cmd('cd ' .. vim.fn.fnameescape(selection.value))
                require('telescope.builtin').find_files()
              end
            end)
            return true
          end,
        })
        :find()
    end

    _G.AlphaFindProjects = find_projects

    local function mru_button(file, sc)
      local short = shorten_path(file)
      short = truncate_path(short, 42)
      local filename = vim.fn.fnamemodify(file, ':t')
      local ext = vim.fn.fnamemodify(file, ':e')
      local icon, icon_hl = devicons.get_icon(filename, ext, { default = true })
      local display = icon .. '  ' .. short
      local cmd = '<cmd>edit ' .. vim.fn.fnameescape(file) .. '<CR>'
      local btn = dashboard.button(sc, display, cmd)
      local path_start = #icon + 2
      local _, last_sep = short:find '.*/'
      local hl = { { icon_hl, 0, #icon } }
      if last_sep then
        table.insert(hl, { 'Comment', path_start, path_start + last_sep })
        table.insert(hl, { 'Normal', path_start + last_sep, path_start + #short })
      else
        table.insert(hl, { 'Normal', path_start, path_start + #short })
      end
      btn.opts.hl = hl
      return btn
    end

    local section_mru = {
      type = 'group',
      val = {
        { type = 'padding', val = 1 },
        { type = 'text', val = 'Recent Files', opts = { hl = 'SpecialComment', position = 'center' } },
        { type = 'padding', val = 1 },
        {
          type = 'group',
          val = function()
            local oldfiles = vim.v.oldfiles
            local btns = {}
            local count = 0
            for _, file in ipairs(oldfiles) do
              if count >= 5 then
                break
              end
              local expanded = vim.fn.expand(file)
              if vim.fn.filereadable(expanded) == 1 and not expanded:match 'COMMIT_EDITMSG' then
                count = count + 1
                btns[#btns + 1] = mru_button(expanded, tostring(count))
              end
            end
            if #btns == 0 then
              btns[#btns + 1] = { type = 'text', val = '  No recent files', opts = { hl = 'Comment', position = 'center' } }
            end
            return btns
          end,
        },
      },
    }

    local function project_button(path, sc)
      local short = truncate_path(shorten_path(path), 42)
      local icon, icon_hl = devicons.get_icon('', '', { default = true })
      local display = icon .. '  ' .. short
      local cmd = '<cmd>cd ' .. vim.fn.fnameescape(path) .. ' | Telescope find_files<CR>'
      local btn = dashboard.button(sc, display, cmd)
      btn.opts.hl = { { icon_hl, 0, #icon } }
      return btn
    end

    local section_projects = {
      type = 'group',
      val = {
        { type = 'padding', val = 1 },
        { type = 'text', val = 'Recent Projects', opts = { hl = 'SpecialComment', position = 'center' } },
        { type = 'padding', val = 1 },
        {
          type = 'group',
          val = function()
            local projects = require('project_nvim').get_recent_projects()
            local btns = {}
            local count = math.min(5, #projects)
            local shortcuts = { 'a', 'b', 'c', 'd', 'i' }
            for i = 1, count do
              local path = projects[#projects - i + 1]
              btns[#btns + 1] = project_button(path, shortcuts[i])
            end
            if #btns == 0 then
              btns[#btns + 1] = { type = 'text', val = '  No recent projects', opts = { hl = 'Comment', position = 'center' } }
            end
            return btns
          end,
        },
      },
    }

    dashboard.config.layout = {
      { type = 'padding', val = 2 },
      dashboard.section.header,
      { type = 'padding', val = 2 },
      dashboard.section.buttons,
      section_mru,
      section_projects,
      { type = 'padding', val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)

    -- Deferred redraw to pick up async project history
    vim.api.nvim_create_autocmd('User', {
      pattern = 'AlphaReady',
      once = true,
      callback = function()
        vim.defer_fn(function()
          if vim.bo.filetype == 'alpha' then
            require('alpha').redraw()
          end
        end, 50)
      end,
    })
  end,
}

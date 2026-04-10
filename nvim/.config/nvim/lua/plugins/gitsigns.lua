-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    signs_staged = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    attach_to_untracked = true,
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      delay = 1000,
    },
    sign_priority = 6,
    update_debounce = 100,
    max_file_length = 40000,
    preview_config = {
      border = 'single',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1,
    },
    on_attach = function(bufnr)
      local gs = require 'gitsigns'

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gs.nav_hunk 'next'
        end
      end, 'Next hunk')

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gs.nav_hunk 'prev'
        end
      end, 'Previous hunk')

      -- Actions
      map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
      map('v', '<leader>hs', function()
        gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Stage hunk')
      map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
      map('v', '<leader>hr', function()
        gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Reset hunk')
      map('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')
      map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
      map('n', '<leader>hb', function()
        gs.blame_line { full = true }
        vim.defer_fn(function()
          local blame_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_config(win).relative ~= '' then
              blame_win = win
              break
            end
          end
          if blame_win then
            local current_buf = vim.api.nvim_get_current_buf()
            local blame_buf = vim.api.nvim_win_get_buf(blame_win)

            local function close_blame()
              if vim.api.nvim_win_is_valid(blame_win) then
                vim.api.nvim_win_close(blame_win, true)
              end
              pcall(vim.keymap.del, 'n', '<Esc>', { buffer = current_buf })
            end

            -- Esc from the original buffer (where focus remains)
            vim.keymap.set('n', '<Esc>', close_blame, { buffer = current_buf, nowait = true })
            -- Esc from inside the popup itself
            vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = blame_buf, nowait = true })
          end
        end, 100)
      end, 'Blame line')
      map('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
      map('n', '<leader>hU', gs.reset_buffer_index, 'Reset buffer index')

      -- Text object
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
    end,
  },
}

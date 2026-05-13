return {
  'seblyng/roslyn.nvim',
  ft = { 'cs' },
  dependencies = {
    'mfussenegger/nvim-dap',
    'stevearc/overseer.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    local mason_path = vim.fn.stdpath 'data' .. '/mason'

    local capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      require('cmp_nvim_lsp').default_capabilities()
    )

    require('roslyn').setup {
      config = { capabilities = capabilities },
    }

    local dap = require 'dap'
    dap.adapters.coreclr = {
      type = 'executable',
      command = mason_path .. '/bin/netcoredbg',
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'launch - netcoredbg',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
      },
    }

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('csharp-keymaps', { clear = true }),
      pattern = 'cs',
      callback = function(ev)
        -- vim.fs.root with string markers does exact-name matches, not globs, so
        -- '*.csproj' would only match a file literally named '*.csproj'. Use a
        -- function matcher to find files by extension instead.
        local function root_with(pat)
          return vim.fs.root(0, function(name) return name:match(pat) ~= nil end)
        end
        -- Solution-level dir: where `dotnet build`/`test` run (they walk all projects).
        local solution_root = root_with '%.sln$' or vim.fs.root(0, { '.git' }) or vim.uv.cwd()
        -- Per-file project dir: where `dotnet run` must run (it needs exactly one project).
        local project_dir = root_with '%.csproj$' or solution_root
        local overseer = require 'overseer'
        local map = function(k, f, d)
          vim.keymap.set('n', k, f, { buffer = ev.buf, desc = 'C#: ' .. d })
        end

        map('<leader>rb', function()
          overseer
            .new_task({
              cmd = { 'dotnet', 'build' },
              cwd = solution_root,
              name = 'dotnet build',
            })
            :start()
          overseer.open()
        end, 'dotnet [b]uild')

        map('<leader>rt', function()
          overseer
            .new_task({
              cmd = { 'dotnet', 'test' },
              cwd = solution_root,
              name = 'dotnet test',
            })
            :start()
          overseer.open()
        end, 'dotnet [t]est')

        map('<leader>rd', function()
          overseer
            .new_task({
              cmd = { 'dotnet', 'run' },
              cwd = project_dir,
              name = 'dotnet run (' .. vim.fs.basename(project_dir) .. ')',
            })
            :start()
          overseer.open()
        end, '[d]otnet run')

        map('<leader>rT', '<cmd>OverseerToggle<cr>', '[T]oggle Overseer task list')
      end,
    })
  end,
}

return {
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  dependencies = {
    'mfussenegger/nvim-dap',
    'stevearc/overseer.nvim',
  },
  config = function()
    local mason_path = vim.fn.stdpath 'data' .. '/mason'

    -- Bundles passed to jdtls via initializationOptions.
    -- java-debug provides the DAP bundle; java-test provides JUnit/TestNG support.
    local bundles = vim.split(
      vim.fn.glob(mason_path .. '/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
      '\n',
      { trimempty = true }
    )
    vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. '/packages/java-test/extension/server/*.jar', true), '\n', { trimempty = true }))

    local jdtls_bin = mason_path .. '/bin/jdtls'

    local function start_jdtls()
      if vim.fn.executable(jdtls_bin) ~= 1 then
        vim.notify('jdtls is not installed yet — run :MasonInstall jdtls. Re-run :JdtlsStart on this buffer once it finishes.', vim.log.levels.WARN)
        return
      end

      local root = vim.fs.root(0, { 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', '.git' })
      if not root then
        return
      end

      local workspace = vim.fn.stdpath 'cache' .. '/jdtls/workspace/' .. vim.fs.basename(root)

      local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

      require('jdtls').start_or_attach {
        cmd = { jdtls_bin, '-data', workspace },
        root_dir = root,
        capabilities = capabilities,
        init_options = { bundles = bundles },
        on_attach = function(_, bufnr)
          local jdtls = require 'jdtls'
          jdtls.setup_dap { hotcodereplace = 'auto' }
          require('jdtls.dap').setup_dap_main_class_configs()

          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'Java: ' .. desc })
          end

          local overseer = require 'overseer'

          map('<leader>rm', function()
            vim.ui.input({ prompt = 'Maven goal: ', default = 'install' }, function(goal)
              if not goal or goal == '' then
                return
              end
              overseer
                .new_task({
                  cmd = vim.list_extend({ 'mvn' }, vim.split(goal, ' ')),
                  cwd = root,
                  name = 'mvn ' .. goal,
                })
                :start()
              overseer.open()
            end)
          end, 'Run [M]aven goal')
          map('<leader>rT', '<cmd>OverseerToggle<cr>', 'Toggle Overseer task list')
          map('<leader>rt', function()
            overseer
              .new_task({
                cmd = { 'mvn', 'test' },
                cwd = root,
                name = 'mvn test',
              })
              :start()
            overseer.open()
          end, 'Run mvn [t]est')
          map('<leader>rj', function()
            local file = vim.fn.expand '%:p'
            overseer
              .new_task({
                cmd = { 'java', file },
                cwd = root,
                name = 'java ' .. vim.fn.expand '%:t',
              })
              :start()
            overseer.open()
          end, 'Run current [j]ava file')

          map('<leader>tt', function()
            require('jdtls.tests').goto_subjects()
          end, '[T]oggle to/from [T]est (or generate)')

          map('<leader>oi', jdtls.organize_imports, '[O]rganize [I]mports')
          map('<leader>ev', jdtls.extract_variable, '[E]xtract [V]ariable')
          map('<leader>ec', jdtls.extract_constant, '[E]xtract [C]onstant')
          map('<leader>em', function()
            jdtls.extract_method(true)
          end, '[E]xtract [M]ethod', 'x')
        end,
      }
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('jdtls-attach', { clear = true }),
      pattern = 'java',
      callback = start_jdtls,
    })

    vim.api.nvim_create_user_command('JdtlsStart', start_jdtls, { desc = 'Start/attach jdtls for current buffer' })
  end,
}

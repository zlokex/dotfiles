return {
  'mfussenegger/nvim-dap',
  dependencies = {
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'nvim-neotest/nvim-nio' },
    },
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP: toggle [B]reakpoint' },
    { '<leader>dc', function() require('dap').continue() end, desc = 'DAP: [C]ontinue / start' },
    { '<leader>do', function() require('dap').step_over() end, desc = 'DAP: step [O]ver' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'DAP: step [I]nto' },
    { '<leader>dO', function() require('dap').step_out() end, desc = 'DAP: step [O]ut' },
    { '<leader>dt', function() require('dap').terminate() end, desc = 'DAP: [T]erminate' },
    { '<leader>du', function() require('dapui').toggle() end, desc = 'DAP: toggle [U]I' },
  },
  config = function()
    local dap, dapui = require 'dap', require 'dapui'
    dapui.setup()
    require('nvim-dap-virtual-text').setup {}

    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end
  end,
}

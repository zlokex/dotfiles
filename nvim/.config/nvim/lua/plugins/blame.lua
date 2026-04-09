return {
  {
    'FabijanZulj/blame.nvim',
    lazy = true,
    keys = {
      { '<leader>gb', '<cmd>BlameToggle<CR>', desc = 'Toggle git blame' },
    },
    config = function()
      require('blame').setup {}
    end,
    opts = {
      blame_options = { '-w' },
    },
  },
}

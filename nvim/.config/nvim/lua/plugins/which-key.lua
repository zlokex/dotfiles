return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter',
  ---@module 'which-key'
  ---@type wk.Opts
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },

    -- Document existing key chains
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>H', group = 'Split window [H]orizontally' },
      { '<leader>V', group = 'Split window [V]ertically' },
      { '<leader>a', group = '[A]I - Claude code', icon = { icon = '󱚦', color = 'orange' } },
      { '<leader>g', group = '[G]it', icon = { icon = '', color = 'orange' } },
      { '<leader>gc', group = 'Git [C]ommit' },
      { '<leader>h', group = 'Git [H]unk' },
    },
  },
}

return {
  -- Powerful Git integration for Vim
  'tpope/vim-fugitive',
  keys = {
    { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git [B]lame' },
    { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git [P]ush' },
    { '<leader>gcc', '<cmd>Git commit<cr>', desc = 'Git Commit [C]reate' },
    { '<leader>gca', '<cmd>Git commit --amend<cr>', desc = 'Git Commit [A]mend' },
    { '<leader>ga', '<cmd>Git add<cr>', desc = 'Git [A]dd (Stage current file)' },
  },
}

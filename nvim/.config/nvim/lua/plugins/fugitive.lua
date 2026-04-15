return {
  -- Powerful Git integration for Vim
  'tpope/vim-fugitive',
  keys = {
    { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git [B]lame' },
    { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git [P]ush' },
    { '<leader>gcc', '<cmd>Git commit<cr>', desc = 'Git Commit [C]reate' },
    { '<leader>gca', '<cmd>Git commit --amend<cr>', desc = 'Git Commit [A]mend' },
    { '<leader>ga', '<cmd>Git add<cr>', desc = 'Git [A]dd (Stage current file)' },
    {
      '<leader>gq',
      function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          vim.api.nvim_win_call(win, function() vim.cmd 'diffoff' end)
        end
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_buf_get_name(buf):match '^fugitive://' then
            vim.api.nvim_win_close(win, false)
          end
        end
      end,
      desc = 'Close Fugitive Diffview',
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'fugitiveblame',
      callback = function(ev)
        vim.keymap.set('n', 'gd', function()
          local sha = vim.api.nvim_get_current_line():match '^%^?(%x+)'
          if not sha or sha:match '^0+$' then
            vim.notify('No commit on this line', vim.log.levels.WARN)
            return
          end
          vim.cmd 'wincmd p'
          vim.cmd('Gvdiffsplit ' .. sha)
        end, { buffer = ev.buf, desc = 'Fugitive blame: vdiff commit vs current file' })
      end,
    })
  end,
}

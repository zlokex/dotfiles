return {
  'DrKJeff16/project.nvim',
  config = function()
    require('project').setup {
      manual_mode = false,
      patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json' },
      exclude_dirs = {},
      show_hidden = false,
      silent_chdir = true,
      scope_chdir = 'global',
    }
  end,
}

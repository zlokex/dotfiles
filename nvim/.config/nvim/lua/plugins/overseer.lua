return {
  'stevearc/overseer.nvim',
  cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerRunCmd', 'OverseerOpen', 'OverseerClose', 'OverseerInfo' },
  config = function()
    require('overseer').setup()
  end,
}

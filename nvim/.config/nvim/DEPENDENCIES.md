# Dependencies

## luarocks (optional)

Required by [image.nvim](https://github.com/3rd/image.nvim), which provides image preview support in neo-tree.

### Install

```bash
# Fedora
sudo dnf install luarocks

# Ubuntu/Debian
sudo apt install luarocks
```

### Alternatives

If you don't need image preview in neo-tree, you can skip installing luarocks by either:

- Removing the `'3rd/image.nvim'` line from `lua/plugins/neotree.lua`
- Disabling rocks support in `init.lua`:
  ```lua
  require('lazy').setup({
    -- plugins...
  }, {
    rocks = { enabled = false },
  })
  ```

## GitHub Copilot

Requires an active [GitHub Copilot](https://github.com/settings/copilot) subscription.

### Authorize

1. Open Neovim and run `:Copilot auth`
2. Copy the one-time code shown and open the GitHub device URL in your browser
3. Paste the code and authorize the plugin
4. Verify with `:Copilot status` — should show `Ready`

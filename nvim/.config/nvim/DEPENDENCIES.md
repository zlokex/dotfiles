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

## Java

Required for the LSP (`jdtls`), DAP debugger, JUnit support, and the `<leader>rm` Maven runner in `lua/plugins/java.lua`.

### System prerequisites

- JDK 17+ on PATH (`java --version`)
- Maven on PATH if you use `<leader>rm` / `<leader>rt` (`mvn --version`)

### Install

On first nvim startup, `mason-tool-installer` auto-fetches `jdtls`, `java-debug-adapter`, and `java-test`. Track progress with `:Mason`.

### Verify

Open a `.java` file inside a Maven/Gradle project. `:LspInfo` should show `jdtls`. If the buffer was opened before Mason finished installing, run `:JdtlsStart` to attach.

## C# (.NET)

Required for the Roslyn LSP, `netcoredbg` debugger, `csharpier` formatter, and the `<leader>rb` / `<leader>rt` / `<leader>rd` dotnet runners in `lua/plugins/csharp.lua`.

### System prerequisites

- **Neovim ≥ 0.12** — required by `roslyn.nvim`. Verify with `nvim --version`.
- .NET SDK on PATH (`dotnet --version`)

### Install

On first nvim startup, `mason-tool-installer` auto-fetches `roslyn`, `netcoredbg`, and `csharpier`. The `roslyn` package comes from the `Crashdummyy/mason-registry` custom registry, which is already wired in `lua/plugins/lsp.lua`. Track progress with `:Mason`.

### Verify

Open a `.cs` file inside a project with a `.sln` or `.csproj`. `:LspInfo` should show `roslyn` attaching (after a brief indexing delay on first open).

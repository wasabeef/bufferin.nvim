# bufferin.nvim

A simple and intuitive buffer manager for Neovim with file type icons support.

![Bufferin Demo](https://user-images.githubusercontent.com/wasabeef/bufferin-demo.gif)

## ✨ Features

- 📋 **List all buffers** - View all open buffers in a clean floating window
- 🎨 **File type icons** - Display icons based on file extensions (supports nvim-web-devicons and mini.icons)
- 🚀 **Quick navigation** - Jump to any buffer with Enter
- 🗑️ **Easy deletion** - Remove buffers with `dd` (with unsaved changes protection)
- 🔄 **Reorder buffers** - Move buffers up/down with `K`/`J` (changes actual Vim buffer order)
- 🔍 **Search functionality** - Filter buffers by name or path with `/`
- 👁️ **Preview support** - Preview buffer contents before switching
- 🎨 **Customizable** - Configure window appearance, keybindings, and display options

## 📋 Requirements

- Neovim >= 0.7.0
- Optional: [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) or [mini.icons](https://github.com/echasnovski/mini.icons) for file icons

## 📦 Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'wasabeef/bufferin.nvim',
  config = function()
    require('bufferin').setup()
  end,
  -- Optional: for file icons
  requires = { 'nvim-tree/nvim-web-devicons' }
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'wasabeef/bufferin.nvim',
  cmd = { "Bufferin", "BufferinToggle" },
  config = function()
    require('bufferin').setup()
  end,
  -- Optional: for file icons
  dependencies = { 'nvim-tree/nvim-web-devicons' }
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'wasabeef/bufferin.nvim'
" Optional: for file icons
Plug 'nvim-tree/nvim-web-devicons'
```

## 🚀 Usage

### Commands

- `:Bufferin` - Open bufferin
- `:BufferinToggle` - Toggle bufferin

### Recommended Keybinding

```lua
vim.keymap.set('n', '<leader>b', '<cmd>Bufferin<cr>', { desc = 'Bufferin' })
```

### Default Keybindings (inside bufferin)

| Key | Action |
|-----|--------|
| `<CR>` or `Enter` | Select buffer |
| `dd` | Delete buffer |
| `K` | Move buffer up |
| `J` | Move buffer down |
| `q` | Close bufferin |
| `/` | Search buffers |
| `<Esc>` | Clear search |
| `p` | Preview buffer |

## ⚙️ Configuration

```lua
require('bufferin').setup({
  -- Window configuration
  window = {
    width = 0.8,        -- 80% of screen width
    height = 0.8,       -- 80% of screen height
    border = 'rounded', -- 'single', 'double', 'rounded', 'solid', 'shadow'
    position = 'center',
  },

  -- Key mappings (inside bufferin window)
  mappings = {
    select = '<CR>',
    delete = 'dd',
    move_up = 'K',
    move_down = 'J',
    quit = 'q',
    search = '/',
    clear_search = '<Esc>',
    preview = 'p',
  },

  -- Display options
  display = {
    show_numbers = true,   -- Show buffer numbers
    show_modified = true,  -- Show modified indicator
    show_path = true,      -- Show file paths
    show_hidden = false,   -- Show hidden buffers
    show_icons = true,     -- Show file type icons
  },

  -- Icons configuration
  icons = {
    modified = '●',
    readonly = '',
    terminal = '',
    -- Icon provider: 'auto', 'devicons', 'mini', or 'builtin'
    provider = 'auto',  -- Auto-detect available icon provider
    -- Builtin icons (used when no icon plugin is available)
    builtin = {
      default = '',
      lua = '',
      vim = '',
      js = '',
      ts = '',
      py = '',
      rb = '',
      go = '',
      rs = '',
      -- ... see config.lua for full list
    },
  },
})
```

## 🎨 Icon Support

bufferin.nvim supports three icon providers:

1. **nvim-web-devicons** - Recommended for the best icon coverage
2. **mini.icons** - Lightweight alternative
3. **builtin** - Basic icons included with the plugin

The plugin automatically detects which icon provider is available. You can manually specify the provider:

```lua
require('bufferin').setup({
  icons = {
    provider = 'devicons',  -- 'auto', 'devicons', 'mini', or 'builtin'
  },
})
```

## 📝 Buffer Ordering

The plugin maintains a custom buffer order during your editing session. When you use `K`/`J` to move buffers, the new order is preserved. You can also use `:BufferinNext` and `:BufferinPrev` commands to navigate through buffers in your custom order.

To make `:bnext`/`:bprev` use the custom order:

```lua
require('bufferin').setup({
  override_navigation = true,  -- This will remap :bnext/:bprev
})
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development

```bash
# Run tests
make test

# Run linter
make lint

# Format code
make format-fix

# Run all checks
make check
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by various buffer management solutions in the Neovim ecosystem
- Icon support thanks to nvim-web-devicons and mini.icons
- Built with love for the Neovim community

## 📞 Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/wasabeef/bufferin.nvim/issues).
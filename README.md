# bufferin.nvim

<div align="center">
  <p>
    <a href="https://github.com/wasabeef/bufferin.nvim/releases/latest">
      <img alt="Latest release" src="https://img.shields.io/github/v/release/wasabeef/bufferin.nvim" />
    </a>
  </p>
</div>

A powerful and intuitive buffer manager for Neovim with advanced window layout visualization and seamless plugin integration.

https://github.com/user-attachments/assets/70d426ae-2e05-45bb-8116-63038557ce39

## ✨ Features

- 📋 **Smart Buffer Management** - View and manage all open buffers in an elegant floating window
- 🗺️ **Visual Window Layout** - See your current window arrangement with Unicode-based layout maps
- 🎨 **Universal Icon Support** - Automatic detection of nvim-web-devicons, mini.icons, or built-in fallback
- 🔗 **Seamless Plugin Integration** - Works with nvim-cokeline, bufferline.nvim, or standalone
- 🚀 **Intelligent Navigation** - Jump to any buffer instantly with Enter
- 🗑️ **Smart Buffer Deletion** - Remove buffers with `dd` including unsaved changes protection
- 🔄 **Real Buffer Reordering** - Move buffers with `K`/`J` using actual buffer manipulation (not just visual)
- 💾 **Session Persistence** - Automatically save and restore buffer order between sessions
- ⚙️ **Zero Configuration** - Works perfectly out of the box with automatic plugin detection

## 🗺️ Layout Visualization

When you have multiple windows open, bufferin.nvim displays a visual representation of your current window layout:

```
Window Layout:
┌──────────────┬──────────────┐
│ config.lua   │ buffer.lua   │
│──────────────┼──────────────│
│ ui.lua       │ utils.lua    │
└──────────────┴──────────────┘
```

This helps you understand your workspace at a glance, especially useful in complex editing sessions with many splits.

## 📋 Requirements

- Neovim >= 0.7.0
- Optional: [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) or [mini.icons](https://github.com/echasnovski/mini.icons) for enhanced file icons
- Optional: [nvim-cokeline](https://github.com/willothy/nvim-cokeline) or [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) for enhanced integration

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

```lua
{
  'wasabeef/bufferin.nvim',
  cmd = { "Bufferin", "BufferinToggle" },
  config = function()
    require('bufferin').setup()
  end,
  -- Optional dependencies for enhanced experience
  dependencies = { 
    'nvim-tree/nvim-web-devicons', -- For file icons
    -- 'willothy/nvim-cokeline',     -- For buffer line integration
    -- 'akinsho/bufferline.nvim',    -- Alternative buffer line
  }
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'wasabeef/bufferin.nvim',
  config = function()
    require('bufferin').setup()
  end,
  requires = { 'nvim-tree/nvim-web-devicons' } -- Optional
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'your-username/bufferin.nvim'
Plug 'nvim-tree/nvim-web-devicons' " Optional
```

## 🚀 Usage

### Commands

- `:Bufferin` - Open bufferin buffer manager
- `:BufferinToggle` - Toggle bufferin window
- `:BufferinNext` - Navigate to next buffer in custom order
- `:BufferinPrev` - Navigate to previous buffer in custom order

### Recommended Keybinding

```lua
vim.keymap.set('n', '<leader>b', '<cmd>Bufferin<cr>', { desc = 'Open Bufferin' })
vim.keymap.set('n', '<leader>bn', '<cmd>BufferinNext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>BufferinPrev<cr>', { desc = 'Previous Buffer' })
```

### Default Keybindings (inside bufferin)

| Key | Action |
|-----|--------|
| `<CR>` or `Enter` | Select and jump to buffer |
| `dd` | Delete buffer (with confirmation for unsaved changes) |
| `K` | Move buffer up in the list |
| `J` | Move buffer down in the list |
| `q` | Close bufferin window |

## ⚙️ Configuration

### Basic Setup (Recommended)

```lua
-- Zero configuration - works perfectly out of the box
require('bufferin').setup()
```

### Advanced Configuration

```lua
require('bufferin').setup({
  -- Window appearance
  window = {
    width = 0.8,        -- 80% of screen width
    height = 0.8,       -- 80% of screen height
    border = 'rounded', -- 'single', 'double', 'rounded', 'solid', 'shadow', 'none'
    position = 'center',
  },

  -- Key mappings (inside bufferin window)
  mappings = {
    select = '<CR>',    -- Select buffer
    delete = 'dd',      -- Delete buffer
    move_up = 'K',      -- Move buffer up
    move_down = 'J',    -- Move buffer down
    quit = 'q',         -- Close window
  },

  -- Display options
  display = {
    show_numbers = true,   -- Show buffer numbers
    show_modified = true,  -- Show modified indicator (●)
    show_path = true,      -- Show file paths
    show_hidden = false,   -- Show hidden/unlisted buffers
    show_icons = true,     -- Show file type icons
  },

  -- Icon configuration
  icons = {
    modified = '●',        -- Modified buffer indicator
    readonly = '',        -- Read-only buffer indicator
    terminal = '',        -- Terminal buffer indicator
    provider = 'auto',     -- 'auto', 'devicons', 'mini', or 'builtin'
    
    -- Built-in icon fallbacks (when no icon plugin available)
    builtin = {
      default = '',
      lua = '',
      vim = '',
      js = '',
      ts = '',
      py = '',
      -- ... (see lua/bufferin/config.lua for complete list)
    },
  },

  -- Experimental/optional features
  show_window_layout = false,   -- Show window layout visualization (experimental)
  override_navigation = false,  -- Override :bnext/:bprev commands
})
```

## 🔗 Plugin Integration

bufferin.nvim automatically detects and integrates with popular buffer line plugins:

### 🎯 nvim-cokeline Integration

When [nvim-cokeline](https://github.com/willothy/nvim-cokeline) is detected:
- Buffer movements in bufferin instantly reflect in your cokeline
- Maintains perfect synchronization between both interfaces
- No additional configuration required

### 📊 bufferline.nvim Integration  

When [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) is detected:
- Seamlessly integrates with bufferline's component system
- Buffer reordering works across both interfaces
- Automatic detection and optimization

### ⚡ Standalone Mode

Works perfectly without any dependencies:
- Full buffer management functionality
- Custom ordering and navigation
- Session persistence
- Layout visualization

## 🗺️ Window Layout Mapping

bufferin.nvim can optionally visualize your current window layout (experimental feature):

### Enabling Layout Visualization

```lua
require('bufferin').setup({
  show_window_layout = true, -- Enable window layout visualization
})
```

### Features
- **Real-time Layout Detection** - Automatically maps your current window arrangement
- **Unicode Visualization** - Uses box-drawing characters for clean ASCII art
- **Smart File Grouping** - Groups multiple instances of the same file
- **Adaptive Display** - Only shows layout when multiple windows are present
- **Responsive Design** - Automatically adjusts to different window configurations

### Examples

**Two-window horizontal split:**
```
┌──────────────┬──────────────┐
│ init.lua     │ config.lua   │
└──────────────┴──────────────┘
```

**Complex multi-window layout:**
```
┌──────────────┬──────────────┬──────────────┐
│ buffer.lua   │ ui.lua       │ utils.lua    │
│──────────────┼──────────────┼──────────────│
│ test.lua     │ README.md    │ config.lua   │
└──────────────┴──────────────┴──────────────┘
```

## 🔄 Advanced Buffer Management

### Real Buffer Reordering

Unlike plugins that only provide visual reordering, bufferin.nvim performs actual buffer manipulation:

- **Swap-based Algorithm** - Inspired by bufferline.nvim's approach
- **Universal Compatibility** - Works with or without external buffer plugins
- **Persistent Changes** - Order changes persist across sessions
- **Navigation Integration** - Custom order affects buffer navigation commands

### Smart Auto-Detection

bufferin.nvim intelligently adapts to your environment:

```lua
-- Automatic optimization based on your setup
require('bufferin').setup() -- That's it!
```

**Detection Logic:**
1. **cokeline detected** → Uses cokeline's buffer management API
2. **bufferline detected** → Integrates with bufferline's component system  
3. **Neither detected** → Uses optimized standalone buffer manipulation
4. **Icon plugins** → Automatically uses best available (devicons > mini.icons > builtin)

## 🛠️ Development

### Running Tests

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"

# Run specific test
nvim --headless -u tests/minimal_init.lua -c "luafile tests/buffer_management_test.lua"
```

### Code Quality

```bash
# Check Lua syntax
luacheck lua/

# Format code
stylua lua/

# Format specific file
stylua lua/bufferin/init.lua
```

### Project Structure

```
bufferin.nvim/
├── lua/bufferin/
│   ├── init.lua        # Main entry point and setup
│   ├── config.lua      # Configuration and plugin detection
│   ├── buffer.lua      # Buffer operations and plugin integration
│   ├── ui.lua          # User interface and window layout
│   ├── utils.lua       # Utility functions
│   └── icons.lua       # Icon provider management
├── plugin/bufferin.lua # Vim plugin integration
├── doc/bufferin.txt    # Comprehensive documentation
└── tests/              # Test suite
```

## 📚 Documentation

- `:help bufferin` - Complete Vim help documentation
- `:help bufferin-config` - Configuration options
- `:help bufferin-commands` - Available commands
- `:help bufferin-keymaps` - Key mappings

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Run the test suite (`make test`)
6. Commit your changes (`git commit -m 'Add some amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **nvim-cokeline** - Inspiration for buffer management API design
- **bufferline.nvim** - Buffer manipulation techniques
- **nvim-web-devicons** - Icon provider integration
- **mini.icons** - Alternative icon provider support
- **plenary.nvim** - Testing framework
- The amazing Neovim community for feedback and contributions

## 📞 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/your-username/bufferin.nvim/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/your-username/bufferin.nvim/discussions)
- 📖 **Documentation**: `:help bufferin`
- 💬 **Community**: [Neovim Discord](https://discord.gg/neovim)

---

⭐ If bufferin.nvim helps improve your Neovim workflow, please consider giving it a star!

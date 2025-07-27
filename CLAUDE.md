# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Testing

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"

# Run specific test
nvim --headless -u tests/minimal_init.lua -c "luafile tests/buffer_management_test.lua"
```

### Code Quality

```bash
# Run linter
luacheck lua/

# Format code (uses stylua.toml config)
stylua lua/

# Format specific file
stylua lua/bufferin/init.lua
```

## Architecture Overview

bufferin.nvim is a Neovim buffer management plugin written in Lua. The architecture follows a modular design:

### Core Modules

- **init.lua** - Main entry point, provides setup() and high-level API
- **config.lua** - Configuration management with defaults and user overrides
- **buffer.lua** - Buffer operations (list, select, delete, reorder) and custom ordering
- **ui.lua** - Floating window UI, keybindings, and display logic
- **utils.lua** - Utility functions (display names, search matching)
- **icons.lua** - File type icon support (nvim-web-devicons, mini.icons, builtin)

### Key Design Patterns

- **Real Buffer Reordering**: Uses swap-based algorithm inspired by bufferline.nvim to actually change buffer arrangement
- **Custom Buffer Ordering**: Plugin maintains its own buffer order separate from Neovim's internal order
- **Icon Provider Abstraction**: Automatically detects and uses available icon plugins (devicons/mini.icons) with builtin fallback
- **Configuration Deep Merge**: User config is deep-merged with defaults using vim.tbl_deep_extend
- **Floating Window State**: UI state is maintained in local state table (buf, win, search_term, selected_line)
- **Navigation Integration**: Global variables store custom order for navigation command synchronization
- **Persistent Order**: Buffer order is saved/restored between sessions using JSON-encoded file paths

### Buffer Management

- Custom order is stored in `custom_order` array in buffer.lua
- `move_buffer()` performs actual buffer swapping using direct array element exchange
- `sync_buffer_order()` stores order in global variables for navigation integration
- `save_custom_order()` and `restore_custom_order()` handle session persistence
- Navigation (next/prev) follows custom order with 5-second freshness check
- Layout visualization uses Unicode box-drawing characters for window mapping
- Performance optimization with cached window layout computation

### Configuration Options

- `show_window_layout` (default: false) - Show window layout visualization (experimental)
- `override_navigation` (default: false) - Override :bnext/:bprev to use custom order
- Buffer order synchronization and session persistence are always enabled as core features

### Plugin Compatibility

- **nvim-cokeline**: Auto-detects and uses cokeline's buf_order system via move_buffer()
- **Standalone**: Uses internal swap-based reordering inspired by bufferline.nvim
- **bufferline.nvim**: Compatible architecture but separate implementations

### Testing Framework

Uses plenary.nvim for testing with minimal_init.lua setup. Tests cover:

- Configuration handling
- Buffer operations (list, delete, select, reorder)
- Plugin integration (cokeline, bufferline)
- Layout visualization
- Navigation and synchronization
- Edge cases (empty lists, same names, window state)

### Code Style

- 4 spaces indentation (stylua.toml)
- Single quotes preferred for strings
- 120 character line width
- Always use call parentheses
- Never collapse simple statements
- LuaLS-style documentation annotations for all public functions

### Key Global Variables

- `_G.bufferin_window_open` - Prevents buffer switching during UI operations
- `vim.g.bufferin_custom_order` - Current buffer order for navigation
- `vim.g.bufferin_last_update` - Timestamp for order freshness check
- `vim.g.bufferin_saved_order` - JSON-encoded persistent order storage

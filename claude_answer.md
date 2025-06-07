## File: README.md
```markdown
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
```# bufferin.nvim

## Directory Structure
```
bufferin.nvim/
├── lua/
│   └── bufferin/
│       ├── init.lua
│       ├── ui.lua
│       ├── buffer.lua
│       ├── config.lua
│       ├── icons.lua
│       └── utils.lua
├── plugin/
│   └── bufferin.lua
├── doc/
│   └── bufferin.txt
├── .github/
│   └── workflows/
│       └── ci.yml
├── tests/
│   └── bufferin_spec.lua
├── LICENSE
├── README.md
└── .luacheckrc
```

## File: lua/bufferin/init.lua
```lua
local M = {}

local ui = require('bufferin.ui')
local config = require('bufferin.config')
local buffer = require('bufferin.buffer')

--- Initialize the plugin with user configuration
--- @param opts table|nil User configuration options
function M.setup(opts)
    config.setup(opts or {})

    -- Optionally override :bnext and :bprev to use custom order
    if config.get().override_navigation then
        M.setup_navigation_overrides()
    end
end

--- Open the buffer manager window
--- Shows a floating window with all open buffers
function M.open()
    ui.open()
end

--- Toggle the buffer manager window
--- Opens if closed, closes if open
function M.toggle()
    ui.toggle()
end

--- Navigate to the next buffer in custom order
--- Wraps around to the first buffer when reaching the end
function M.next()
    local buffers = buffer.get_buffers()
    local current = vim.api.nvim_get_current_buf()

    for i, buf in ipairs(buffers) do
        if buf.bufnr == current then
            local next_idx = i < #buffers and i + 1 or 1
            buffer.select(buffers[next_idx].bufnr)
            return
        end
    end

    -- If current buffer not found, go to first
    if #buffers > 0 then
        buffer.select(buffers[1].bufnr)
    end
end

--- Navigate to the previous buffer in custom order
--- Wraps around to the last buffer when reaching the beginning
function M.prev()
    local buffers = buffer.get_buffers()
    local current = vim.api.nvim_get_current_buf()

    for i, buf in ipairs(buffers) do
        if buf.bufnr == current then
            local prev_idx = i > 1 and i - 1 or #buffers
            buffer.select(buffers[prev_idx].bufnr)
            return
        end
    end

    -- If current buffer not found, go to last
    if #buffers > 0 then
        buffer.select(buffers[#buffers].bufnr)
    end
end

--- Setup navigation command overrides
--- This replaces :bnext and :bprev with custom order navigation
function M.setup_navigation_overrides()
    vim.api.nvim_create_user_command('BufferinNext', M.next, { desc = 'Go to next buffer in custom order' })
    vim.api.nvim_create_user_command('BufferinPrev', M.prev, { desc = 'Go to previous buffer in custom order' })

    -- Optionally remap :bnext and :bprev
    vim.cmd([[
        cabbrev <expr> bnext getcmdtype() == ':' && getcmdline() == 'bnext' ? 'BufferinNext' : 'bnext'
        cabbrev <expr> bprev getcmdtype() == ':' && getcmdline() == 'bprev' ? 'BufferinPrev' : 'bprev'
        cabbrev <expr> bprevious getcmdtype() == ':' && getcmdline() == 'bprevious' ? 'BufferinPrev' : 'bprevious'
    ]])
end

return M
```

## File: lua/bufferin/config.lua
```lua
local M = {}

-- Default configuration values
local defaults = {
    -- Window configuration
    window = {
        width = 0.8,        -- Percentage of screen width (0.0 to 1.0)
        height = 0.8,       -- Percentage of screen height (0.0 to 1.0)
        border = 'rounded', -- Border style: 'single', 'double', 'rounded', 'solid', 'shadow', 'none'
        position = 'center', -- Window position (currently only 'center' is supported)
    },
    -- Key mappings for buffer operations
    mappings = {
        select = '<CR>',        -- Select buffer under cursor
        delete = 'dd',          -- Delete buffer under cursor
        move_up = 'K',          -- Move buffer up in the list
        move_down = 'J',        -- Move buffer down in the list
        quit = 'q',             -- Close the bufferin window
        search = '/',           -- Start search mode
        clear_search = '<Esc>', -- Clear current search
        preview = 'p',          -- Preview buffer contents
    },
    -- Display options
    display = {
        show_numbers = true,    -- Show buffer numbers
        show_modified = true,   -- Show modified indicator
        show_path = true,       -- Show file paths
        show_hidden = false,    -- Show hidden/unlisted buffers
        show_icons = true,      -- Show file type icons
    },
    -- Icon configuration
    icons = {
        modified = '●',         -- Icon for modified buffers
        readonly = '',         -- Icon for readonly buffers
        terminal = '',         -- Icon for terminal buffers
        -- Icon provider: 'auto', 'devicons', 'mini', or 'builtin'
        provider = 'auto',      -- Auto-detect available icon provider
        -- Fallback icons when using builtin provider
        builtin = {
            default = '',       -- Default file icon
            folder = '',        -- Folder icon
            lua = '',           -- Lua files
            vim = '',           -- Vim files
            js = '',            -- JavaScript files
            ts = '',            -- TypeScript files
            jsx = '',           -- JSX files
            tsx = '',           -- TSX files
            py = '',            -- Python files
            rb = '',            -- Ruby files
            go = '',            -- Go files
            rs = '',            -- Rust files
            c = '',             -- C files
            cpp = '',           -- C++ files
            h = '',             -- Header files
            hpp = '',           -- C++ header files
            java = '',          -- Java files
            sh = '',            -- Shell scripts
            bash = '',          -- Bash scripts
            zsh = '',           -- Zsh scripts
            fish = '',          -- Fish scripts
            ps1 = '',           -- PowerShell scripts
            json = '',          -- JSON files
            yaml = '',          -- YAML files
            yml = '',           -- YAML files (alternative extension)
            toml = '',          -- TOML files
            xml = '',           -- XML files
            html = '',          -- HTML files
            css = '',           -- CSS files
            scss = '',          -- SCSS files
            sass = '',          -- Sass files
            less = '',          -- Less files
            md = '',            -- Markdown files
            markdown = '',      -- Markdown files (alternative extension)
            tex = '',           -- LaTeX files
            txt = '',           -- Text files
            log = '',           -- Log files
            sql = '',           -- SQL files
            docker = '',        -- Dockerfile
            git = '',           -- Git files
            svg = '',           -- SVG files
            png = '',           -- PNG images
            jpg = '',           -- JPG images
            jpeg = '',          -- JPEG images
            gif = '',           -- GIF images
            ico = '',           -- Icon files
            pdf = '',           -- PDF files
            zip = '',           -- ZIP archives
            tar = '',           -- TAR archives
            gz = '',            -- Gzip files
            rar = '',           -- RAR archives
            ['7z'] = '',        -- 7-Zip archives
            lock = '',          -- Lock files
        },
    },
    -- Navigation behavior
    override_navigation = false, -- Override :bnext/:bprev to use custom order
}

-- Current configuration (merged with defaults)
M.options = {}

--- Setup the configuration with user options
--- @param opts table|nil User configuration to merge with defaults
function M.setup(opts)
    M.options = vim.tbl_deep_extend('force', defaults, opts or {})
end

--- Get the current configuration
--- @return table Current configuration
function M.get()
    return M.options
end

return M
```

## File: lua/bufferin/buffer.lua
```lua
local M = {}
local utils = require('bufferin.utils')
local config = require('bufferin.config')

-- Get list of all buffers with metadata
function M.get_buffers()
    local buffers = {}
    local conf = config.get()

    -- Get buffers in their actual order (left to right as shown in :buffers)
    for i = 1, vim.fn.bufnr('

## File: lua/buffer-manager/ui.lua
```lua
local M = {}
local buffer = require('buffer-manager.buffer')
local config = require('buffer-manager.config')
local utils = require('buffer-manager.utils')
local icons = require('buffer-manager.icons')

local state = {
    buf = nil,
    win = nil,
    search_term = '',
    selected_line = 1,
}

-- Create floating window
local function create_window()
    local conf = config.get()

    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', 'bufferin')

    -- Calculate window size
    local width = math.floor(vim.o.columns * conf.window.width)
    local height = math.floor(vim.o.lines * conf.window.height)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create window
    local win_opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = conf.window.border,
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Set window options
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    -- Setup icon highlights
    icons.setup_highlights()

    return buf, win
end

-- Render buffer list
local function render_buffers(buffers)
    local lines = {}
    local highlights = {}
    local conf = config.get()

    -- Header
    table.insert(lines, ' Bufferin')
    table.insert(lines, string.rep('─', vim.api.nvim_win_get_width(state.win) - 2))

    -- Buffer list
    for i, buf in ipairs(buffers) do
        local line = ''
        local col_offset = 0

        -- Buffer number
        if conf.display.show_numbers then
            line = line .. string.format('%3d: ', buf.bufnr)
            col_offset = col_offset + 5
        end

        -- File icon
        if conf.display.show_icons then
            local icon, icon_hl = icons.get_icon(buf.name)
            if icon and icon ~= '' then
                line = line .. icon .. ' '
                if icon_hl then
                    table.insert(highlights, {
                        line = i + 2,
                        col_start = col_offset,
                        col_end = col_offset + vim.fn.strwidth(icon),
                        hl_group = icon_hl,
                    })
                end
                col_offset = col_offset + vim.fn.strwidth(icon) + 1
            end
        end

        -- Status icons
        if buf.modified then
            line = line .. conf.icons.modified .. ' '
            table.insert(highlights, {
                line = i + 2,
                col_start = col_offset,
                col_end = col_offset + vim.fn.strwidth(conf.icons.modified),
                hl_group = 'DiagnosticError',
            })
            col_offset = col_offset + vim.fn.strwidth(conf.icons.modified) + 1
        elseif buf.readonly then
            line = line .. conf.icons.readonly .. ' '
            col_offset = col_offset + vim.fn.strwidth(conf.icons.readonly) + 1
        else
            line = line .. '  '
            col_offset = col_offset + 2
        end

        -- Current buffer indicator
        if buf.current then
            line = line .. '▸ '
        else
            line = line .. '  '
        end
        col_offset = col_offset + 2

        -- Buffer name
        line = line .. buf.display_name

        -- Path
        if conf.display.show_path and buf.name ~= '' then
            local dir = vim.fn.fnamemodify(buf.name, ':h')
            if dir ~= '.' then
                line = line .. ' (' .. dir .. ')'
            end
        end

        table.insert(lines, line)

        -- Highlight current buffer
        if buf.current then
            table.insert(highlights, {
                line = i + 2,
                col_start = 0,
                col_end = -1,
                hl_group = 'Visual',
            })
        end
    end

    -- Footer with help
    table.insert(lines, string.rep('─', vim.api.nvim_win_get_width(state.win) - 2))
    table.insert(lines, ' [Enter] Select  [dd] Delete  [K/J] Move  [/] Search  [q] Quit')

    -- Set buffer content
    vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)

    -- Apply highlights
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(
            state.buf,
            -1,
            hl.hl_group,
            hl.line - 1,
            hl.col_start,
            hl.col_end
        )
    end
end

-- Get buffer list filtered by search
local function get_filtered_buffers()
    local buffers = buffer.get_buffers()

    if state.search_term ~= '' then
        local filtered = {}
        for _, buf in ipairs(buffers) do
            if utils.matches_search(buf, state.search_term) then
                table.insert(filtered, buf)
            end
        end
        buffers = filtered
    end

    return buffers
end

-- Refresh display
local function refresh()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        local buffers = get_filtered_buffers()
        render_buffers(buffers)

        -- Restore cursor position
        local line_count = vim.api.nvim_buf_line_count(state.buf)
        local cursor_line = math.min(state.selected_line + 2, line_count - 1)
        cursor_line = math.max(3, cursor_line) -- Skip header
        vim.api.nvim_win_set_cursor(state.win, { cursor_line, 0 })
    end
end

-- Get buffer at current line
local function get_current_buffer()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    local buffers = get_filtered_buffers()
    local idx = line - 2 -- Account for header

    if idx > 0 and idx <= #buffers then
        state.selected_line = idx
        return buffers[idx], idx, buffers
    end

    return nil, nil, buffers
end

-- Keybinding handlers
local function handle_select()
    local buf_info = get_current_buffer()
    if buf_info then
        M.close()
        buffer.select(buf_info.bufnr)
    end
end

local function handle_delete()
    local buf_info = get_current_buffer()
    if buf_info then
        if buffer.delete(buf_info.bufnr, false) then
            refresh()
        end
    end
end

local function handle_move_up()
    local buf_info, idx, buffers = get_current_buffer()
    if buf_info and idx > 1 then
        -- Only allow moving when not searching
        if state.search_term == '' then
            if buffer.move_buffer(idx, idx - 1, buffer.get_buffers()) then
                state.selected_line = idx - 1
                refresh()
            end
        else
            vim.notify("Cannot reorder buffers while searching", vim.log.levels.WARN)
        end
    end
end

local function handle_move_down()
    local buf_info, idx, buffers = get_current_buffer()
    if buf_info and idx < #buffers then
        -- Only allow moving when not searching
        if state.search_term == '' then
            if buffer.move_buffer(idx, idx + 1, buffer.get_buffers()) then
                state.selected_line = idx + 1
                refresh()
            end
        else
            vim.notify("Cannot reorder buffers while searching", vim.log.levels.WARN)
        end
    end
end

local function handle_search()
    local search = vim.fn.input('Search: ', state.search_term)
    if search then
        state.search_term = search
        state.selected_line = 1
        refresh()
    end
end

local function handle_clear_search()
    if state.search_term ~= '' then
        state.search_term = ''
        refresh()
    end
end

local function handle_preview()
    local buf_info = get_current_buffer()
    if buf_info and buf_info.name ~= '' then
        -- Check if file exists
        if vim.fn.filereadable(buf_info.name) == 0 then
            vim.notify("File not found: " .. buf_info.name, vim.log.levels.WARN)
            return
        end

        -- Create preview window
        local preview_buf = vim.api.nvim_create_buf(false, true)

        -- Load file content safely
        local ok, lines = pcall(vim.fn.readfile, buf_info.name, '', 50)
        if not ok then
            vim.notify("Failed to read file: " .. buf_info.name, vim.log.levels.ERROR)
            return
        end

        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

        -- Set filetype for syntax highlighting
        local ft = vim.filetype.match({ filename = buf_info.name })
        if ft then
            vim.api.nvim_buf_set_option(preview_buf, 'filetype', ft)
        end

        -- Create preview window
        local width = math.floor(vim.o.columns * 0.5)
        local height = math.floor(vim.o.lines * 0.5)

        local preview_win = vim.api.nvim_open_win(preview_buf, false, {
            relative = 'cursor',
            width = width,
            height = height,
            row = 1,
            col = 0,
            style = 'minimal',
            border = 'single',
        })

        -- Close preview on any movement
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = state.buf,
            once = true,
            callback = function()
                if vim.api.nvim_win_is_valid(preview_win) then
                    vim.api.nvim_win_close(preview_win, true)
                end
            end,
        })
    end
end

-- Setup keybindings
local function setup_mappings()
    local conf = config.get()
    local opts = { noremap = true, silent = true, buffer = state.buf }

    vim.keymap.set('n', conf.mappings.select, handle_select, opts)
    vim.keymap.set('n', conf.mappings.delete, handle_delete, opts)
    vim.keymap.set('n', conf.mappings.move_up, handle_move_up, opts)
    vim.keymap.set('n', conf.mappings.move_down, handle_move_down, opts)
    vim.keymap.set('n', conf.mappings.quit, M.close, opts)
    vim.keymap.set('n', conf.mappings.search, handle_search, opts)
    vim.keymap.set('n', conf.mappings.clear_search, handle_clear_search, opts)
    vim.keymap.set('n', conf.mappings.preview, handle_preview, opts)

    -- Auto refresh on buffer changes
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
        callback = function()
            if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                vim.schedule(refresh)
            end
        end,
    })
end

-- Open buffer manager
function M.open()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_set_current_win(state.win)
        return
    end

    state.buf, state.win = create_window()
    setup_mappings()
    refresh()
end

-- Close buffer manager
function M.close()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.buf = nil
    state.win = nil
    state.search_term = ''
    state.selected_line = 1
end

-- Toggle buffer manager
function M.toggle()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        M.close()
    else
        M.open()
    end
end

return M
```_buf = vim.api.nvim_create_buf(false, true)

        -- Load file content
        local lines = vim.fn.readfile(buf_info.name, '', 50) -- First 50 lines
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

        -- Set filetype for syntax highlighting
        local ft = vim.filetype.match({ filename = buf_info.name })
        if ft then
            vim.api.nvim_buf_set_option(preview_buf, 'filetype', ft)
        end

        -- Create preview window
        local width = math.floor(vim.o.columns * 0.5)
        local height = math.floor(vim.o.lines * 0.5)

        local preview_win = vim.api.nvim_open_win(preview_buf, false, {
            relative = 'cursor',
            width = width,
            height = height,
            row = 1,
            col = 0,
            style = 'minimal',
            border = 'single',
        })

        -- Close preview on any movement
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = state.buf,
            once = true,
            callback = function()
                if vim.api.nvim_win_is_valid(preview_win) then
                    vim.api.nvim_win_close(preview_win, true)
                end
            end,
        })
    end
end

-- Setup keybindings
local function setup_mappings()
    local conf = config.get()
    local opts = { noremap = true, silent = true, buffer = state.buf }

    vim.keymap.set('n', conf.mappings.select, handle_select, opts)
    vim.keymap.set('n', conf.mappings.delete, handle_delete, opts)
    vim.keymap.set('n', conf.mappings.move_up, handle_move_up, opts)
    vim.keymap.set('n', conf.mappings.move_down, handle_move_down, opts)
    vim.keymap.set('n', conf.mappings.quit, M.close, opts)
    vim.keymap.set('n', conf.mappings.search, handle_search, opts)
    vim.keymap.set('n', conf.mappings.clear_search, handle_clear_search, opts)
    vim.keymap.set('n', conf.mappings.preview, handle_preview, opts)

    -- Auto refresh on buffer changes
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
        callback = function()
            if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                vim.schedule(refresh)
            end
        end,
    })
end

-- Open buffer manager
function M.open()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_set_current_win(state.win)
        return
    end

    state.buf, state.win = create_window()
    setup_mappings()
    refresh()
end

-- Close buffer manager
function M.close()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.buf = nil
    state.win = nil
    state.search_term = ''
    state.selected_line = 1
end

-- Toggle buffer manager
function M.toggle()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        M.close()
    else
        M.open()
    end
end

return M
```

## File: lua/bufferin/utils.lua
```lua
local M = {}

--- Get a display name for a buffer
--- Handles special cases like empty names and terminal buffers
--- @param path string The full buffer path
--- @return string The display name
function M.get_display_name(path)
    if path == '' then
        return '[No Name]'
    end

    -- Special handling for terminal buffers
    if path:match('^term://') then
        return '[Terminal]'
    end

    -- Extract filename from path
    local name = vim.fn.fnamemodify(path, ':t')
    if name == '' then
        -- If no filename, use the parent directory name
        name = vim.fn.fnamemodify(path, ':h:t')
    end

    return name
end

--- Check if a buffer matches the search term
--- Performs case-insensitive search on both filename and path
--- @param buf table Buffer information table
--- @param search_term string The search term
--- @return boolean True if buffer matches the search
function M.matches_search(buf, search_term)
    local lower_search = search_term:lower()
    local lower_name = buf.display_name:lower()
    local lower_path = buf.name:lower()

    -- Check if search term is found in either name or path
    return lower_name:find(lower_search, 1, true) or
           lower_path:find(lower_search, 1, true)
end

return M
```

## File: plugin/bufferin.lua
```lua
-- bufferin.nvim
-- A simple and intuitive buffer manager for Neovim
-- Repository: https://github.com/wasabeef/bufferin.nvim
-- License: MIT

-- Check Neovim version compatibility
if vim.fn.has('nvim-0.7.0') ~= 1 then
    vim.api.nvim_err_writeln('bufferin.nvim requires Neovim 0.7.0+')
    return
end

-- Register user commands

-- Open the buffer manager window
vim.api.nvim_create_user_command('Bufferin', function()
    require('bufferin').open()
end, { desc = 'Open bufferin window' })

-- Toggle the buffer manager window
vim.api.nvim_create_user_command('BufferinToggle', function()
    require('bufferin').toggle()
end, { desc = 'Toggle bufferin window' })

-- Navigate to next buffer in custom order
vim.api.nvim_create_user_command('BufferinNext', function()
    require('bufferin').next()
end, { desc = 'Go to next buffer in custom order' })

-- Navigate to previous buffer in custom order
vim.api.nvim_create_user_command('BufferinPrev', function()
    require('bufferin').prev()
end, { desc = 'Go to previous buffer in custom order' })
```

## File: doc/bufferin.txt
```
*bufferin.txt*    A simple and intuitive buffer manager for Neovim

==============================================================================
CONTENTS                                                   *bufferin-contents*

  1. Introduction.......................................|bufferin-introduction|
  2. Requirements.......................................|bufferin-requirements|
  3. Installation.......................................|bufferin-installation|
  4. Usage.................................................|bufferin-usage|
  5. Configuration...................................|bufferin-configuration|
  6. Commands.............................................|bufferin-commands|
  7. Mappings.............................................|bufferin-mappings|
  8. Icons.................................................|bufferin-icons|
  9. License...............................................|bufferin-license|

==============================================================================
1. INTRODUCTION                                        *bufferin-introduction*

bufferin.nvim is a simple and intuitive buffer manager for Neovim.
It provides an easy way to navigate, delete, and reorder buffers through
a floating window interface with file type icon support.

Features:
- List all open buffers in a floating window
- Display file type icons (supports nvim-web-devicons and mini.icons)
- Navigate to buffers with Enter
- Delete buffers with dd
- Reorder buffers with K/J (changes actual Vim buffer order)
- Search buffers with /
- Preview buffer contents with p

==============================================================================
2. REQUIREMENTS                                        *bufferin-requirements*

- Neovim >= 0.7.0
- Optional: nvim-web-devicons or mini.icons for file icons

==============================================================================
3. INSTALLATION                                        *bufferin-installation*

Using packer.nvim:
>
  use {
    'wasabeef/bufferin.nvim',
    config = function()
      require('bufferin').setup()
    end,
    requires = { 'nvim-tree/nvim-web-devicons' } -- optional
  }
<

Using lazy.nvim:
>
  {
    'wasabeef/bufferin.nvim',
    config = function()
      require('bufferin').setup()
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' } -- optional
  }
<

==============================================================================
4. USAGE                                                     *bufferin-usage*

Open bufferin:
>
  :Bufferin
<

Or toggle it:
>
  :BufferinToggle
<

You can also map it to a key:
>
  vim.keymap.set('n', '<leader>b', ':Bufferin<CR>')
<

==============================================================================
5. CONFIGURATION                                      *bufferin-configuration*

Setup bufferin with custom options:
>
  require('bufferin').setup({
    window = {
      width = 0.8,      -- Window width (0-1 for percentage)
      height = 0.8,     -- Window height (0-1 for percentage)
      border = 'rounded', -- Border style
      position = 'center', -- Window position
    },
    mappings = {
      select = '<CR>',    -- Select buffer
      delete = 'dd',      -- Delete buffer
      move_up = 'K',      -- Move buffer up
      move_down = 'J',    -- Move buffer down
      quit = 'q',         -- Close window
      search = '/',       -- Search buffers
      clear_search = '<Esc>', -- Clear search
      preview = 'p',      -- Preview buffer
    },
    display = {
      show_numbers = true,  -- Show buffer numbers
      show_modified = true, -- Show modified indicator
      show_path = true,     -- Show file path
      show_hidden = false,  -- Show hidden buffers
      show_icons = true,    -- Show file type icons
    },
    icons = {
      modified = '●',    -- Modified buffer icon
      readonly = '',    -- Readonly buffer icon
      terminal = '',    -- Terminal buffer icon
      provider = 'auto', -- Icon provider: 'auto', 'devicons', 'mini', 'builtin'
      builtin = {        -- Builtin icons (when no icon plugin available)
        default = '',
        lua = '',
        vim = '',
        -- ... see config.lua for full list
      },
    },
  })
<

==============================================================================
6. COMMANDS                                                *bufferin-commands*

*:Bufferin*
    Open the bufferin window

*:BufferinToggle*
    Toggle the bufferin window

*:BufferinNext*
    Go to the next buffer in custom order

*:BufferinPrev*
    Go to the previous buffer in custom order

==============================================================================
7. MAPPINGS                                                *bufferin-mappings*

Default mappings inside the bufferin window:

  <CR>        Select the buffer under cursor
  dd          Delete the buffer under cursor
  K           Move buffer up in the list
  J           Move buffer down in the list
  q           Close bufferin
  /           Search buffers
  <Esc>       Clear search
  p           Preview buffer contents

==============================================================================
8. ICONS                                                      *bufferin-icons*

bufferin.nvim supports multiple icon providers:

1. nvim-web-devicons - Provides the most comprehensive icon set
2. mini.icons - Lightweight alternative
3. builtin - Basic icons included with the plugin

The plugin automatically detects which provider is available. You can
manually specify the provider in the configuration:
>
  icons = {
    provider = 'devicons', -- 'auto', 'devicons', 'mini', or 'builtin'
  }
<

When using the builtin provider, you can customize the icons for different
file types in the configuration.

==============================================================================
9. LICENSE                                                  *bufferin-license*

MIT License. See LICENSE file for details.

==============================================================================
vim:tw=78:ts=8:ft=help:norl:
```

## File: README.md
```markdown
# buffer-manager.nvim

A simple and intuitive buffer manager for Neovim with file type icons support.

![Buffer Manager Demo](https://user-images.githubusercontent.com/your-username/buffer-manager-demo.gif)

## ✨ Features

- 📋 **List all buffers** - View all open buffers in a clean floating window
- 🎨 **File type icons** - Display icons based on file extensions (supports nvim-web-devicons and mini.icons)
- 🚀 **Quick navigation** - Jump to any buffer with Enter
- 🗑️ **Easy deletion** - Remove buffers with `dd` (with unsaved changes protection)
- 🔄 **Reorder buffers** - Move buffers up/down with `K`/`J`
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
  'your-username/buffer-manager.nvim',
  config = function()
    require('buffer-manager').setup()
  end,
  -- Optional: for file icons
  requires = { 'nvim-tree/nvim-web-devicons' }
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'your-username/buffer-manager.nvim',
  cmd = { "BufferManager", "BufferManagerToggle" },
  config = function()
    require('buffer-manager').setup()
  end,
  -- Optional: for file icons
  dependencies = { 'nvim-tree/nvim-web-devicons' }
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'your-username/buffer-manager.nvim'
" Optional: for file icons
Plug 'nvim-tree/nvim-web-devicons'
```

## 🚀 Usage

### Commands

- `:BufferManager` - Open the buffer manager
- `:BufferManagerToggle` - Toggle the buffer manager

### Recommended Keybinding

```lua
vim.keymap.set('n', '<leader>b', '<cmd>BufferManager<cr>', { desc = 'Buffer Manager' })
```

### Default Keybindings (inside buffer manager)

| Key | Action |
|-----|--------|
| `<CR>` or `Enter` | Select buffer |
| `dd` | Delete buffer |
| `K` | Move buffer up |
| `J` | Move buffer down |
| `q` | Close buffer manager |
| `/` | Search buffers |
| `<Esc>` | Clear search |
| `p` | Preview buffer |

## ⚙️ Configuration

```lua
require('buffer-manager').setup({
  -- Window configuration
  window = {
    width = 0.8,        -- 80% of screen width
    height = 0.8,       -- 80% of screen height
    border = 'rounded', -- 'single', 'double', 'rounded', 'solid', 'shadow'
    position = 'center',
  },

  -- Key mappings (inside buffer manager window)
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

buffer-manager.nvim supports three icon providers:

1. **nvim-web-devicons** - Recommended for the best icon coverage
2. **mini.icons** - Lightweight alternative
3. **builtin** - Basic icons included with the plugin

The plugin automatically detects which icon provider is available. You can manually specify the provider:

```lua
require('buffer-manager').setup({
  icons = {
    provider = 'devicons',  -- 'auto', 'devicons', 'mini', or 'builtin'
  },
})
```

## 📝 Buffer Ordering

The plugin remembers the order of your buffers even after reordering them with `K`/`J`. This order persists until you restart Neovim.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by various buffer management solutions in the Neovim ecosystem
- Icon support thanks to nvim-web-devicons and mini.icons
- Built with love for the Neovim community

## 📞 Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/your-username/buffer-manager.nvim/issues).
```

## File: LICENSE
```
MIT License

Copyright (c) 2024 wasabeef

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## File: .github/workflows/ci.yml
```yaml
# Continuous Integration workflow for bufferin.nvim
# Runs tests, linting, and formatting checks on every push and pull request

name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  # Run test suite on multiple Neovim versions
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        neovim_version:
          - stable    # Latest stable release
          - nightly   # Development version

    steps:
    # Checkout the repository
    - uses: actions/checkout@v3

    # Install Neovim
    - name: Install Neovim
      uses: rhysd/action-setup-vim@v1
      with:
        neovim: true
        version: ${{ matrix.neovim_version }}

    # Install test framework
    - name: Install Plenary
      run: |
        git clone https://github.com/nvim-lua/plenary.nvim.git ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim

    # Run test suite
    - name: Run tests
      run: |
        nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua', sequential = true }"

  # Run luacheck linter
  lint:
    runs-on: ubuntu-latest

    steps:
    # Checkout the repository
    - uses: actions/checkout@v3

    # Install luacheck
    - name: Install luacheck
      run: |
        sudo apt-get update
        sudo apt-get install -y luarocks
        sudo luarocks install luacheck

    # Run linter
    - name: Run luacheck
      run: luacheck lua/

  # Check code formatting
  format:
    runs-on: ubuntu-latest

    steps:
    # Checkout the repository
    - uses: actions/checkout@v3

    # Install and run stylua
    - name: Install stylua
      uses: JohnnyMorganz/stylua-action@v3
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        version: latest
        args: --check lua/
```

## File: .luacheckrc
```lua
-- Luacheck configuration file for bufferin.nvim
-- Defines linting rules and exceptions

return {
    -- Global variables
    globals = {
        "vim",  -- Neovim global
    },
    -- Read-only globals (from test framework)
    read_globals = {
        "describe",     -- Test suite declaration
        "it",           -- Test case declaration
        "before_each",  -- Setup function
        "after_each",   -- Teardown function
        "assert",       -- Assertion library
        "pcall",        -- Protected call (Lua builtin)
    },
    -- Files to exclude from linting
    exclude_files = {
        ".luacheckrc",
        "tests/minimal_init.lua",  -- Test setup file
    },
    -- Maximum line length
    max_line_length = 120,
    -- Warnings to ignore
    ignore = {
        "212", -- Unused argument
        "213", -- Unused loop variable
    },
}
```

## File: tests/minimal_init.lua
```lua
-- Minimal init file for running tests
-- This sets up the bare minimum Neovim configuration needed to run the test suite

-- Test environment paths
local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local plugin_dir = os.getenv("PLUGIN_DIR") or "."

-- Add test framework and plugin to runtime path
vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(plugin_dir)

-- Disable swap files and backups for cleaner test environment
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false

-- Load the test framework
vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")

-- Load the plugin being tested
require("bufferin")
```

## File: tests/bufferin_spec.lua
```lua
--- Test suite for bufferin.nvim
--- Covers core functionality including buffer operations, navigation, and search

local bufferin = require('bufferin')
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')
local utils = require('bufferin.utils')

describe("bufferin", function()
    before_each(function()
        -- Reset to default configuration
        config.setup({})

        -- Clear custom buffer order
        buffer.set_custom_order({})

        -- Clean up all buffers except current to ensure consistent test environment
        local current = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= current and vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end)

    describe("setup", function()
        it("should accept custom configuration", function()
            bufferin.setup({
                window = {
                    width = 0.5,
                    height = 0.5,
                },
                mappings = {
                    select = '<Space>',
                },
                override_navigation = true,
            })

            local conf = config.get()
            assert.equals(0.5, conf.window.width)
            assert.equals(0.5, conf.window.height)
            assert.equals('<Space>', conf.mappings.select)
            assert.equals(true, conf.override_navigation)
        end)
    end)

    describe("buffer operations", function()
        it("should list all buffers", function()
            -- Create test buffers
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)

            local buffers = buffer.get_buffers()
            assert.equals(3, #buffers) -- Current + 2 created
        end)

        it("should filter hidden buffers", function()
            -- Create visible buffer
            local visible = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(visible, "visible.txt")

            -- Create hidden buffer
            local hidden = vim.api.nvim_create_buf(false, true)

            config.setup({ display = { show_hidden = false } })
            local buffers = buffer.get_buffers()

            local found_hidden = false
            for _, buf in ipairs(buffers) do
                if buf.bufnr == hidden then
                    found_hidden = true
                end
            end

            assert.is_false(found_hidden)
        end)

        it("should delete buffer", function()
            local buf = vim.api.nvim_create_buf(true, false)
            assert.is_true(vim.api.nvim_buf_is_valid(buf))

            buffer.delete(buf, true)
            assert.is_false(vim.api.nvim_buf_is_valid(buf))
        end)

        it("should select buffer", function()
            local buf = vim.api.nvim_create_buf(true, false)
            buffer.select(buf)
            assert.equals(buf, vim.api.nvim_get_current_buf())
        end)

        it("should reorder buffers", function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)
            local buf3 = vim.api.nvim_create_buf(true, false)

            local buffers = buffer.get_buffers()
            local initial_order = {}
            for _, buf in ipairs(buffers) do
                table.insert(initial_order, buf.bufnr)
            end

            -- Move second buffer to first position
            buffer.move_buffer(2, 1, buffers)

            local new_buffers = buffer.get_buffers()
            assert.equals(initial_order[2], new_buffers[1].bufnr)
            assert.equals(initial_order[1], new_buffers[2].bufnr)
        end)

        it("should handle invalid move operations", function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buffers = buffer.get_buffers()

            -- Test invalid indices
            assert.is_false(buffer.move_buffer(0, 1, buffers))
            assert.is_false(buffer.move_buffer(1, 0, buffers))
            assert.is_false(buffer.move_buffer(1, #buffers + 1, buffers))
            assert.is_false(buffer.move_buffer(1, 1, buffers)) -- Same position
        end)

        it("should maintain custom order across buffer additions", function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)

            local buffers = buffer.get_buffers()
            buffer.move_buffer(2, 1, buffers)

            -- Add new buffer
            local buf3 = vim.api.nvim_create_buf(true, false)

            local new_buffers = buffer.get_buffers()
            -- New buffer should be at the end
            assert.equals(buf3, new_buffers[#new_buffers].bufnr)
        end)
    end)

    describe("search functionality", function()
        it("should match buffer by name", function()
            local buf_info = {
                display_name = "test.lua",
                name = "/home/user/test.lua",
            }

            assert.is_true(utils.matches_search(buf_info, "test"))
            assert.is_true(utils.matches_search(buf_info, "lua"))
            assert.is_false(utils.matches_search(buf_info, "vim"))
        end)

        it("should match buffer by path", function()
            local buf_info = {
                display_name = "test.lua",
                name = "/home/user/project/test.lua",
            }

            assert.is_true(utils.matches_search(buf_info, "home"))
            assert.is_true(utils.matches_search(buf_info, "project"))
        end)

        it("should handle case-insensitive search", function()
            local buf_info = {
                display_name = "Test.Lua",
                name = "/Home/User/Test.Lua",
            }

            assert.is_true(utils.matches_search(buf_info, "test"))
            assert.is_true(utils.matches_search(buf_info, "TEST"))
            assert.is_true(utils.matches_search(buf_info, "lua"))
            assert.is_true(utils.matches_search(buf_info, "LUA"))
        end)
    end)

    describe("navigation", function()
        it("should navigate to next buffer", function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)
            local buf3 = vim.api.nvim_create_buf(true, false)

            buffer.select(buf1)
            bufferin.next()
            assert.equals(buf2, vim.api.nvim_get_current_buf())

            bufferin.next()
            assert.equals(buf3, vim.api.nvim_get_current_buf())

            -- Should wrap around
            bufferin.next()
            local current_buf = vim.api.nvim_get_current_buf()
            assert.is_true(current_buf == buf1 or vim.fn.buflisted(current_buf) == 1)
        end)

        it("should navigate to previous buffer", function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)
            local buf3 = vim.api.nvim_create_buf(true, false)

            buffer.select(buf3)
            bufferin.prev()
            assert.equals(buf2, vim.api.nvim_get_current_buf())

            bufferin.prev()
            assert.equals(buf1, vim.api.nvim_get_current_buf())
        end)

        it("should respect custom order in navigation", function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)
            local buf3 = vim.api.nvim_create_buf(true, false)

            -- Reorder: move buf3 to position 1
            local buffers = buffer.get_buffers()
            local buf3_idx = nil
            for i, b in ipairs(buffers) do
                if b.bufnr == buf3 then
                    buf3_idx = i
                    break
                end
            end

            if buf3_idx then
                buffer.move_buffer(buf3_idx, 1, buffers)

                -- Now order should be buf3, current, buf1, buf2
                buffer.select(buf3)
                bufferin.next()
                -- Should navigate according to custom order
                local next_buf = vim.api.nvim_get_current_buf()
                assert.is_true(vim.fn.buflisted(next_buf) == 1)
            end
        end)
    end)

    describe("utils", function()
        it("should get correct display name", function()
            assert.equals("[No Name]", utils.get_display_name(""))
            assert.equals("test.lua", utils.get_display_name("/path/to/test.lua"))
            assert.equals("[Terminal]", utils.get_display_name("term://something"))
        end)
    end)

    describe("edge cases", function()
        it("should handle empty buffer list", function()
            -- Delete all buffers including current
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end

            -- Create a new buffer
            vim.cmd("enew")

            local buffers = buffer.get_buffers()
            assert.equals(1, #buffers)
        end)

        it("should handle buffers with same name", function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(buf1, "test.txt")

            local buf2 = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(buf2, "test.txt")

            local buffers = buffer.get_buffers()
            local found_count = 0
            for _, buf in ipairs(buffers) do
                if buf.display_name == "test.txt" then
                    found_count = found_count + 1
                end
            end

            assert.equals(2, found_count)
        end)
    end)
end)
```

## File: .gitignore
```
# Neovim swap files
*.swp
*.swo
*~

# macOS system files
.DS_Store

# Testing artifacts
/plenary.nvim/

# IDE configuration files
.idea/
.vscode/

# Log files
*.log

# Temporary files
*.tmp
*.bak
```

## File: stylua.toml
```toml
# Stylua configuration for bufferin.nvim
# Defines code formatting rules

column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 4
quote_style = "AutoPreferSingle"
call_parentheses = "Always"
collapse_simple_statement = "Never"

[sort_requires]
enabled = false
```

## File: .editorconfig
```ini
# EditorConfig configuration for bufferin.nvim
# Ensures consistent coding styles between different editors and IDEs
# EditorConfig is awesome: https://EditorConfig.org

# This is the top-most EditorConfig file
root = true

# Default settings for all files
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

# YAML files use 2 spaces
[*.{yml,yaml}]
indent_size = 2

# Markdown files may have trailing whitespace
[*.md]
trim_trailing_whitespace = false

# Makefiles require tabs
[Makefile]
indent_style = tab
```

## File: CONTRIBUTING.md
```markdown
# Contributing to bufferin.nvim

First off, thank you for considering contributing to bufferin.nvim!

## Ways to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- Neovim version (`nvim --version`)
- bufferin.nvim configuration
- Steps to reproduce
- Expected behavior
- Actual behavior
- Error messages (if any)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- Use case for the feature
- Proposed solution
- Alternative solutions considered
- Additional context

### Pull Requests

1. Fork the repo and create your branch from `main`
2. Add tests for any new functionality
3. Ensure the test suite passes
4. Make sure your code follows the existing style
5. Write a clear commit message

## Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/your-username/bufferin.nvim.git
   cd bufferin.nvim
   ```

2. Install development dependencies:
   - [luacheck](https://github.com/mpeterv/luacheck) for linting
   - [stylua](https://github.com/JohnnyMorganz/StyLua) for formatting
   - [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing

3. Run tests:
   ```bash
   nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"
   ```

4. Run linter:
   ```bash
   luacheck lua/
   ```

5. Format code:
   ```bash
   stylua lua/
   ```

## Code Style

- Use 4 spaces for indentation
- Follow the existing code style
- Add comments for complex logic
- Keep functions small and focused
- Use descriptive variable names

## Testing

- Write tests for new features
- Ensure all tests pass before submitting PR
- Test with both stable and nightly Neovim

## Documentation

- Update README.md if adding new features
- Update help documentation in doc/
- Add inline comments for complex code
- Include examples where appropriate

## Commit Messages

- Use clear and meaningful commit messages
- Start with a verb in present tense
- Keep the first line under 50 characters
- Add detailed description if needed

Example:
```
Add search highlighting feature

- Highlight matching characters in buffer names
- Add configuration option to disable highlighting
- Update documentation with new feature
```

Thank you for contributing!
```) do
        if vim.fn.buflisted(i) == 1 then
            local name = vim.api.nvim_buf_get_name(i)
            local buftype = vim.api.nvim_buf_get_option(i, 'buftype')

            -- Skip hidden buffers if configured
            if conf.display.show_hidden or (name ~= '' and buftype == '') then
                local modified = vim.api.nvim_buf_get_option(i, 'modified')
                local readonly = vim.api.nvim_buf_get_option(i, 'readonly')

                table.insert(buffers, {
                    bufnr = i,
                    name = name,
                    display_name = utils.get_display_name(name),
                    modified = modified,
                    readonly = readonly,
                    buftype = buftype,
                    current = i == vim.api.nvim_get_current_buf(),
                })
            end
        end
    end

    return buffers
end

-- Select a buffer
function M.select(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_set_current_buf(bufnr)
        return true
    end
    return false
end

-- Delete a buffer
function M.delete(bufnr, force)
    if vim.api.nvim_buf_is_valid(bufnr) then
        local modified = vim.api.nvim_buf_get_option(bufnr, 'modified')

        if modified and not force then
            local choice = vim.fn.confirm(
                'Buffer has unsaved changes. Delete anyway?',
                '&Yes\n&No\n&Save and Delete',
                2
            )

            if choice == 1 then -- Yes
                vim.api.nvim_buf_delete(bufnr, { force = true })
                return true
            elseif choice == 3 then -- Save and Delete
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd('write')
                end)
                vim.api.nvim_buf_delete(bufnr, { force = false })
                return true
            end
            return false
        else
            vim.api.nvim_buf_delete(bufnr, { force = force })
            return true
        end
    end
    return false
end

return M
```

## File: lua/buffer-manager/ui.lua
```lua
local M = {}
local buffer = require('buffer-manager.buffer')
local config = require('buffer-manager.config')
local utils = require('buffer-manager.utils')
local icons = require('buffer-manager.icons')

local state = {
    buf = nil,
    win = nil,
    search_term = '',
    selected_line = 1,
}

-- Create floating window
local function create_window()
    local conf = config.get()

    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', 'bufferin')

    -- Calculate window size
    local width = math.floor(vim.o.columns * conf.window.width)
    local height = math.floor(vim.o.lines * conf.window.height)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create window
    local win_opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = conf.window.border,
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Set window options
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    -- Setup icon highlights
    icons.setup_highlights()

    return buf, win
end

-- Render buffer list
local function render_buffers(buffers)
    local lines = {}
    local highlights = {}
    local conf = config.get()

    -- Header
    table.insert(lines, ' Bufferin')
    table.insert(lines, string.rep('─', vim.api.nvim_win_get_width(state.win) - 2))

    -- Buffer list
    for i, buf in ipairs(buffers) do
        local line = ''
        local col_offset = 0

        -- Buffer number
        if conf.display.show_numbers then
            line = line .. string.format('%3d: ', buf.bufnr)
            col_offset = col_offset + 5
        end

        -- File icon
        if conf.display.show_icons then
            local icon, icon_hl = icons.get_icon(buf.name)
            if icon and icon ~= '' then
                line = line .. icon .. ' '
                if icon_hl then
                    table.insert(highlights, {
                        line = i + 2,
                        col_start = col_offset,
                        col_end = col_offset + vim.fn.strwidth(icon),
                        hl_group = icon_hl,
                    })
                end
                col_offset = col_offset + vim.fn.strwidth(icon) + 1
            end
        end

        -- Status icons
        if buf.modified then
            line = line .. conf.icons.modified .. ' '
            table.insert(highlights, {
                line = i + 2,
                col_start = col_offset,
                col_end = col_offset + vim.fn.strwidth(conf.icons.modified),
                hl_group = 'DiagnosticError',
            })
            col_offset = col_offset + vim.fn.strwidth(conf.icons.modified) + 1
        elseif buf.readonly then
            line = line .. conf.icons.readonly .. ' '
            col_offset = col_offset + vim.fn.strwidth(conf.icons.readonly) + 1
        else
            line = line .. '  '
            col_offset = col_offset + 2
        end

        -- Current buffer indicator
        if buf.current then
            line = line .. '▸ '
        else
            line = line .. '  '
        end
        col_offset = col_offset + 2

        -- Buffer name
        line = line .. buf.display_name

        -- Path
        if conf.display.show_path and buf.name ~= '' then
            local dir = vim.fn.fnamemodify(buf.name, ':h')
            if dir ~= '.' then
                line = line .. ' (' .. dir .. ')'
            end
        end

        table.insert(lines, line)

        -- Highlight current buffer
        if buf.current then
            table.insert(highlights, {
                line = i + 2,
                col_start = 0,
                col_end = -1,
                hl_group = 'Visual',
            })
        end
    end

    -- Footer with help
    table.insert(lines, string.rep('─', vim.api.nvim_win_get_width(state.win) - 2))
    table.insert(lines, ' [Enter] Select  [dd] Delete  [K/J] Move  [/] Search  [q] Quit')

    -- Set buffer content
    vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)

    -- Apply highlights
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(
            state.buf,
            -1,
            hl.hl_group,
            hl.line - 1,
            hl.col_start,
            hl.col_end
        )
    end
end

-- Get buffer list filtered by search
local function get_filtered_buffers()
    local buffers = buffer.get_buffers()

    if state.search_term ~= '' then
        local filtered = {}
        for _, buf in ipairs(buffers) do
            if utils.matches_search(buf, state.search_term) then
                table.insert(filtered, buf)
            end
        end
        buffers = filtered
    end

    return buffers
end

-- Refresh display
local function refresh()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        local buffers = get_filtered_buffers()
        render_buffers(buffers)

        -- Restore cursor position
        local line_count = vim.api.nvim_buf_line_count(state.buf)
        local cursor_line = math.min(state.selected_line + 2, line_count - 1)
        cursor_line = math.max(3, cursor_line) -- Skip header
        vim.api.nvim_win_set_cursor(state.win, { cursor_line, 0 })
    end
end

-- Get buffer at current line
local function get_current_buffer()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    local buffers = get_filtered_buffers()
    local idx = line - 2 -- Account for header

    if idx > 0 and idx <= #buffers then
        state.selected_line = idx
        return buffers[idx], idx, buffers
    end

    return nil, nil, buffers
end

-- Keybinding handlers
local function handle_select()
    local buf_info = get_current_buffer()
    if buf_info then
        M.close()
        buffer.select(buf_info.bufnr)
    end
end

local function handle_delete()
    local buf_info = get_current_buffer()
    if buf_info then
        if buffer.delete(buf_info.bufnr, false) then
            refresh()
        end
    end
end

local function handle_move_up()
    local buf_info, idx, buffers = get_current_buffer()
    if buf_info and idx > 1 then
        if buffer.move_buffer(idx, idx - 1, buffers) then
            state.selected_line = idx - 1
            refresh()
        end
    end
end

local function handle_move_down()
    local buf_info, idx, buffers = get_current_buffer()
    if buf_info and idx < #buffers then
        if buffer.move_buffer(idx, idx + 1, buffers) then
            state.selected_line = idx + 1
            refresh()
        end
    end
end

local function handle_search()
    local search = vim.fn.input('Search: ', state.search_term)
    if search then
        state.search_term = search
        state.selected_line = 1
        refresh()
    end
end

local function handle_clear_search()
    if state.search_term ~= '' then
        state.search_term = ''
        refresh()
    end
end

local function handle_preview()
    local buf_info = get_current_buffer()
    if buf_info and buf_info.name ~= '' then
        -- Create preview window
        local preview_buf = vim.api.nvim_create_buf(false, true)

        -- Load file content
        local lines = vim.fn.readfile(buf_info.name, '', 50) -- First 50 lines
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

        -- Set filetype for syntax highlighting
        local ft = vim.filetype.match({ filename = buf_info.name })
        if ft then
            vim.api.nvim_buf_set_option(preview_buf, 'filetype', ft)
        end

        -- Create preview window
        local width = math.floor(vim.o.columns * 0.5)
        local height = math.floor(vim.o.lines * 0.5)

        local preview_win = vim.api.nvim_open_win(preview_buf, false, {
            relative = 'cursor',
            width = width,
            height = height,
            row = 1,
            col = 0,
            style = 'minimal',
            border = 'single',
        })

        -- Close preview on any movement
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = state.buf,
            once = true,
            callback = function()
                if vim.api.nvim_win_is_valid(preview_win) then
                    vim.api.nvim_win_close(preview_win, true)
                end
            end,
        })
    end
end

-- Setup keybindings
local function setup_mappings()
    local conf = config.get()
    local opts = { noremap = true, silent = true, buffer = state.buf }

    vim.keymap.set('n', conf.mappings.select, handle_select, opts)
    vim.keymap.set('n', conf.mappings.delete, handle_delete, opts)
    vim.keymap.set('n', conf.mappings.move_up, handle_move_up, opts)
    vim.keymap.set('n', conf.mappings.move_down, handle_move_down, opts)
    vim.keymap.set('n', conf.mappings.quit, M.close, opts)
    vim.keymap.set('n', conf.mappings.search, handle_search, opts)
    vim.keymap.set('n', conf.mappings.clear_search, handle_clear_search, opts)
    vim.keymap.set('n', conf.mappings.preview, handle_preview, opts)

    -- Auto refresh on buffer changes
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
        callback = function()
            if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                vim.schedule(refresh)
            end
        end,
    })
end

-- Open buffer manager
function M.open()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_set_current_win(state.win)
        return
    end

    state.buf, state.win = create_window()
    setup_mappings()
    refresh()
end

-- Close buffer manager
function M.close()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.buf = nil
    state.win = nil
    state.search_term = ''
    state.selected_line = 1
end

-- Toggle buffer manager
function M.toggle()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        M.close()
    else
        M.open()
    end
end

return M
```_buf = vim.api.nvim_create_buf(false, true)

        -- Load file content
        local lines = vim.fn.readfile(buf_info.name, '', 50) -- First 50 lines
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

        -- Set filetype for syntax highlighting
        local ft = vim.filetype.match({ filename = buf_info.name })
        if ft then
            vim.api.nvim_buf_set_option(preview_buf, 'filetype', ft)
        end

        -- Create preview window
        local width = math.floor(vim.o.columns * 0.5)
        local height = math.floor(vim.o.lines * 0.5)

        local preview_win = vim.api.nvim_open_win(preview_buf, false, {
            relative = 'cursor',
            width = width,
            height = height,
            row = 1,
            col = 0,
            style = 'minimal',
            border = 'single',
        })

        -- Close preview on any movement
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = state.buf,
            once = true,
            callback = function()
                if vim.api.nvim_win_is_valid(preview_win) then
                    vim.api.nvim_win_close(preview_win, true)
                end
            end,
        })
    end
end

-- Setup keybindings
local function setup_mappings()
    local conf = config.get()
    local opts = { noremap = true, silent = true, buffer = state.buf }

    vim.keymap.set('n', conf.mappings.select, handle_select, opts)
    vim.keymap.set('n', conf.mappings.delete, handle_delete, opts)
    vim.keymap.set('n', conf.mappings.move_up, handle_move_up, opts)
    vim.keymap.set('n', conf.mappings.move_down, handle_move_down, opts)
    vim.keymap.set('n', conf.mappings.quit, M.close, opts)
    vim.keymap.set('n', conf.mappings.search, handle_search, opts)
    vim.keymap.set('n', conf.mappings.clear_search, handle_clear_search, opts)
    vim.keymap.set('n', conf.mappings.preview, handle_preview, opts)

    -- Auto refresh on buffer changes
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
        callback = function()
            if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                vim.schedule(refresh)
            end
        end,
    })
end

-- Open buffer manager
function M.open()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_set_current_win(state.win)
        return
    end

    state.buf, state.win = create_window()
    setup_mappings()
    refresh()
end

-- Close buffer manager
function M.close()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.buf = nil
    state.win = nil
    state.search_term = ''
    state.selected_line = 1
end

-- Toggle buffer manager
function M.toggle()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        M.close()
    else
        M.open()
    end
end

return M
```

## File: lua/bufferin/utils.lua
```lua
local M = {}

-- Get display name for buffer
function M.get_display_name(path)
    if path == '' then
        return '[No Name]'
    end

    -- Special handling for terminal buffers
    if path:match('^term://') then
        return '[Terminal]'
    end

    -- Get filename
    local name = vim.fn.fnamemodify(path, ':t')
    if name == '' then
        name = vim.fn.fnamemodify(path, ':h:t')
    end

    return name
end

-- Check if buffer matches search term
function M.matches_search(buf, search_term)
    local lower_search = search_term:lower()
    local lower_name = buf.display_name:lower()
    local lower_path = buf.name:lower()

    return lower_name:find(lower_search, 1, true) or
           lower_path:find(lower_search, 1, true)
end

return M
```

## File: plugin/bufferin.lua
```lua
-- bufferin.nvim
-- A simple and intuitive buffer manager for Neovim

if vim.fn.has('nvim-0.7.0') ~= 1 then
    vim.api.nvim_err_writeln('bufferin.nvim requires Neovim 0.7.0+')
    return
end

-- Create commands
vim.api.nvim_create_user_command('Bufferin', function()
    require('bufferin').open()
end, { desc = 'Open bufferin' })

vim.api.nvim_create_user_command('BufferinToggle', function()
    require('bufferin').toggle()
end, { desc = 'Toggle bufferin' })
```

## File: doc/bufferin.txt
```
*bufferin.txt*    A simple and intuitive buffer manager for Neovim

==============================================================================
CONTENTS                                                   *bufferin-contents*

  1. Introduction.......................................|bufferin-introduction|
  2. Requirements.......................................|bufferin-requirements|
  3. Installation.......................................|bufferin-installation|
  4. Usage.................................................|bufferin-usage|
  5. Configuration...................................|bufferin-configuration|
  6. Commands.............................................|bufferin-commands|
  7. Mappings.............................................|bufferin-mappings|
  8. Icons.................................................|bufferin-icons|
  9. License...............................................|bufferin-license|

==============================================================================
1. INTRODUCTION                                        *bufferin-introduction*

bufferin.nvim is a simple and intuitive buffer manager for Neovim.
It provides an easy way to navigate, delete, and reorder buffers through
a floating window interface with file type icon support.

Features:
- List all open buffers in a floating window
- Display file type icons (supports nvim-web-devicons and mini.icons)
- Navigate to buffers with Enter
- Delete buffers with dd
- Reorder buffers with K/J
- Search buffers with /
- Preview buffer contents with p

==============================================================================
2. REQUIREMENTS                                        *bufferin-requirements*

- Neovim >= 0.7.0
- Optional: nvim-web-devicons or mini.icons for file icons

==============================================================================
3. INSTALLATION                                        *bufferin-installation*

Using packer.nvim:
>
  use {
    'wasabeef/bufferin.nvim',
    config = function()
      require('bufferin').setup()
    end,
    requires = { 'nvim-tree/nvim-web-devicons' } -- optional
  }
<

Using lazy.nvim:
>
  {
    'wasabeef/bufferin.nvim',
    config = function()
      require('bufferin').setup()
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' } -- optional
  }
<

==============================================================================
4. USAGE                                                     *bufferin-usage*

Open bufferin:
>
  :Bufferin
<

Or toggle it:
>
  :BufferinToggle
<

You can also map it to a key:
>
  vim.keymap.set('n', '<leader>b', ':Bufferin<CR>')
<

==============================================================================
5. CONFIGURATION                                      *bufferin-configuration*

Setup bufferin with custom options:
>
  require('bufferin').setup({
    window = {
      width = 0.8,      -- Window width (0-1 for percentage)
      height = 0.8,     -- Window height (0-1 for percentage)
      border = 'rounded', -- Border style
      position = 'center', -- Window position
    },
    mappings = {
      select = '<CR>',    -- Select buffer
      delete = 'dd',      -- Delete buffer
      move_up = 'K',      -- Move buffer up
      move_down = 'J',    -- Move buffer down
      quit = 'q',         -- Close window
      search = '/',       -- Search buffers
      clear_search = '<Esc>', -- Clear search
      preview = 'p',      -- Preview buffer
    },
    display = {
      show_numbers = true,  -- Show buffer numbers
      show_modified = true, -- Show modified indicator
      show_path = true,     -- Show file path
      show_hidden = false,  -- Show hidden buffers
      show_icons = true,    -- Show file type icons
    },
    icons = {
      modified = '●',    -- Modified buffer icon
      readonly = '',    -- Readonly buffer icon
      terminal = '',    -- Terminal buffer icon
      provider = 'auto', -- Icon provider: 'auto', 'devicons', 'mini', 'builtin'
      builtin = {        -- Builtin icons (when no icon plugin available)
        default = '',
        lua = '',
        vim = '',
        -- ... see config.lua for full list
      },
    },
  })
<

==============================================================================
6. COMMANDS                                                *bufferin-commands*

*:Bufferin*
    Open the bufferin window

*:BufferinToggle*
    Toggle the bufferin window

==============================================================================
7. MAPPINGS                                                *bufferin-mappings*

Default mappings inside the bufferin window:

  <CR>        Select the buffer under cursor
  dd          Delete the buffer under cursor
  K           Move buffer up in the list
  J           Move buffer down in the list
  q           Close bufferin
  /           Search buffers
  <Esc>       Clear search
  p           Preview buffer contents

==============================================================================
8. ICONS                                                      *bufferin-icons*

bufferin.nvim supports multiple icon providers:

1. nvim-web-devicons - Provides the most comprehensive icon set
2. mini.icons - Lightweight alternative
3. builtin - Basic icons included with the plugin

The plugin automatically detects which provider is available. You can
manually specify the provider in the configuration:
>
  icons = {
    provider = 'devicons', -- 'auto', 'devicons', 'mini', or 'builtin'
  }
<

When using the builtin provider, you can customize the icons for different
file types in the configuration.

==============================================================================
9. LICENSE                                                  *bufferin-license*

MIT License. See LICENSE file for details.

==============================================================================
vim:tw=78:ts=8:ft=help:norl:
```

## File: README.md
```markdown
# buffer-manager.nvim

A simple and intuitive buffer manager for Neovim with file type icons support.

![Buffer Manager Demo](https://user-images.githubusercontent.com/your-username/buffer-manager-demo.gif)

## ✨ Features

- 📋 **List all buffers** - View all open buffers in a clean floating window
- 🎨 **File type icons** - Display icons based on file extensions (supports nvim-web-devicons and mini.icons)
- 🚀 **Quick navigation** - Jump to any buffer with Enter
- 🗑️ **Easy deletion** - Remove buffers with `dd` (with unsaved changes protection)
- 🔄 **Reorder buffers** - Move buffers up/down with `K`/`J`
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
  'your-username/buffer-manager.nvim',
  config = function()
    require('buffer-manager').setup()
  end,
  -- Optional: for file icons
  requires = { 'nvim-tree/nvim-web-devicons' }
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'your-username/buffer-manager.nvim',
  cmd = { "BufferManager", "BufferManagerToggle" },
  config = function()
    require('buffer-manager').setup()
  end,
  -- Optional: for file icons
  dependencies = { 'nvim-tree/nvim-web-devicons' }
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'your-username/buffer-manager.nvim'
" Optional: for file icons
Plug 'nvim-tree/nvim-web-devicons'
```

## 🚀 Usage

### Commands

- `:BufferManager` - Open the buffer manager
- `:BufferManagerToggle` - Toggle the buffer manager

### Recommended Keybinding

```lua
vim.keymap.set('n', '<leader>b', '<cmd>BufferManager<cr>', { desc = 'Buffer Manager' })
```

### Default Keybindings (inside buffer manager)

| Key | Action |
|-----|--------|
| `<CR>` or `Enter` | Select buffer |
| `dd` | Delete buffer |
| `K` | Move buffer up |
| `J` | Move buffer down |
| `q` | Close buffer manager |
| `/` | Search buffers |
| `<Esc>` | Clear search |
| `p` | Preview buffer |

## ⚙️ Configuration

```lua
require('buffer-manager').setup({
  -- Window configuration
  window = {
    width = 0.8,        -- 80% of screen width
    height = 0.8,       -- 80% of screen height
    border = 'rounded', -- 'single', 'double', 'rounded', 'solid', 'shadow'
    position = 'center',
  },

  -- Key mappings (inside buffer manager window)
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

buffer-manager.nvim supports three icon providers:

1. **nvim-web-devicons** - Recommended for the best icon coverage
2. **mini.icons** - Lightweight alternative
3. **builtin** - Basic icons included with the plugin

The plugin automatically detects which icon provider is available. You can manually specify the provider:

```lua
require('buffer-manager').setup({
  icons = {
    provider = 'devicons',  -- 'auto', 'devicons', 'mini', or 'builtin'
  },
})
```

## 📝 Buffer Ordering

The plugin remembers the order of your buffers even after reordering them with `K`/`J`. This order persists until you restart Neovim.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by various buffer management solutions in the Neovim ecosystem
- Icon support thanks to nvim-web-devicons and mini.icons
- Built with love for the Neovim community

## 📞 Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/your-username/buffer-manager.nvim/issues).
```

## File: LICENSE
```
MIT License

Copyright (c) 2024 wasabeef

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## File: .github/workflows/ci.yml
```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        neovim_version:
          - stable
          - nightly

    steps:
    - uses: actions/checkout@v3

    - name: Install Neovim
      uses: rhysd/action-setup-vim@v1
      with:
        neovim: true
        version: ${{ matrix.neovim_version }}

    - name: Install Plenary
      run: |
        git clone https://github.com/nvim-lua/plenary.nvim.git ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim

    - name: Run tests
      run: |
        nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua' }"

  lint:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Install luacheck
      run: |
        sudo apt-get update
        sudo apt-get install -y luarocks
        sudo luarocks install luacheck

    - name: Run luacheck
      run: luacheck lua/

  format:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Install stylua
      uses: JohnnyMorganz/stylua-action@v3
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        version: latest
        args: --check lua/
```

## File: .luacheckrc
```lua
-- Luacheck configuration file
return {
    globals = {
        "vim",
    },
    read_globals = {
        "describe",
        "it",
        "before_each",
        "after_each",
        "assert",
    },
    exclude_files = {
        ".luacheckrc",
    },
    max_line_length = 120,
}
```

## File: tests/minimal_init.lua
```lua
-- Minimal init file for running tests
local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local plugin_dir = os.getenv("PLUGIN_DIR") or "."

vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(plugin_dir)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
```

## File: tests/bufferin_spec.lua
```lua
local bufferin = require('bufferin')
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')

describe("bufferin", function()
    before_each(function()
        -- Reset config to defaults
        config.setup({})

        -- Clean up all buffers except current
        local current = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= current and vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end)

    describe("setup", function()
        it("should accept custom configuration", function()
            bufferin.setup({
                window = {
                    width = 0.5,
                    height = 0.5,
                },
                mappings = {
                    select = '<Space>',
                },
            })

            local conf = config.get()
            assert.equals(0.5, conf.window.width)
            assert.equals(0.5, conf.window.height)
            assert.equals('<Space>', conf.mappings.select)
        end)
    end)

    describe("buffer operations", function()
        it("should list all buffers", function()
            -- Create test buffers
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)

            local buffers = buffer.get_buffers()
            assert.equals(3, #buffers) -- Current + 2 created
        end)

        it("should filter hidden buffers", function()
            -- Create visible buffer
            local visible = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(visible, "visible.txt")

            -- Create hidden buffer
            local hidden = vim.api.nvim_create_buf(false, true)

            config.setup({ display = { show_hidden = false } })
            local buffers = buffer.get_buffers()

            local found_hidden = false
            for _, buf in ipairs(buffers) do
                if buf.bufnr == hidden then
                    found_hidden = true
                end
            end

            assert.is_false(found_hidden)
        end)

        it("should delete buffer", function()
            local buf = vim.api.nvim_create_buf(true, false)
            assert.is_true(vim.api.nvim_buf_is_valid(buf))

            buffer.delete(buf, true)
            assert.is_false(vim.api.nvim_buf_is_valid(buf))
        end)

        it("should select buffer", function()
            local buf = vim.api.nvim_create_buf(true, false)
            buffer.select(buf)
            assert.equals(buf, vim.api.nvim_get_current_buf())
        end)

        it("should reorder buffers", function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)
            local buf3 = vim.api.nvim_create_buf(true, false)

            local buffers = buffer.get_buffers()
            local initial_order = {}
            for _, buf in ipairs(buffers) do
                table.insert(initial_order, buf.bufnr)
            end

            -- Move second buffer to first position
            buffer.move_buffer(2, 1, buffers)

            local new_buffers = buffer.get_buffers()
            assert.equals(initial_order[2], new_buffers[1].bufnr)
            assert.equals(initial_order[1], new_buffers[2].bufnr)
        end)
    end)

    describe("search functionality", function()
        it("should match buffer by name", function()
            local utils = require('bufferin.utils')

            local buf_info = {
                display_name = "test.lua",
                name = "/home/user/test.lua",
            }

            assert.is_true(utils.matches_search(buf_info, "test"))
            assert.is_true(utils.matches_search(buf_info, "lua"))
            assert.is_false(utils.matches_search(buf_info, "vim"))
        end)

        it("should match buffer by path", function()
            local utils = require('bufferin.utils')

            local buf_info = {
                display_name = "test.lua",
                name = "/home/user/project/test.lua",
            }

            assert.is_true(utils.matches_search(buf_info, "home"))
            assert.is_true(utils.matches_search(buf_info, "project"))
        end)
    end)
end)
```

## File: .gitignore
```
# Neovim
*.swp
*.swo
*~

# macOS
.DS_Store

# Testing
/plenary.nvim/

# IDE
.idea/
.vscode/

# Logs
*.log
```

## File: stylua.toml
```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 4
quote_style = "AutoPreferSingle"
call_parentheses = "Always"
collapse_simple_statement = "Never"

[sort_requires]
enabled = false
```

## File: .editorconfig
```ini
# EditorConfig is awesome: https://EditorConfig.org

root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

[*.{yml,yaml}]
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

## File: CONTRIBUTING.md
```markdown
# Contributing to bufferin.nvim

First off, thank you for considering contributing to bufferin.nvim!

## Ways to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- Neovim version (`nvim --version`)
- bufferin.nvim configuration
- Steps to reproduce
- Expected behavior
- Actual behavior
- Error messages (if any)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- Use case for the feature
- Proposed solution
- Alternative solutions considered
- Additional context

### Pull Requests

1. Fork the repo and create your branch from `main`
2. Add tests for any new functionality
3. Ensure the test suite passes
4. Make sure your code follows the existing style
5. Write a clear commit message

## Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/your-username/bufferin.nvim.git
   cd bufferin.nvim
   ```

2. Install development dependencies:
   - [luacheck](https://github.com/mpeterv/luacheck) for linting
   - [stylua](https://github.com/JohnnyMorganz/StyLua) for formatting
   - [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing

3. Run tests:
   ```bash
   nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"
   ```

4. Run linter:
   ```bash
   luacheck lua/
   ```

5. Format code:
   ```bash
   stylua lua/
   ```

## Code Style

- Use 4 spaces for indentation
- Follow the existing code style
- Add comments for complex logic
- Keep functions small and focused
- Use descriptive variable names

## Testing

- Write tests for new features
- Ensure all tests pass before submitting PR
- Test with both stable and nightly Neovim

## Documentation

- Update README.md if adding new features
- Update help documentation in doc/
- Add inline comments for complex code
- Include examples where appropriate

## Commit Messages

- Use clear and meaningful commit messages
- Start with a verb in present tense
- Keep the first line under 50 characters
- Add detailed description if needed

Example:
```
Add search highlighting feature

- Highlight matching characters in buffer names
- Add configuration option to disable highlighting
- Update documentation with new feature
```

Thank you for contributing!
```

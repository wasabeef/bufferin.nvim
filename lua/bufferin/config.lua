--- Configuration module for bufferin.nvim
--- Handles plugin settings, defaults, and external plugin detection
--- @module bufferin.config

local M = {}

--- Default configuration values
--- @type table
local defaults = {
    -- Window configuration
    window = {
        width = 0.8, -- Percentage of screen width (0.0 to 1.0)
        height = 0.8, -- Percentage of screen height (0.0 to 1.0)
        border = 'rounded', -- Border style: 'single', 'double', 'rounded', 'solid', 'shadow', 'none'
        position = 'center', -- Window position (currently only 'center' is supported)
    },
    -- Key mappings for buffer operations
    mappings = {
        select = '<CR>', -- Select buffer under cursor
        delete = 'dd', -- Delete buffer under cursor
        move_up = 'K', -- Move buffer up in the list
        move_down = 'J', -- Move buffer down in the list
        quit = 'q', -- Close the bufferin window
    },
    -- Display options
    display = {
        show_numbers = true, -- Show buffer numbers
        show_modified = true, -- Show modified indicator
        show_path = true, -- Show file paths
        show_hidden = false, -- Show hidden/unlisted buffers
        show_icons = true, -- Show file type icons
    },
    -- Icon configuration
    icons = {
        modified = '●', -- Icon for modified buffers
        readonly = '', -- Icon for readonly buffers
        terminal = '', -- Icon for terminal buffers
        -- Icon provider: 'auto', 'devicons', 'mini', or 'builtin'
        provider = 'auto', -- Auto-detect available icon provider
        -- Fallback icons when using builtin provider
        builtin = {
            default = '', -- Default file icon
            folder = '', -- Folder icon
            lua = '', -- Lua files
            vim = '', -- Vim files
            js = '', -- JavaScript files
            ts = '', -- TypeScript files
            jsx = '', -- JSX files
            tsx = '', -- TSX files
            py = '', -- Python files
            rb = '', -- Ruby files
            go = '', -- Go files
            rs = '', -- Rust files
            c = '', -- C files
            cpp = '', -- C++ files
            h = '', -- Header files
            hpp = '', -- C++ header files
            java = '', -- Java files
            sh = '', -- Shell scripts
            bash = '', -- Bash scripts
            zsh = '', -- Zsh scripts
            fish = '', -- Fish scripts
            ps1 = '', -- PowerShell scripts
            json = '', -- JSON files
            yaml = '', -- YAML files
            yml = '', -- YAML files (alternative extension)
            toml = '', -- TOML files
            xml = '', -- XML files
            html = '', -- HTML files
            css = '', -- CSS files
            scss = '', -- SCSS files
            sass = '', -- Sass files
            less = '', -- Less files
            md = '', -- Markdown files
            markdown = '', -- Markdown files (alternative extension)
            tex = '', -- LaTeX files
            txt = '', -- Text files
            log = '', -- Log files
            sql = '', -- SQL files
            docker = '', -- Dockerfile
            git = '', -- Git files
            svg = '', -- SVG files
            png = '', -- PNG images
            jpg = '', -- JPG images
            jpeg = '', -- JPEG images
            gif = '', -- GIF images
            ico = '', -- Icon files
            pdf = '', -- PDF files
            zip = '', -- ZIP archives
            tar = '', -- TAR archives
            gz = '', -- Gzip files
            rar = '', -- RAR archives
            ['7z'] = '', -- 7-Zip archives
            lock = '', -- Lock files
        },
    },
    -- Experimental/optional features
    show_window_layout = false, -- Show window layout visualization (experimental)
    override_navigation = false, -- Override :bnext/:bprev to use custom order
}

--- Current configuration (merged with defaults)
--- @type table
M.options = {}

--- Detect available buffer line plugins
--- @return string|nil Plugin name ('cokeline' or 'bufferline') or nil if none found
local function detect_plugins()
    local detected = nil

    -- Check for cokeline
    local has_cokeline = pcall(require, 'cokeline.buffers')
    if has_cokeline then
        detected = 'cokeline'
    end

    -- Check for bufferline (only if cokeline not found)
    if not detected then
        local has_bufferline = pcall(require, 'bufferline.state')
        if has_bufferline then
            detected = 'bufferline'
        end
    end

    return detected
end

--- Setup the configuration with user options
--- @param opts table|nil User configuration to merge with defaults
function M.setup(opts)
    M.options = vim.tbl_deep_extend('force', defaults, opts or {})

    -- Detect available plugins
    M.options._detected_plugin = detect_plugins()
end

--- Get the current configuration
--- @return table Current configuration
function M.get()
    return M.options
end

return M

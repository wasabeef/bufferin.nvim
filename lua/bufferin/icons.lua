local M = {}
local config = require('bufferin.config')

-- Check for availability of nvim-web-devicons
local function has_devicons()
    return pcall(require, 'nvim-web-devicons')
end

-- Check for availability of mini.icons
local function has_mini_icons()
    return pcall(require, 'mini.icons')
end

-- Get icon from nvim-web-devicons
local function get_devicon(filename)
    local devicons = require('nvim-web-devicons')
    local ext = vim.fn.fnamemodify(filename, ':e')
    local icon, hl_group = devicons.get_icon(filename, ext, { default = true })
    return icon, hl_group
end

-- Get icon from mini.icons
local function get_mini_icon(filename)
    local mini_icons = require('mini.icons')
    local ext = vim.fn.fnamemodify(filename, ':e')
    local icon = mini_icons.get_icon(filename) or mini_icons.get_icon(ext)
    return icon, nil -- mini.icons doesn't provide highlight groups
end

-- Get icon from builtin mappings
local function get_builtin_icon(filename)
    local conf = config.get()
    local icons = conf.icons.builtin
    local ext = vim.fn.fnamemodify(filename, ':e')
    
    -- Handle special cases
    if filename:match('^term://') then
        return conf.icons.terminal, nil
    end
    
    -- Look up by extension
    local icon = icons[ext]
    if icon then
        return icon, nil
    end
    
    -- Try to match by filename for files without extension
    local basename = vim.fn.fnamemodify(filename, ':t')
    if icons[basename] then
        return icons[basename], nil
    end
    
    -- Default icon
    return icons.default, nil
end

-- Get icon provider based on configuration and availability
local function get_icon_provider()
    local conf = config.get()
    local provider = conf.icons.provider
    
    if provider == 'auto' then
        if has_devicons() then
            return 'devicons'
        elseif has_mini_icons() then
            return 'mini'
        else
            return 'builtin'
        end
    end
    
    return provider
end

-- Setup highlights for icons
function M.setup_highlights()
    -- Ensure highlight groups for icons exist
    -- This could be extended to create more groups if needed
    vim.cmd([[
        highlight default link BufferinModified DiagnosticError
        highlight default link BufferinReadOnly DiagnosticHint
        highlight default link BufferinTerminal DiagnosticInfo
    ]])
end

-- Get icon for a file
function M.get_icon(filename)
    local provider = get_icon_provider()
    
    if provider == 'devicons' and has_devicons() then
        return get_devicon(filename)
    elseif provider == 'mini' and has_mini_icons() then
        return get_mini_icon(filename)
    else
        return get_builtin_icon(filename)
    end
end

return M
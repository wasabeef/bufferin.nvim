--- Utility functions for bufferin.nvim
--- Handles display names, search functionality, and text processing
--- @module bufferin.utils

local M = {}

--- Get a display name for a buffer
--- Handles special cases like empty names and terminal buffers
--- @param path string|nil The full buffer path
--- @return string The display name
function M.get_display_name(path)
    if not path or type(path) ~= 'string' or path == '' then
        return '[No Name]'
    end

    -- Special handling for different buffer types
    if path:match('^term://') then
        return '[Terminal]'
    end

    if path:match('^fugitive://') then
        return '[Git]'
    end

    if path:match('^oil://') then
        return '[Oil]'
    end

    -- Extract filename from path with proper encoding handling
    local ok, name = pcall(vim.fn.fnamemodify, path, ':t')
    if not ok or not name or name == '' then
        -- If no filename, try to use the parent directory name
        local ok2, dir_name = pcall(vim.fn.fnamemodify, path, ':h:t')
        if ok2 and dir_name and dir_name ~= '.' then
            name = dir_name
        else
            return '[Invalid Name]'
        end
    end

    -- Encoding processing improvement
    if name and name ~= '' then
        -- No conversion needed for UTF-8 environment, try conversion only for other environments
        if vim.o.encoding ~= 'utf-8' then
            local ok_iconv, utf8_name = pcall(function()
                return vim.iconv(name, vim.o.encoding, 'utf-8')
            end)
            if ok_iconv and utf8_name and utf8_name ~= '' then
                name = utf8_name
            end
        end

        -- Remove control characters and invalid characters
        name = name:gsub('[%z\1-\31\127]', '')

        -- Fallback for empty string
        if name == '' then
            return '[Invalid Name]'
        end
    end

    return name or '[Invalid Name]'
end

--- Check if a buffer name matches a search term
--- @param term string The search term
--- @param name string The buffer name to check
--- @return boolean True if the name matches the search term
function M.matches_search(term, name)
    if not term or term == '' then
        return true
    end

    if not name then
        return false
    end

    -- Case-insensitive search
    local lower_term = term:lower()
    local lower_name = name:lower()

    return lower_name:find(lower_term, 1, true) ~= nil
end

return M

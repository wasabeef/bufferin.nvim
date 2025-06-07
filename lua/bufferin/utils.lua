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
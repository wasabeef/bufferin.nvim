local M = {}
local utils = require('bufferin.utils')
local config = require('bufferin.config')

-- Custom buffer order storage
local custom_order = {}

-- Get list of all buffers with metadata
function M.get_buffers()
    local buffers = {}
    local conf = config.get()
    
    -- Track if we have custom ordering
    local has_custom_order = #custom_order > 0
    
    -- First collect all buffers
    local all_buffers = {}
    
    -- Get buffers in their actual order (left to right as shown in :buffers)
    for i = 1, vim.fn.bufnr('$') do
        if vim.fn.buflisted(i) == 1 then
            local name = vim.api.nvim_buf_get_name(i)
            local buftype = vim.api.nvim_buf_get_option(i, 'buftype')
            
            -- Skip hidden buffers if configured
            if conf.display.show_hidden or (name ~= '' and buftype == '') then
                local modified = vim.api.nvim_buf_get_option(i, 'modified')
                local readonly = vim.api.nvim_buf_get_option(i, 'readonly')
                
                table.insert(all_buffers, {
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
    
    -- Apply custom order if available
    if has_custom_order then
        -- First add buffers that are in the custom order
        for _, bufnr in ipairs(custom_order) do
            for _, buf in ipairs(all_buffers) do
                if buf.bufnr == bufnr then
                    table.insert(buffers, buf)
                    break
                end
            end
        end
        
        -- Then add any buffers that aren't in the custom order
        for _, buf in ipairs(all_buffers) do
            local found = false
            for _, bufnr in ipairs(custom_order) do
                if buf.bufnr == bufnr then
                    found = true
                    break
                end
            end
            
            if not found then
                table.insert(buffers, buf)
            end
        end
    else
        -- No custom order, use default order
        buffers = all_buffers
    end
    
    -- Update custom order to match current buffer list
    M.update_custom_order(buffers)
    
    return buffers
end

-- Update custom order to match current buffer list
function M.update_custom_order(buffers)
    custom_order = {}
    for _, buf in ipairs(buffers) do
        table.insert(custom_order, buf.bufnr)
    end
end

-- Set custom buffer order directly
function M.set_custom_order(order)
    custom_order = order
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

-- Move a buffer from one position to another
function M.move_buffer(from_idx, to_idx, buffers)
    -- Validate indices
    if from_idx < 1 or from_idx > #buffers or 
       to_idx < 1 or to_idx > #buffers or
       from_idx == to_idx then
        return false
    end
    
    -- Get the buffer to move
    local buf_to_move = buffers[from_idx]
    
    -- Create a new buffer list with the moved buffer
    local new_buffers = {}
    for i = 1, #buffers do
        if i == from_idx then
            -- Skip this position, we're moving this buffer
        elseif i == to_idx then
            -- Insert the moved buffer at this position
            if to_idx < from_idx then
                -- Moving up, insert before the current position
                table.insert(new_buffers, buf_to_move)
                table.insert(new_buffers, buffers[i])
            else
                -- Moving down, insert after the current position
                table.insert(new_buffers, buffers[i])
                table.insert(new_buffers, buf_to_move)
            end
        else
            table.insert(new_buffers, buffers[i])
        end
    end
    
    -- Update custom order
    M.update_custom_order(new_buffers)
    
    return true
end

return M
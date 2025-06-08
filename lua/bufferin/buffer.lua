--- Buffer management module for bufferin.nvim
--- Handles buffer operations, custom ordering, and integration with external plugins
--- @module bufferin.buffer

local M = {}
local utils = require('bufferin.utils')
local config = require('bufferin.config')

--- Custom buffer order storage for internal use
--- @type table<number>
local custom_order = {}

--- Get list of all buffers with metadata
--- Retrieves buffers using the appropriate method based on detected plugins
--- @return table<{bufnr: number, name: string, display_name: string, is_current: boolean, is_modified: boolean}> List of buffer information
function M.get_buffers()
    local buffers = {}
    local conf = config.get()

    -- Use detected plugin integration
    if conf._detected_plugin == 'cokeline' then
        return M.get_buffers_with_cokeline()
    elseif conf._detected_plugin == 'bufferline' then
        return M.get_buffers_with_bufferline()
    end

    -- Fallback to standalone mode
    return M.get_buffers_fallback()
end

-- Get buffers using cokeline's order
function M.get_buffers_with_cokeline()
    local cokeline_buffers = require('cokeline.buffers')
    local conf = config.get()

    -- Get cokeline's buffer order
    local cokeline_valid_buffers = cokeline_buffers.get_valid_buffers()

    -- Convert cokeline buffers to bufferin format
    local buffers = {}
    for _, cokeline_buf in ipairs(cokeline_valid_buffers) do
        local name = cokeline_buf.path
        local buftype = cokeline_buf.type

        -- Apply display filters
        if conf.display.show_hidden or (name ~= '' and buftype == '') then
            table.insert(buffers, {
                bufnr = cokeline_buf.number,
                name = name,
                display_name = utils.get_display_name(name),
                modified = cokeline_buf.is_modified,
                readonly = cokeline_buf.is_readonly,
                buftype = buftype,
                current = cokeline_buf.is_focused,
                _cokeline_buf = cokeline_buf, -- Keep reference for moves
            })
        end
    end

    -- Update our custom order to match cokeline's order
    custom_order = {}
    for _, buf in ipairs(buffers) do
        table.insert(custom_order, buf.bufnr)
    end

    return buffers
end

-- Get buffers using bufferline.nvim's order
function M.get_buffers_with_bufferline()
    local conf = config.get()

    -- Try to get bufferline's state
    local has_bufferline_state, bufferline_state = pcall(require, 'bufferline.state')
    if has_bufferline_state and bufferline_state.components then
        -- Convert bufferline components to bufferin format
        local buffers = {}
        for _, component in ipairs(bufferline_state.components) do
            if component.id and vim.api.nvim_buf_is_valid(component.id) then
                local name = vim.api.nvim_buf_get_name(component.id)
                local buftype = vim.api.nvim_buf_get_option(component.id, 'buftype')

                if conf.display.show_hidden or (name ~= '' and buftype == '') then
                    table.insert(buffers, {
                        bufnr = component.id,
                        name = name,
                        display_name = utils.get_display_name(name),
                        modified = vim.api.nvim_buf_get_option(component.id, 'modified'),
                        readonly = vim.api.nvim_buf_get_option(component.id, 'readonly'),
                        buftype = buftype,
                        current = component.id == vim.api.nvim_get_current_buf(),
                        _bufferline_component = component, -- Keep reference
                    })
                end
            end
        end

        -- Update our custom order to match bufferline's order
        custom_order = {}
        for _, buf in ipairs(buffers) do
            table.insert(custom_order, buf.bufnr)
        end

        return buffers
    end

    -- Fallback to regular buffer list if bufferline state is not available
    return M.get_buffers_fallback()
end

-- Fallback buffer list function (original logic)
function M.get_buffers_fallback()
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

--- Update custom order to match current buffer list
--- @param buffers table<{bufnr: number}> List of buffer objects with buffer numbers
function M.update_custom_order(buffers)
    custom_order = {}
    for _, buf in ipairs(buffers) do
        table.insert(custom_order, buf.bufnr)
    end

    -- Auto-save order if persistence is enabled
    M.save_custom_order()
end

--- Set custom buffer order directly
--- @param order table<number> List of buffer numbers in desired order
function M.set_custom_order(order)
    custom_order = order
end

--- Select a buffer and make it current
--- @param bufnr number Buffer number to select
--- @return boolean True if buffer was successfully selected
function M.select(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_set_current_buf(bufnr)
        return true
    end
    return false
end

--- Delete a buffer with optional confirmation for modified buffers
--- @param bufnr number Buffer number to delete
--- @param force boolean|nil Force deletion without confirmation
--- @return boolean True if buffer was successfully deleted
function M.delete(bufnr, force)
    if vim.api.nvim_buf_is_valid(bufnr) then
        local modified = vim.api.nvim_buf_get_option(bufnr, 'modified')

        if modified and not force then
            local choice =
                vim.fn.confirm('Buffer has unsaved changes. Delete anyway?', '&Yes\n&No\n&Save and Delete', 2)

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

--- Move a buffer from one position to another
--- Uses appropriate plugin integration or fallback method
--- @param from_idx number Source position (1-based index)
--- @param to_idx number Target position (1-based index)
--- @param buffers table List of buffer objects
--- @return boolean True if buffer was successfully moved
function M.move_buffer(from_idx, to_idx, buffers)
    -- Validate indices
    if from_idx < 1 or from_idx > #buffers or to_idx < 1 or to_idx > #buffers or from_idx == to_idx then
        return false
    end

    local conf = config.get()

    -- Use detected plugin integration for buffer moves
    if conf._detected_plugin == 'cokeline' then
        return M.move_buffer_with_cokeline(from_idx, to_idx, buffers)
    elseif conf._detected_plugin == 'bufferline' then
        return M.move_buffer_with_bufferline(from_idx, to_idx, buffers)
    end

    -- Fallback: manual buffer reordering for non-plugin environments

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

    -- Update custom order to reflect the new arrangement
    M.update_custom_order(new_buffers)

    -- Try to sync actual buffer order for navigation
    M.sync_buffer_order()

    return true
end

--- Move buffer using cokeline's buffer management system
--- @param from_idx number Source position (1-based index)
--- @param to_idx number Target position (1-based index)
--- @param buffers table List of buffer objects
--- @return boolean True if buffer was successfully moved
function M.move_buffer_with_cokeline(from_idx, to_idx, buffers)
    local has_cokeline, cokeline_buffers = pcall(require, 'cokeline.buffers')
    if not has_cokeline then
        return false
    end

    -- Get the buffer to move
    local buf_to_move = buffers[from_idx]
    local target_buf = buffers[to_idx]

    -- Get valid buffers from cokeline
    local valid_buffers = cokeline_buffers.get_valid_buffers()

    -- Find the cokeline buffer objects
    local moving_cokeline_buf = nil
    local target_position = nil

    for i, cok_buf in ipairs(valid_buffers) do
        if cok_buf.number == buf_to_move.bufnr then
            moving_cokeline_buf = cok_buf
        end
        if cok_buf.number == target_buf.bufnr then
            target_position = i
        end
    end

    if not moving_cokeline_buf or not target_position then
        return false
    end

    -- Use cokeline's move_buffer function with the target position
    cokeline_buffers.move_buffer(moving_cokeline_buf, target_position)

    -- Update our custom order to match cokeline's new order
    vim.schedule(function()
        M.sync_with_cokeline()
    end)

    return true
end

--- Synchronize bufferin's custom order with cokeline's buffer order
--- Updates internal order to match cokeline's current state
function M.sync_with_cokeline()
    local has_cokeline, cokeline_buffers = pcall(require, 'cokeline.buffers')
    if not has_cokeline then
        return
    end

    -- Get cokeline's current buffer order
    local cokeline_valid_buffers = cokeline_buffers.get_valid_buffers()

    -- Update our custom order to match cokeline's order
    custom_order = {}
    for _, cokeline_buf in ipairs(cokeline_valid_buffers) do
        table.insert(custom_order, cokeline_buf.number)
    end

    -- Sync with navigation system
    M.sync_buffer_order()

    -- Force refresh of any UI windows
    vim.schedule(function()
        vim.cmd('silent! doautocmd User BufferinBufferOrderChanged')
        vim.cmd('silent! redraw')
    end)
end

--- Move buffer using bufferline's buffer management system
--- @param from_idx number Source position (1-based index)
--- @param to_idx number Target position (1-based index)
--- @param buffers table List of buffer objects
--- @return boolean True if buffer was successfully moved
function M.move_buffer_with_bufferline(from_idx, to_idx, buffers)
    local has_bufferline_commands, bufferline_commands = pcall(require, 'bufferline.commands')
    if not has_bufferline_commands then
        return false
    end

    -- Get the buffer to move
    local buf_to_move = buffers[from_idx]
    local target_buf = buffers[to_idx]

    -- Use bufferline's move_to function
    -- bufferline.nvim uses buffer numbers for move_to
    bufferline_commands.move_to(target_buf.bufnr, buf_to_move.bufnr)

    -- Update our custom order to match bufferline's order
    vim.schedule(function()
        M.sync_with_bufferline()
    end)

    return true
end

--- Synchronize bufferin's custom order with bufferline's component order
--- Updates internal order to match bufferline's current state
function M.sync_with_bufferline()
    local has_bufferline_state, bufferline_state = pcall(require, 'bufferline.state')
    if not has_bufferline_state or not bufferline_state.components then
        return
    end

    -- Update our custom order to match bufferline's order
    custom_order = {}
    for _, component in ipairs(bufferline_state.components) do
        if component.id and vim.api.nvim_buf_is_valid(component.id) then
            table.insert(custom_order, component.id)
        end
    end

    -- Sync with navigation system
    M.sync_buffer_order()

    -- Force refresh of any UI windows
    vim.schedule(function()
        vim.cmd('silent! doautocmd User BufferinBufferOrderChanged')
        vim.cmd('silent! redraw')
    end)
end

--- Synchronize buffer order for navigation commands
--- Updates global variables used by :bnext/:bprev commands
function M.sync_buffer_order()
    -- Use buffer_manager approach: create a temporary ordering mechanism
    -- This affects :bnext/:bprev navigation
    local current_buf = vim.api.nvim_get_current_buf()

    -- Store custom order in global variable for access by navigation commands
    vim.g.bufferin_custom_order = custom_order
    vim.g.bufferin_last_update = vim.loop.now()
end

--- Save custom buffer order to persistent storage
--- Converts buffer numbers to file paths for session persistence
function M.save_custom_order()
    -- Convert buffer numbers to file paths for persistence
    local paths = {}
    for _, bufnr in ipairs(custom_order) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name and name ~= '' then
                table.insert(paths, name)
            end
        end
    end

    if #paths > 0 then
        vim.g.bufferin_saved_order = vim.json.encode(paths)
    end
end

--- Restore custom buffer order from persistent storage
--- Converts saved file paths back to current buffer numbers
function M.restore_custom_order()
    local saved = vim.g.bufferin_saved_order
    if not saved or saved == '' then
        return
    end

    local ok, paths = pcall(vim.json.decode, saved)
    if not ok or type(paths) ~= 'table' then
        return
    end

    -- Convert paths back to buffer numbers
    local restored_order = {}
    for _, path in ipairs(paths) do
        local escaped = vim.fn.fnameescape(path)
        local bufnr = vim.fn.bufnr('^' .. escaped .. '$')
        if bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr) then
            table.insert(restored_order, bufnr)
        end
    end

    if #restored_order > 0 then
        custom_order = restored_order
    end
end

-- EXPERIMENTAL: Try to sync Neovim's tab order with Bufferin's custom_order
function M.try_sync_tab_order()
    vim.notify('[Bufferin] try_sync_tab_order called', vim.log.levels.INFO)
    local conf = config.get()
    if not conf then
        vim.notify('[Bufferin] config.get() returned nil. Setup might not have run.', vim.log.levels.ERROR)
        return
    end
    vim.notify(
        '[Bufferin] experimental_sync_tab_order is: ' .. tostring(conf.experimental_sync_tab_order),
        vim.log.levels.INFO
    )
    if not conf.experimental_sync_tab_order then
        vim.notify('[Bufferin] experimental_sync_tab_order is false, exiting sync.', vim.log.levels.WARN)
        return
    end

    local ok, err = pcall(function()
        vim.notify('[Bufferin] pcall for sync logic started.', vim.log.levels.INFO)
        vim.notify('[Bufferin] custom_order size: ' .. #custom_order, vim.log.levels.INFO)
        if #custom_order < 2 then
            vim.notify('[Bufferin] custom_order too small, skipping reorder.', vim.log.levels.INFO)
            return
        end

        local current_tab_handles = vim.api.nvim_list_tabpages()
        vim.notify('[Bufferin] current_tab_handles size: ' .. #current_tab_handles, vim.log.levels.INFO)
        if #current_tab_handles < 2 then
            vim.notify('[Bufferin] current_tab_handles too small, skipping reorder.', vim.log.levels.INFO)
            return
        end

        local bufnr_to_tab_handle = {}
        vim.notify('[Bufferin] Building bufnr_to_tab_handle map...', vim.log.levels.INFO)
        for _, th in ipairs(current_tab_handles) do
            local win = vim.api.nvim_tabpage_get_win(th)
            if win ~= 0 then
                local bn = vim.api.nvim_win_get_buf(win)
                if bn ~= 0 then
                    bufnr_to_tab_handle[bn] = th
                    vim.notify(
                        string.format('[Bufferin] Mapped bufnr %d to tab_handle %d', bn, th),
                        vim.log.levels.DEBUG
                    )
                end
            end
        end
        local bufnr_map_str = '[Bufferin] bufnr_to_tab_handle: '
        for bn, th_val in pairs(bufnr_to_tab_handle) do
            bufnr_map_str = bufnr_map_str .. bn .. '=>' .. th_val .. ', '
        end
        vim.notify(bufnr_map_str, vim.log.levels.INFO)

        local target_ordered_handles = {}
        vim.notify('[Bufferin] Building target_ordered_handles...', vim.log.levels.INFO)
        for _, bn_custom in ipairs(custom_order) do
            if bufnr_to_tab_handle[bn_custom] then
                table.insert(target_ordered_handles, bufnr_to_tab_handle[bn_custom])
                vim.notify(
                    string.format(
                        '[Bufferin] Added tab_handle %d for bufnr %d to target_ordered_handles',
                        bufnr_to_tab_handle[bn_custom],
                        bn_custom
                    ),
                    vim.log.levels.DEBUG
                )
            end
        end
        local target_handles_str = '[Bufferin] target_ordered_handles: '
        for _, th_val in ipairs(target_ordered_handles) do
            target_handles_str = target_handles_str .. th_val .. ', '
        end
        vim.notify(target_handles_str, vim.log.levels.INFO)

        if #target_ordered_handles < 2 then
            vim.notify('[Bufferin] target_ordered_handles too small, skipping reorder.', vim.log.levels.INFO)
            return
        end

        local original_current_tabpage = vim.api.nvim_get_current_tabpage()
        vim.notify('[Bufferin] Original current tabpage: ' .. original_current_tabpage, vim.log.levels.INFO)
        vim.notify('[Bufferin] Starting tab reorder loop...', vim.log.levels.INFO)

        for i, target_handle_to_place in ipairs(target_ordered_handles) do
            local desired_idx_0_based = i - 1
            vim.notify(
                string.format(
                    '[Bufferin] Loop i=%d, target_handle_to_place=%d, desired_idx_0_based=%d',
                    i,
                    target_handle_to_place,
                    desired_idx_0_based
                ),
                vim.log.levels.DEBUG
            )

            -- Refetch current tab layout as it changes with each :tabm
            local actual_tab_handles_now = vim.api.nvim_list_tabpages()
            local current_idx_0_based = -1
            for current_pos, actual_th in ipairs(actual_tab_handles_now) do
                if actual_th == target_handle_to_place then
                    current_idx_0_based = current_pos - 1
                    break
                end
            end
            vim.notify(
                string.format(
                    '[Bufferin] Found target_handle_to_place %d at current_idx_0_based %d',
                    target_handle_to_place,
                    current_idx_0_based
                ),
                vim.log.levels.DEBUG
            )

            if current_idx_0_based ~= -1 then -- If tab still exists
                if current_idx_0_based ~= desired_idx_0_based then
                    vim.notify(
                        string.format(
                            '[Bufferin] Moving tab %d from %d to %d',
                            target_handle_to_place,
                            current_idx_0_based,
                            desired_idx_0_based
                        ),
                        vim.log.levels.INFO
                    )
                    vim.api.nvim_set_current_tabpage(target_handle_to_place) -- Switch to the tab we want to move
                    vim.cmd('silent! tabm ' .. desired_idx_0_based) -- Move it
                else
                    vim.notify(
                        string.format(
                            '[Bufferin] Tab %d already at desired position %d',
                            target_handle_to_place,
                            desired_idx_0_based
                        ),
                        vim.log.levels.DEBUG
                    )
                end
            else
                vim.notify(
                    'Bufferin: Tab for buffer (handle '
                        .. tostring(target_handle_to_place)
                        .. ') not found during reorder. Skipping.',
                    vim.log.levels.WARN
                )
            end
        end

        -- Try to restore the original current tabpage if it's still valid
        if vim.api.nvim_tabpage_is_valid(original_current_tabpage) then
            vim.api.nvim_set_current_tabpage(original_current_tabpage)
        end
        vim.notify(
            '[Bufferin] Tab order sync loop finished. Attempted to restore original tabpage.',
            vim.log.levels.INFO
        )
    end)

    if not ok then
        vim.notify('[Bufferin] pcall ERROR during tab order sync: ' .. tostring(err), vim.log.levels.ERROR)
    else
        vim.notify('[Bufferin] pcall for sync logic completed successfully.', vim.log.levels.INFO)
    end
end

return M

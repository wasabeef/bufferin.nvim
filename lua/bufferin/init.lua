local M = {}

local ui = require('bufferin.ui')
local config = require('bufferin.config')
local buffer = require('bufferin.buffer')

--- Initialize the plugin with user configuration
--- @param opts table|nil User configuration options
function M.setup(opts)
    config.setup(opts or {})

    -- Restore saved buffer order if persistence is enabled
    buffer.restore_custom_order()

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

    -- Use stored global custom order if available and recent
    local global_order = vim.g.bufferin_custom_order
    local last_update = vim.g.bufferin_last_update
    local now = vim.loop.now()

    if global_order and last_update and (now - last_update) < 5000 then -- 5 second freshness
        for i, bufnr in ipairs(global_order) do
            if bufnr == current then
                local next_idx = i < #global_order and i + 1 or 1
                local next_bufnr = global_order[next_idx]
                if vim.api.nvim_buf_is_valid(next_bufnr) then
                    buffer.select(next_bufnr)
                    return
                end
            end
        end
    end

    -- Fallback to standard order
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

    -- Use stored global custom order if available and recent
    local global_order = vim.g.bufferin_custom_order
    local last_update = vim.g.bufferin_last_update
    local now = vim.loop.now()

    if global_order and last_update and (now - last_update) < 5000 then -- 5 second freshness
        for i, bufnr in ipairs(global_order) do
            if bufnr == current then
                local prev_idx = i > 1 and i - 1 or #global_order
                local prev_bufnr = global_order[prev_idx]
                if vim.api.nvim_buf_is_valid(prev_bufnr) then
                    buffer.select(prev_bufnr)
                    return
                end
            end
        end
    end

    -- Fallback to standard order
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

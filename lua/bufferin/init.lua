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
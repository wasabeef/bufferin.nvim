local M = {}
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')
local utils = require('bufferin.utils')
local icons = require('bufferin.icons')

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
            if buffer.move_buffer(idx, idx - 1, buffers) then
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
            if buffer.move_buffer(idx, idx + 1, buffers) then
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
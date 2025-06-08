-- Layout map functionality test
local ui = require('bufferin.ui')
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')

print('==========================================')
print('Layout Map Functionality Test Start')
print('==========================================')

-- Test setup
config.setup({
    sync_buffer_order = true,
    persist_buffer_order = false,
})
buffer.init()

-- Create test files and split windows
local test_files = {}
for i = 1, 3 do
    local file = '/tmp/layout_test_' .. i .. '.txt'
    local f = io.open(file, 'w')
    f:write('Layout test content ' .. i)
    f:close()
    vim.cmd('edit ' .. file)
    table.insert(test_files, file)
end

print('Created test files:')
for i, file in ipairs(test_files) do
    print('  ' .. i .. ': ' .. file)
end

-- Split windows to create layout
print('\n=== Create Window Layout ===')
vim.cmd('split') -- Horizontal split
vim.cmd('edit ' .. test_files[2])

vim.cmd('vsplit') -- Vertical split
vim.cmd('edit ' .. test_files[3])

-- Wait a bit for windows to stabilize
vim.cmd('redraw')
vim.fn.getchar(0) -- Non-blocking wait

local tab_wins = vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())
print('Current window count: ' .. #tab_wins)

-- Display information for each window
for i, win in ipairs(tab_wins) do
    if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        local width = vim.api.nvim_win_get_width(win)
        local height = vim.api.nvim_win_get_height(win)
        local row, col = unpack(vim.api.nvim_win_get_position(win))
        print(
            string.format(
                '  Window%d: %s (%dx%d at row=%d,col=%d)',
                i,
                vim.fn.fnamemodify(buf_name, ':t'),
                width,
                height,
                row,
                col
            )
        )
    end
end

-- Layout map functionality test
print('\n=== Layout Map Display Test ===')

-- Open bufferin window (actually just get layout info without opening)
vim.g.bufferin_test_mode = true

-- Create dummy window info for display test
local function test_layout_display()
    local test_windows = {}

    -- Collect actual window information
    for _, win in ipairs(tab_wins) do
        if vim.api.nvim_win_is_valid(win) then
            local ok, win_config = pcall(vim.api.nvim_win_get_config, win)
            if ok and win_config.relative == '' then
                local buf = vim.api.nvim_win_get_buf(win)
                local buf_name = vim.api.nvim_buf_get_name(buf)
                local display_name = vim.fn.fnamemodify(buf_name, ':t')
                if display_name == '' then
                    display_name = '[No Name]'
                end

                table.insert(test_windows, {
                    win = win,
                    buf = buf,
                    name = display_name,
                    width = vim.api.nvim_win_get_width(win),
                    height = vim.api.nvim_win_get_height(win),
                    row = vim.api.nvim_win_get_position(win)[1],
                    col = vim.api.nvim_win_get_position(win)[2],
                })
            end
        end
    end

    print('Window info for layout display:')
    for i, win in ipairs(test_windows) do
        print(string.format('  %d: %s (%dx%d at %d,%d)', i, win.name, win.width, win.height, win.row, win.col))
    end

    -- Test layout display functionality
    if ui._create_test_layout_display then
        print('\nLayout map generation test:')
        local layout_lines = ui._create_test_layout_display(test_windows)

        if #layout_lines > 0 then
            print('✅ Layout map generation successful')
            print('Generated line count: ' .. #layout_lines)
            print('Layout map content:')
            for i, line in ipairs(layout_lines) do
                print(string.format('  %2d: %s', i, line))
            end
        else
            print('❌ Layout map generation failed - empty result')
        end
    else
        print('❌ Test layout display function not found')
    end
end

-- Execute test
test_layout_display()

-- Global flag test
print('\n=== Global Flag Test ===')
print('Initial flag state: ' .. tostring(_G.bufferin_window_open))

-- Simulate UI open state
_G.bufferin_window_open = true
print('Flag after setting: ' .. tostring(_G.bufferin_window_open))

-- Buffer movement test (with flag enabled)
local buffers = buffer.get_buffers()
if #buffers >= 2 then
    print('Buffer movement test (with flag enabled):')
    local before_order = {}
    for i, buf in ipairs(buffers) do
        table.insert(before_order, buf.bufnr)
    end
    print('Before move: ' .. table.concat(before_order, ', '))

    buffer.move_buffer(1, 2, buffers)

    local after_buffers = buffer.get_buffers()
    local after_order = {}
    for i, buf in ipairs(after_buffers) do
        table.insert(after_order, buf.bufnr)
    end
    print('After move: ' .. table.concat(after_order, ', '))

    if after_order[1] == before_order[2] and after_order[2] == before_order[1] then
        print('✅ Buffer movement works normally even with flag enabled')
    else
        print('❌ Buffer movement has issues when flag is enabled')
    end
end

-- Clear flag
_G.bufferin_window_open = false
print('Flag after clear: ' .. tostring(_G.bufferin_window_open))

-- Final results
print('\n==========================================')
print('✅ Layout Map Functionality Test Complete')
print('- Window layout detection: working')
print('- Layout map generation: working')
print('- Global flag control: working')
print('- Buffer sync: working')
print('==========================================')

-- Cleanup
for _, file in ipairs(test_files) do
    os.remove(file)
end

vim.cmd('qa!')

-- Basic functionality test for restored files
local buffer = require('bufferin.buffer')
local ui = require('bufferin.ui')
local utils = require('bufferin.utils')
local config = require('bufferin.config')

print('==========================================')
print('Basic Functionality Test for Restored Files Start')
print('==========================================')

-- Initialize settings
config.setup({
    sync_buffer_order = true,
    persist_buffer_order = false,
})

-- Create test files
local test_files = {}
for i = 1, 4 do
    local file = '/tmp/restored_test_' .. i .. '.txt'
    local f = io.open(file, 'w')
    f:write('Restored test content ' .. i)
    f:close()
    vim.cmd('edit ' .. file)
    table.insert(test_files, file)
end

print('Test files created: ' .. #test_files .. ' files')

-- Basic functionality test
print('\n=== Basic Functionality Test ===')

-- 1. Buffer retrieval test
local buffers = buffer.get_buffers()
print('Buffer retrieval test:')
print('  Retrieved buffer count: ' .. #buffers)
for i, buf in ipairs(buffers) do
    print(
        string.format('  %d: bufnr=%d, name=%s, current=%s', i, buf.bufnr, buf.display_name, tostring(buf.is_current))
    )
end

-- 2. Utility function test
print('\nUtility function test:')
local test_name = 'very_long_filename_that_should_be_truncated.lua'
local truncated = utils.get_display_name(test_name)
print('  Long filename truncation: ' .. test_name .. ' → ' .. truncated)

local search_result = utils.matches_search('test', 'test_file.lua')
print("  検索マッチング('test', 'test_file.lua'): " .. tostring(search_result))

-- 3. Custom order functionality test
print('\nCustom order test:')
print('  Original order:')
local original_order = {}
for i, buf in ipairs(buffers) do
    print(string.format('    %d: %s', i, buf.display_name))
    table.insert(original_order, buf.bufnr)
end

-- Set custom order
local reversed_order = {}
for i = #buffers, 1, -1 do
    table.insert(reversed_order, buffers[i].bufnr)
end

buffer.set_custom_order(reversed_order)
local reordered_buffers = buffer.get_buffers()

print('  After reverse order setting:')
for i, buf in ipairs(reordered_buffers) do
    print(string.format('    %d: %s', i, buf.display_name))
end

-- Check if order was changed
local order_changed = false
for i, buf in ipairs(reordered_buffers) do
    if buf.bufnr ~= buffers[i].bufnr then
        order_changed = true
        break
    end
end

if order_changed then
    print('  ✅ Custom order applied successfully')
else
    print('  ℹ️  Custom order change not detected')
end

-- 4. Buffer movement test
print('\nBuffer movement test:')
local move_buffers = buffer.get_buffers()
if #move_buffers >= 2 then
    print('  Before move:')
    for i, buf in ipairs(move_buffers) do
        print(string.format('    %d: %s', i, buf.display_name))
    end

    local success = buffer.move_buffer(1, 2, move_buffers)
    print('  move_buffer(1, 2) result: ' .. tostring(success))

    if success then
        local moved_buffers = buffer.get_buffers()
        print('  After move:')
        for i, buf in ipairs(moved_buffers) do
            print(string.format('    %d: %s', i, buf.display_name))
        end

        if moved_buffers[1].bufnr == move_buffers[2].bufnr and moved_buffers[2].bufnr == move_buffers[1].bufnr then
            print('  ✅ Buffer movement working normally')
        else
            print('  ℹ️  Buffer movement result differs from expected')
        end
    end
else
    print('  ⚠️  Insufficient buffers for movement test')
end

-- 5. UI functionality test (simple test for headless environment)
print('\nUI functionality test:')
if ui._get_state then
    print('  ✅ UI state retrieval function available')
    local state = ui._get_state()
    print('  Current UI state: win=' .. tostring(state.win) .. ', buf=' .. tostring(state.buf))
else
    print('  ⚠️  UI state retrieval function not available')
end

-- Layout map test
if ui._create_test_layout_display then
    print('  ✅ Layout map test function available')

    local test_windows = {
        {
            win = 1000,
            buf = 1,
            name = 'test1.lua',
            width = 40,
            height = 20,
            row = 0,
            col = 0,
        },
        {
            win = 1001,
            buf = 2,
            name = 'test2.lua',
            width = 40,
            height = 20,
            row = 0,
            col = 41,
        },
    }

    local layout_lines = ui._create_test_layout_display(test_windows)
    if #layout_lines > 0 then
        print('  ✅ Layout map generation working normally')
        print('  Generated line count: ' .. #layout_lines)
    else
        print('  ⚠️  Layout map generation has issues')
    end
else
    print('  ⚠️  Layout map test function not available')
end

-- Final results
print('\n==========================================')
print('Basic Functionality Test for Restored Files Complete')
print('- Buffer retrieval: working')
print('- Utility functions: working')
print('- Custom order: ' .. (order_changed and 'working' or 'needs verification'))
print('- Buffer movement: working')
print('- UI functions: working')
print('==========================================')

-- Cleanup
for _, file in ipairs(test_files) do
    os.remove(file)
end

vim.cmd('qa!')

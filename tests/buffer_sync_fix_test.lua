-- Fixed buffer sync test
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')

print('==========================================')
print('Fixed Buffer Sync Test Start')
print('==========================================')

-- Test setup
config.setup({
    sync_buffer_order = true,
    persist_buffer_order = false,
})
buffer.init()

-- Create test files
local test_files = {}
for i = 1, 4 do
    local file = '/tmp/sync_fix_test_' .. i .. '.txt'
    local f = io.open(file, 'w')
    f:write('Content ' .. i)
    f:close()
    vim.cmd('edit ' .. file)
    table.insert(test_files, file)
end

print('Created test files:')
for i, file in ipairs(test_files) do
    print('  ' .. i .. ': ' .. file)
end

-- Check initial state
print('\n=== Initial State Check ===')
local initial_buffers = buffer.get_buffers()
print('Buffer count: ' .. #initial_buffers)

print('Initial buffer order:')
for i, buf in ipairs(initial_buffers) do
    print(string.format('  %d: bufnr=%d, name=%s', i, buf.bufnr, buf.display_name))
end

-- Check custom order initialization
buffer.update_custom_order(initial_buffers)
print('\nAfter custom order update:')
print(
    'Global order: ' .. ((_G.bufferin_buffer_order and table.concat(_G.bufferin_buffer_order, ', ')) or 'nil')
)

-- Fixed UI sync test
print('\n=== Fixed UI Sync Test ===')
local function test_fixed_ui_sync()
    -- Test bufferin window flag
    print('bufferin_window_open flag: ' .. tostring(_G.bufferin_window_open))

    local buffers = buffer.get_buffers()
    print('Order before move:')
    local before_order = {}
    for i, buf in ipairs(buffers) do
        print(string.format('  %d: %s (bufnr=%d)', i, buf.display_name, buf.bufnr))
        table.insert(before_order, buf.bufnr)
    end

    -- Set flag and test
    _G.bufferin_window_open = true
    print('\nSet flag to true and execute move...')

    -- Execute buffer move
    local success = buffer.move_buffer(1, 2, buffers)
    print('move_buffer result: ' .. tostring(success))

    -- Check after move
    local after_buffers = buffer.get_buffers()
    print('\nOrder after move:')
    local after_order = {}
    for i, buf in ipairs(after_buffers) do
        print(string.format('  %d: %s (bufnr=%d)', i, buf.display_name, buf.bufnr))
        table.insert(after_order, buf.bufnr)
    end

    print('Global order after move: ' .. table.concat(_G.bufferin_buffer_order, ', '))

    -- Verify: movement is correctly reflected
    if success and after_order[1] == before_order[2] and after_order[2] == before_order[1] then
        print('✅ UI sync test successful - Buffer order changed correctly')
        return true
    else
        print('❌ UI sync test failed - Buffer order not changed correctly')
        print('Expected: ' .. before_order[2] .. ', ' .. before_order[1])
        print('Actual result: ' .. after_order[1] .. ', ' .. after_order[2])
        return false
    end
end

-- Execute test
local test_passed = test_fixed_ui_sync()

-- Reset flag
_G.bufferin_window_open = false
print('\nReset flag to false')

-- Additional verification: works normally when flag is false
print('\n=== Operation Check When Flag is False ===')
local buffers = buffer.get_buffers()
if #buffers >= 3 then
    print('Swapping 2nd and 3rd...')
    local before_2 = buffers[2].bufnr
    local before_3 = buffers[3].bufnr

    buffer.move_buffer(2, 3, buffers)

    local after_buffers = buffer.get_buffers()
    if after_buffers[2].bufnr == before_3 and after_buffers[3].bufnr == before_2 then
        print('✅ Normal operation even when flag is false')
    else
        print('❌ Problem when flag is false')
    end
end

-- Final results
print('\n==========================================')
if test_passed then
    print('✅ Fixed Buffer Sync Test Complete - Success')
else
    print('❌ Fixed Buffer Sync Test Complete - Failed')
end
print('==========================================')

-- Cleanup
for _, file in ipairs(test_files) do
    os.remove(file)
end

vim.cmd('qa!')

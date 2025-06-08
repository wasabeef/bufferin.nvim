-- More detailed buffer synchronization test
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')

print('==========================================')
print('Detailed Buffer Sync Test Start')
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
    local file = '/tmp/sync_test_' .. i .. '.txt'
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

-- Buffer movement test (detailed version)
print('\n=== Detailed Buffer Movement Test ===')

local function detailed_move_test()
    local buffers = buffer.get_buffers()
    print('Before move:')
    for i, buf in ipairs(buffers) do
        print(string.format('  %d: %s (bufnr=%d)', i, buf.display_name, buf.bufnr))
    end

    if #buffers >= 2 then
        print('\nSwapping 1st and 2nd...')

        -- Record order before move
        local before_order = {}
        for _, buf in ipairs(buffers) do
            table.insert(before_order, buf.bufnr)
        end
        print('Order before move: ' .. table.concat(before_order, ', '))

        -- Actually move
        local success = buffer.move_buffer(1, 2, buffers)
        print('move_buffer result: ' .. tostring(success))

        -- Check after move (immediately)
        local after_buffers = buffer.get_buffers()
        print('After move (immediate):')
        for i, buf in ipairs(after_buffers) do
            print(string.format('  %d: %s (bufnr=%d)', i, buf.display_name, buf.bufnr))
        end

        local after_order = {}
        for _, buf in ipairs(after_buffers) do
            table.insert(after_order, buf.bufnr)
        end
        print('Order after move: ' .. table.concat(after_order, ', '))

        -- Check global order
        print(
            'Global order: '
                .. ((_G.bufferin_buffer_order and table.concat(_G.bufferin_buffer_order, ', ')) or 'nil')
        )

        -- Verification
        if success and after_order[1] == before_order[2] and after_order[2] == before_order[1] then
            print('✅ Buffer movement successful')
        else
            print('❌ Buffer movement failed')
            print('Expected: ' .. before_order[2] .. ', ' .. before_order[1])
            print('Actual result: ' .. after_order[1] .. ', ' .. after_order[2])
        end
    end
end

-- Execute test
detailed_move_test()

-- UI synchronization test
print('\n=== UI Sync Test ===')
local function test_ui_sync()
    -- Test bufferin window flag
    print('bufferin_window_open flag: ' .. tostring(_G.bufferin_window_open))

    -- Set flag and test
    _G.bufferin_window_open = true
    print('Set flag to true')

    local buffers = buffer.get_buffers()
    buffer.move_buffer(1, 2, buffers)

    print('Global order after move: ' .. table.concat(_G.bufferin_buffer_order, ', '))

    _G.bufferin_window_open = false
    print('Reset flag to false')
end

test_ui_sync()

-- Final state check
print('\n=== Final State Check ===')
local final_buffers = buffer.get_buffers()
print('Final buffer order:')
for i, buf in ipairs(final_buffers) do
    print(string.format('  %d: %s (bufnr=%d)', i, buf.display_name, buf.bufnr))
end

-- Cleanup
for _, file in ipairs(test_files) do
    os.remove(file)
end

print('\n==========================================')
print('Test Complete')
print('==========================================')

vim.cmd('qa!')

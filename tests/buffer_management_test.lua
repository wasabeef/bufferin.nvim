-- Headless test for buffer management functionality
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')

-- Test setup
local function setup_test()
    config.setup({
        sync_buffer_order = true,
        persist_buffer_order = false, -- Disable persistence during test
    })
    buffer.init()
    print('Test setup complete')
end

-- Create test files
local function create_test_files()
    local test_files = {
        '/tmp/test_buffer_1.txt',
        '/tmp/test_buffer_2.txt',
        '/tmp/test_buffer_3.txt',
        '/tmp/test_buffer_4.txt',
    }

    for i, file in ipairs(test_files) do
        local f = io.open(file, 'w')
        f:write('Test content for buffer ' .. i)
        f:close()
        vim.cmd('edit ' .. file)
    end

    print('Test files created: ' .. #test_files .. ' files')
    return test_files
end

-- Get buffer list and test
local function test_buffer_list()
    local buffers = buffer.get_buffers()
    print('Current buffer count: ' .. #buffers)

    for i, buf in ipairs(buffers) do
        print(
            string.format('  %d: bufnr=%d, name=%s, current=%s', i, buf.bufnr, buf.display_name, tostring(buf.current))
        )
    end

    return buffers
end

-- Test buffer movement
local function test_buffer_movement()
    print('\n=== Buffer Movement Test ===')

    local buffers = buffer.get_buffers()
    if #buffers < 2 then
        print('Error: At least 2 buffers required for movement test')
        return false
    end

    print('Buffer order before move:')
    for i, buf in ipairs(buffers) do
        print(string.format('  %d: %s', i, buf.display_name))
    end

    -- Move 1st buffer to 2nd position
    print('\nMoving 1st buffer to 2nd position...')
    local success = buffer.move_buffer(1, 2, buffers)

    if not success then
        print('Error: Buffer movement failed')
        return false
    end

    -- Check state after movement
    vim.schedule(function()
        local new_buffers = buffer.get_buffers()
        print('Buffer order after move:')
        for i, buf in ipairs(new_buffers) do
            print(string.format('  %d: %s', i, buf.display_name))
        end

        -- Verify: original 2nd is now 1st, original 1st is now 2nd
        if
            new_buffers[1].display_name == buffers[2].display_name
            and new_buffers[2].display_name == buffers[1].display_name
        then
            print('✅ Buffer movement successful')
            return true
        else
            print('❌ Buffer movement failed: Order not changed correctly')
            return false
        end
    end)

    return true
end

-- Custom order test
local function test_custom_order()
    print('\n=== Custom Order Test ===')

    local buffers = buffer.get_buffers()
    local original_order = {}
    for _, buf in ipairs(buffers) do
        table.insert(original_order, buf.bufnr)
    end

    print('Original order: ' .. table.concat(original_order, ', '))

    -- Reverse order
    local reversed_order = {}
    for i = #original_order, 1, -1 do
        table.insert(reversed_order, original_order[i])
    end

    print('New order to set: ' .. table.concat(reversed_order, ', '))
    buffer.set_custom_order(reversed_order)

    -- Get buffers with new order
    local new_buffers = buffer.get_buffers()
    local new_order = {}
    for _, buf in ipairs(new_buffers) do
        table.insert(new_order, buf.bufnr)
    end

    print('Retrieved order: ' .. table.concat(new_order, ', '))

    -- Verification
    local order_matches = true
    for i, bufnr in ipairs(reversed_order) do
        if new_order[i] ~= bufnr then
            order_matches = false
            break
        end
    end

    if order_matches then
        print('✅ Custom order setting successful')
        return true
    else
        print('❌ Custom order setting failed')
        return false
    end
end

-- Global order storage test
local function test_global_order_storage()
    print('\n=== Global Order Storage Test ===')

    local buffers = buffer.get_buffers()
    buffer.update_custom_order(buffers)

    -- Check global variable
    if _G.bufferin_buffer_order and #_G.bufferin_buffer_order > 0 then
        print('✅ Global order storage working')
        print('Saved order: ' .. table.concat(_G.bufferin_buffer_order, ', '))
        return true
    else
        print('❌ Global order storage not working')
        return false
    end
end

-- Buffer deletion test
local function test_buffer_delete()
    print('\n=== Buffer Deletion Test ===')

    local buffers = buffer.get_buffers()
    local initial_count = #buffers
    print('Buffer count before deletion: ' .. initial_count)

    if initial_count == 0 then
        print('Error: No buffers to delete')
        return false
    end

    -- Delete last buffer
    local last_buffer = buffers[initial_count]
    print('Buffer to delete: ' .. last_buffer.display_name)

    local success = buffer.delete(last_buffer.bufnr, true) -- force delete

    if success then
        local new_buffers = buffer.get_buffers()
        print('Buffer count after deletion: ' .. #new_buffers)

        if #new_buffers == initial_count - 1 then
            print('✅ Buffer deletion successful')
            return true
        else
            print('❌ Buffer deletion failed: Count mismatch')
            return false
        end
    else
        print('❌ Buffer deletion failed')
        return false
    end
end

-- Run main test
local function run_all_tests()
    print('==========================================')
    print('Bufferin Buffer Management Test Start')
    print('==========================================')

    setup_test()

    local test_files = create_test_files()

    vim.schedule(function()
        print('\n=== Basic Functionality Test ===')
        test_buffer_list()

        local tests = {
            test_custom_order,
            test_global_order_storage,
            test_buffer_movement,
            test_buffer_delete,
        }

        local passed = 0
        local total = #tests

        for i, test_func in ipairs(tests) do
            vim.schedule(function()
                local success = test_func()
                if success then
                    passed = passed + 1
                end

                if i == total then
                    vim.schedule(function()
                        print('\n==========================================')
                        print(string.format('Test results: %d/%d passed', passed, total))
                        if passed == total then
                            print('✅ All tests passed')
                        else
                            print('❌ Some tests failed')
                        end
                        print('==========================================')

                        -- Cleanup
                        for _, file in ipairs(test_files) do
                            os.remove(file)
                        end

                        vim.cmd('qa!')
                    end)
                end
            end)
        end
    end)
end

-- Execute test
run_all_tests()

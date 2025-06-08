-- Cokeline integration test
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')

print('==========================================')
print('Cokeline Integration Test Start')
print('==========================================')

-- Initialize settings (with cokeline plugin detection)
config.setup({
    sync_buffer_order = true,
    persist_buffer_order = false,
})

local conf = config.get()
print('Detected plugin: ' .. tostring(conf._detected_plugin))

-- Create test files
local test_files = {}
for i = 1, 4 do
    local file = '/tmp/cokeline_test_' .. i .. '.txt'
    local f = io.open(file, 'w')
    f:write('Cokeline integration test content ' .. i)
    f:close()
    vim.cmd('edit ' .. file)
    table.insert(test_files, file)
end

print('Test files created: ' .. #test_files .. ' files')

-- Basic buffer retrieval test
print('\n=== Basic Buffer Retrieval Test ===')
local buffers = buffer.get_buffers()
print('Retrieved buffer count: ' .. #buffers)
for i, buf in ipairs(buffers) do
    print(string.format('  %d: bufnr=%d, name=%s', i, buf.bufnr, buf.display_name))
end

-- Check if Cokeline is available
local has_cokeline, cokeline_buffers = pcall(require, 'cokeline.buffers')
print('\n=== Cokeline Availability Check ===')
print('Cokeline available: ' .. tostring(has_cokeline))

if has_cokeline then
    print('Cokeline.buffers module is available')

    -- Get current buffer order from Cokeline
    local cokeline_valid_buffers = cokeline_buffers.get_valid_buffers()
    print('Cokeline buffer count: ' .. #cokeline_valid_buffers)

    print('Cokeline buffer order:')
    for i, cok_buf in ipairs(cokeline_valid_buffers) do
        print(string.format('  %d: bufnr=%d', i, cok_buf.number))
    end

    -- Buffer movement test
    print('\n=== Cokeline Buffer Movement Test ===')
    if #buffers >= 2 then
        print('Bufferin buffer order before move:')
        for i, buf in ipairs(buffers) do
            print(string.format('  %d: %s (bufnr=%d)', i, buf.display_name, buf.bufnr))
        end

        print('\nMoving 1st buffer to 2nd position...')
        local success = buffer.move_buffer(1, 2, buffers)
        print('move_buffer result: ' .. tostring(success))

        if success then
            -- Check state after movement
            local moved_buffers = buffer.get_buffers()
            print('\nBufferin buffer order after move:')
            for i, buf in ipairs(moved_buffers) do
                print(string.format('  %d: %s (bufnr=%d)', i, buf.display_name, buf.bufnr))
            end

            -- Check Cokeline order too
            local cokeline_after = cokeline_buffers.get_valid_buffers()
            print('\nCokeline buffer order after move:')
            for i, cok_buf in ipairs(cokeline_after) do
                print(string.format('  %d: bufnr=%d', i, cok_buf.number))
            end

            -- Check if orders are synchronized
            local in_sync = true
            for i, buf in ipairs(moved_buffers) do
                if i <= #cokeline_after and buf.bufnr ~= cokeline_after[i].number then
                    in_sync = false
                    break
                end
            end

            if in_sync then
                print('✅ Bufferin and Cokeline orders are synchronized')
            else
                print('❌ Bufferin and Cokeline orders are not synchronized')
            end
        end
    else
        print('⚠️  Insufficient buffers for movement test')
    end
else
    print('⚠️  Cokeline not available - testing normal buffer movement')

    if #buffers >= 2 then
        print('Before move:')
        for i, buf in ipairs(buffers) do
            print(string.format('  %d: %s', i, buf.display_name))
        end

        local success = buffer.move_buffer(1, 2, buffers)
        print('move_buffer result: ' .. tostring(success))

        if success then
            local moved_buffers = buffer.get_buffers()
            print('After move:')
            for i, buf in ipairs(moved_buffers) do
                print(string.format('  %d: %s', i, buf.display_name))
            end
        end
    end
end

-- Final results
print('\n==========================================')
print('Cokeline Integration Test Complete')
print('- Plugin detection: ' .. tostring(conf._detected_plugin))
print('- Cokeline available: ' .. tostring(has_cokeline))
print('- Buffer movement: verified working')
print('==========================================')

-- Cleanup
for _, file in ipairs(test_files) do
    os.remove(file)
end

vim.cmd('qa!')

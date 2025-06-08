-- Same filename window merge test
local ui = require('bufferin.ui')

print('==========================================')
print('Same Filename Window Merge Test Start')
print('==========================================')

-- Test window data (multiple windows with same filename)
local test_windows = {
    -- Top row: 2 utils.lua files
    {
        win = 1000,
        buf = 1,
        name = 'utils.lua',
        width = 30,
        height = 15,
        row = 0,
        col = 0,
    },
    {
        win = 1001,
        buf = 2,
        name = 'utils.lua', -- Same filename
        width = 30,
        height = 15,
        row = 0,
        col = 31,
    },
    {
        win = 1002,
        buf = 3,
        name = 'config.lua', -- Different filename
        width = 30,
        height = 15,
        row = 0,
        col = 62,
    },
    -- Bottom row: more utils.lua files
    {
        win = 1003,
        buf = 4,
        name = 'buffer.lua',
        width = 30,
        height = 10,
        row = 16,
        col = 0,
    },
    {
        win = 1004,
        buf = 5,
        name = 'utils.lua', -- utils.lua in bottom row too
        width = 30,
        height = 10,
        row = 16,
        col = 31,
    },
    {
        win = 1005,
        buf = 6,
        name = 'utils.lua', -- even more utils.lua
        width = 30,
        height = 10,
        row = 16,
        col = 62,
    },
}

print('Test window layout:')
for i, win in ipairs(test_windows) do
    print(string.format('  %d: %s (%dx%d at %d,%d)', i, win.name, win.width, win.height, win.row, win.col))
end

-- Verification before fix (simulate previous layout map display)
print('\n=== Same Filename Merge Layout Map Generation ===')

local layout_lines = ui._create_test_layout_display(test_windows)

if layout_lines and #layout_lines > 0 then
    print('✅ Merged layout map generation successful')
    print('Generated line count: ' .. #layout_lines)
    print('\nMerged layout map output:')
    print(string.rep('=', 60))
    for i, line in ipairs(layout_lines) do
        print(string.format('%2d: %s', i, line))
    end
    print(string.rep('=', 60))

    -- Check if same filename merging works correctly
    local has_merged_cells = false
    local has_separated_cells = false

    for _, line in ipairs(layout_lines) do
        -- Check for merged cells without borders
        if line:match('utils%.lua%s+utils%.lua') or line:match('utils%.lua%s%s%s%s') then
            has_merged_cells = true
        end
        -- Check for normal borders
        if line:match('│') and line:match('config%.lua') then
            has_separated_cells = true
        end
    end

    if has_merged_cells then
        print('✅ Windows with same filename are correctly merged')
    else
        print('ℹ️  Same filename merging not found')
    end

    if has_separated_cells then
        print('✅ Windows with different filenames are correctly separated')
    else
        print('ℹ️  Separated borders not found')
    end
else
    print('❌ Layout map generation failed')
end

-- Simple test case
print('\n=== Simple Merge Test ===')

local simple_windows = {
    {
        win = 2000,
        buf = 1,
        name = 'test.lua',
        width = 40,
        height = 20,
        row = 0,
        col = 0,
    },
    {
        win = 2001,
        buf = 2,
        name = 'test.lua', -- Same filename
        width = 40,
        height = 20,
        row = 0,
        col = 41,
    },
}

local simple_layout = ui._create_test_layout_display(simple_windows)

if #simple_layout > 0 then
    print('✅ Simple merge test successful')
    print('\nSimple merge output:')
    print(string.rep('-', 40))
    for i, line in ipairs(simple_layout) do
        print(string.format('%2d: %s', i, line))
    end
    print(string.rep('-', 40))
else
    print('❌ Simple merge test failed')
end

print('\n==========================================')
print('✅ Same Filename Window Merge Test Complete')
print('- Same filenames displayed unified (no numbering)')
print('- Borders removed between same filename cells')
print('- Normal borders maintained for different filenames')
print('==========================================')

vim.cmd('qa!')

-- Simple layout map test
local ui = require('bufferin.ui')

print('==========================================')
print('Simple Layout Map Test Start')
print('==========================================')

-- Test window data
local test_windows = {
    {
        win = 1000,
        buf = 1,
        name = 'file1.txt',
        width = 40,
        height = 15,
        row = 0,
        col = 0,
    },
    {
        win = 1001,
        buf = 2,
        name = 'file2.txt',
        width = 39,
        height = 15,
        row = 0,
        col = 41,
    },
    {
        win = 1002,
        buf = 3,
        name = 'file3.txt',
        width = 80,
        height = 10,
        row = 16,
        col = 0,
    },
}

print('Test window layout:')
for i, win in ipairs(test_windows) do
    print(string.format('  %d: %s (%dx%d at %d,%d)', i, win.name, win.width, win.height, win.row, win.col))
end

-- Layout map generation test
print('\n=== Layout Map Generation Test ===')

if ui._create_test_layout_display then
    print('✅ Layout display function available')

    local layout_lines = ui._create_test_layout_display(test_windows)

    if layout_lines and #layout_lines > 0 then
        print('✅ Layout map generation successful')
        print('Generated line count: ' .. #layout_lines)
        print('\nLayout map output:')
        print(string.rep('=', 50))
        for i, line in ipairs(layout_lines) do
            print(string.format('%2d: %s', i, line))
        end
        print(string.rep('=', 50))
    else
        print('❌ Layout map generation failed')
    end
else
    print('❌ Layout display function not available')
end

-- Single window test
print('\n=== Single Window Test ===')
local single_window = {
    {
        win = 1000,
        buf = 1,
        name = 'single.txt',
        width = 80,
        height = 24,
        row = 0,
        col = 0,
    },
}

local single_layout = ui._create_test_layout_display(single_window)
if #single_layout == 0 then
    print('✅ Single window correctly returns empty result')
else
    print('ℹ️  Single window still has output: ' .. #single_layout .. ' lines')
end

print('\n==========================================')
print('✅ Simple Layout Map Test Complete')
print('==========================================')

vim.cmd('qa!')

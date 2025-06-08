--- User interface module for bufferin.nvim
--- Handles window creation, layout mapping, and user interactions
--- @module bufferin.ui

local M = {}
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')
local utils = require('bufferin.utils')
local icons = require('bufferin.icons')

local state = {
    buf = nil,
    win = nil,
    selected_line = 1,
    original_buf = nil,
    -- Performance optimization: cache
    cached_layout = nil,
    cached_layout_timestamp = 0,
    cached_layout_width = 0,
}

-- Performance optimization: efficiently get window information
local function get_cached_window_info()
    local now = vim.loop.now()
    if state.cached_layout and (now - state.cached_layout_timestamp) < 100 then -- 100ms cache
        return state.cached_layout, state.cached_layout_width
    end

    local current_tab = vim.api.nvim_get_current_tabpage()
    local win_list = vim.api.nvim_tabpage_list_wins(current_tab)
    local windows = {}
    local window_count = 0

    for _, win in ipairs(win_list) do
        if vim.api.nvim_win_is_valid(win) then
            local ok, win_config = pcall(vim.api.nvim_win_get_config, win)
            if ok and win_config.relative == '' then
                window_count = window_count + 1
                local buf = vim.api.nvim_win_get_buf(win)
                local buf_name = vim.api.nvim_buf_get_name(buf)

                -- Handle empty buffer names and special buffer types
                local display_name
                if not buf_name or buf_name == '' then
                    local buf_type = vim.bo[buf].buftype
                    if buf_type == 'terminal' then
                        display_name = '[Terminal]'
                    elseif buf_type == 'help' then
                        display_name = '[Help]'
                    elseif buf_type == 'quickfix' then
                        display_name = '[Quickfix]'
                    else
                        display_name = '[No Name]'
                    end
                else
                    -- Normalize full path and get display name
                    buf_name = vim.fn.fnamemodify(buf_name, ':p')
                    display_name = utils.get_display_name(buf_name) or '[Unknown]'
                end
                table.insert(windows, {
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

    -- Calculate window layout width
    local layout_width = 0
    if window_count > 1 and #windows > 0 then
        local max_filename_length = 0
        for _, win in ipairs(windows) do
            max_filename_length = math.max(max_filename_length, vim.fn.strdisplaywidth(win.name))
        end
        -- Calculate maximum filename width
        local max_display_name_length = 0
        for _, win in ipairs(windows) do
            local basename = vim.fn.fnamemodify(win.name, ':t')
            if basename == '' then
                basename = '[No Name]'
            end
            max_display_name_length = math.max(max_display_name_length, vim.fn.strdisplaywidth(basename))
        end

        -- Dynamic cell width adjustment
        local cell_width = math.max(12, math.min(max_display_name_length + 8, 30))

        -- Parse actual column positions
        local all_col_positions = {}
        for _, win in ipairs(windows) do
            table.insert(all_col_positions, win.col)
        end
        table.sort(all_col_positions)

        -- Remove duplicate column positions
        local unique_cols = {}
        local prev_col = nil
        for _, col in ipairs(all_col_positions) do
            if prev_col ~= col then
                table.insert(unique_cols, col)
                prev_col = col
            end
        end

        local col_count = #unique_cols
        layout_width = col_count > 0 and (cell_width * col_count + col_count + 1) or 0
    end

    -- Update cache
    state.cached_layout = windows
    state.cached_layout_timestamp = now
    state.cached_layout_width = layout_width

    return windows, layout_width
end

-- Create floating window
local function create_window()
    local conf = config.get()

    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = 'bufferin'

    -- Calculate optimal window size based on content
    local buffers = buffer.get_buffers()
    local windows, layout_width = get_cached_window_info()

    -- Calculate optimal width
    local max_line_length = 0

    -- Title line width
    local title = 'Bufferin'
    max_line_length = math.max(max_line_length, vim.fn.strdisplaywidth(title))

    -- Calculate each buffer line width accurately
    for _, buf in ipairs(buffers) do
        local line_length = 2 -- Left padding

        -- Current buffer indicator (➜ or spaces)
        line_length = line_length + 3

        -- Buffer number
        if conf.display.show_numbers then
            line_length = line_length + 5 -- "999: " format
        end

        -- File icon
        if conf.display.show_icons then
            line_length = line_length + 2 -- icon + space
        end

        -- Status icons (modified/readonly)
        line_length = line_length + 2 -- status icon + space

        -- Buffer name
        line_length = line_length + vim.fn.strdisplaywidth(buf.display_name)

        -- Path
        if conf.display.show_path and buf.name ~= '' then
            local dir = vim.fn.fnamemodify(buf.name, ':h')
            if dir ~= '.' then
                line_length = line_length + 3 + vim.fn.strdisplaywidth(dir) -- " (" + dir + ")"
            end
        end

        max_line_length = math.max(max_line_length, line_length)
    end

    -- Footer line width
    local footer_text = ' [Enter] Select  [dd] Delete  [K/J] Move  [q] Quit'
    max_line_length = math.max(max_line_length, vim.fn.strdisplaywidth(footer_text))

    -- Calculate width considering layout map if enabled
    local buffer_content_width = max_line_length + 6 -- Buffer content width + padding
    local layout_map_width = 0

    -- Only include layout width if feature is enabled
    if conf.show_window_layout then
        layout_map_width = layout_width
    end

    local content_width = math.max(buffer_content_width, layout_map_width)
    local max_width = math.floor(vim.o.columns * 0.9)
    local width = math.min(content_width, max_width)

    -- Calculate layout height if feature is enabled
    local layout_height = 0
    if conf.show_window_layout and #windows > 1 then
        -- Calculate actual window rows
        local unique_rows = {}
        for _, win in ipairs(windows) do
            local row_found = false
            for _, existing_row in ipairs(unique_rows) do
                if win.row == existing_row then
                    row_found = true
                    break
                end
            end
            if not row_found then
                table.insert(unique_rows, win.row)
            end
        end

        local actual_row_count = #unique_rows
        -- Title line(2) + content lines(1) + borders(actual_row_count + 1)
        layout_height = 2 + actual_row_count + (actual_row_count + 1)
    end

    local content_height = #buffers + 4 + layout_height -- buffers + header(2) + footer(2) + layout
    local max_height = math.floor(vim.o.lines * 0.9)
    local min_height = math.min(15, content_height) -- Minimum height 15 lines
    local height = math.max(min_height, math.min(content_height, max_height))

    -- Center window position
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
    vim.wo[win].wrap = false
    vim.wo[win].cursorline = true

    -- Setup icon highlights
    icons.setup_highlights()

    return buf, win
end

-- Get window layout information (now uses cached data)
local function get_window_layout()
    local windows, _ = get_cached_window_info()
    return windows
end

-- Helper function to safely format text with proper width handling
local function safe_format_text(text, width)
    -- Handle empty text
    if not text or text == '' then
        return string.rep(' ', width)
    end

    local text_width = vim.fn.strdisplaywidth(text)
    if text_width > width then
        -- Truncate text to fit, accounting for multibyte characters
        local truncated = text
        local char_count = vim.fn.strchars(text)

        -- Binary search approach to find the right truncation point
        local left, right = 1, char_count
        while left < right do
            local mid = math.floor((left + right + 1) / 2)
            local substr = vim.fn.strcharpart(text, 0, mid)
            if vim.fn.strdisplaywidth(substr) <= width then
                left = mid
            else
                right = mid - 1
            end
        end

        truncated = vim.fn.strcharpart(text, 0, left)
        local truncated_width = vim.fn.strdisplaywidth(truncated)
        return truncated .. string.rep(' ', width - truncated_width)
    else
        return text .. string.rep(' ', width - text_width)
    end
end

-- Create window layout display that accurately represents the actual layout
local function create_layout_display(windows)
    if #windows <= 1 then
        return {}
    end

    local lines = {
        '',
        'Window Layout:',
    }

    -- 重複除去は位置ベースではなく、ウィンドウIDベースで行う
    local unique_windows = {}
    local seen_win_ids = {}

    for _, win in ipairs(windows) do
        if not seen_win_ids[win.win] then
            seen_win_ids[win.win] = true
            table.insert(unique_windows, win)
        end
    end

    -- 実際の列位置を正確にマッピングするための解析
    local all_col_positions = {}
    for _, win in ipairs(unique_windows) do
        table.insert(all_col_positions, win.col)
    end
    table.sort(all_col_positions)

    -- 重複する列位置を除去
    local unique_cols = {}
    local prev_col = nil
    for _, col in ipairs(all_col_positions) do
        if prev_col ~= col then
            table.insert(unique_cols, col)
            prev_col = col
        end
    end

    -- 行グループ化（修正：各ウィンドウを正確な行位置で表示）
    local rows = {}
    for _, win in ipairs(unique_windows) do
        local placed = false

        for _, row in ipairs(rows) do
            -- 同じ行判定：row の差が厳密に0の場合のみ
            if win.row == row.row_pos then
                table.insert(row.windows, win)
                placed = true
                break
            end
        end

        if not placed then
            table.insert(rows, {
                row_pos = win.row,
                windows = { win },
            })
        end
    end

    -- 行を位置順にソート
    table.sort(rows, function(a, b)
        return a.row_pos < b.row_pos
    end)

    -- 実際の位置に基づくグリッド表示を作成
    local col_count = #unique_cols

    -- ラベルマッピング作成（IDとラベルを別管理）
    local label_mapping = {}
    local used_labels = {}

    for _, win in ipairs(unique_windows) do
        local basename = vim.fn.fnamemodify(win.name, ':t')
        if basename == '' then
            basename = '[No Name]'
        end

        -- 同じファイル名の場合は連番で区別
        local label = basename
        local counter = 1
        while used_labels[label] do
            counter = counter + 1
            label = basename .. '(' .. counter .. ')'
        end

        used_labels[label] = true
        label_mapping[win.win] = label
    end

    -- ファイル名の最大幅を計算してセル幅を動的調整
    local max_display_name_length = 0
    for _, label in pairs(label_mapping) do
        max_display_name_length = math.max(max_display_name_length, vim.fn.strdisplaywidth(label))
    end

    -- セル幅を動的調整（最小10、最大25に縮小）
    local cell_width = math.max(10, math.min(max_display_name_length + 2, 25))

    -- 各行でグリッドを作成（空行のスキップロジック改善）
    local has_content_rows = {}
    for row_idx, row in ipairs(rows) do
        local has_content = false
        for _, win in ipairs(row.windows) do
            if label_mapping[win.win] and label_mapping[win.win] ~= '' then
                has_content = true
                break
            end
        end
        has_content_rows[row_idx] = has_content
    end

    for row_idx, row in ipairs(rows) do
        -- 内容がない行はスキップ
        if not has_content_rows[row_idx] then
            goto continue
        end

        -- 列位置マッピング：どの列にウィンドウがあるかを記録
        local grid_row = {}
        for col_idx = 1, col_count do
            grid_row[col_idx] = nil -- 空セル
        end

        local has_actual_content = false
        -- 各ウィンドウを正確な列位置にマッピング
        for _, win in ipairs(row.windows) do
            local mapped = false
            for col_idx, col_pos in ipairs(unique_cols) do
                if math.abs(win.col - col_pos) <= 10 then -- 列位置の許容値
                    local label = label_mapping[win.win]
                    if label and label ~= '' then
                        grid_row[col_idx] = label
                        has_actual_content = true
                        mapped = true
                    end
                    break
                end
            end

            -- マッピングされなかった場合のフォールバック
            if not mapped then
                local label = label_mapping[win.win]
                if label and label ~= '' then
                    -- 最も近い列に配置
                    local closest_col_idx = 1
                    local min_distance = math.abs(win.col - unique_cols[1])

                    for col_idx, col_pos in ipairs(unique_cols) do
                        local distance = math.abs(win.col - col_pos)
                        if distance < min_distance then
                            min_distance = distance
                            closest_col_idx = col_idx
                        end
                    end

                    -- 空いている列に配置、占有されている場合は最初の空列を探す
                    if not grid_row[closest_col_idx] then
                        grid_row[closest_col_idx] = label
                        has_actual_content = true
                    else
                        for col_idx = 1, col_count do
                            if not grid_row[col_idx] then
                                grid_row[col_idx] = label
                                has_actual_content = true
                                break
                            end
                        end
                    end
                end
            end
        end

        -- 実際に内容がない場合はスキップ
        if not has_actual_content then
            goto continue
        end

        -- 上境界線（最初の内容行のみ）
        local is_first_content_row = true
        for i = 1, row_idx - 1 do
            if has_content_rows[i] then
                is_first_content_row = false
                break
            end
        end

        if is_first_content_row then
            -- 現在の行が全幅かチェック
            local current_is_full_width = #row.windows == 1 and row.windows[1].width > 200

            if current_is_full_width then
                -- 全幅の場合の上境界線
                local total_width = (cell_width * col_count) + col_count - 1
                local border = '┌' .. string.rep('─', total_width) .. '┐'
                table.insert(lines, border)
            else
                -- 通常の上境界線
                local border = '┌'
                for col = 1, col_count do
                    border = border .. string.rep('─', cell_width)
                    if col < col_count then
                        border = border .. '┬'
                    else
                        border = border .. '┐'
                    end
                end
                table.insert(lines, border)
            end
        else
            -- 前の内容行との境界線のみ表示
            local prev_content_row_idx = nil
            for i = row_idx - 1, 1, -1 do
                if has_content_rows[i] then
                    prev_content_row_idx = i
                    break
                end
            end

            if prev_content_row_idx then
                -- 現在の行が全幅かチェック
                local current_is_full_width = #row.windows == 1 and row.windows[1].width > 200
                -- 前の行が全幅かチェック
                local prev_is_full_width = #rows[prev_content_row_idx].windows == 1
                    and rows[prev_content_row_idx].windows[1].width > 200

                if current_is_full_width and prev_is_full_width then
                    -- 両方全幅の場合
                    local total_width = (cell_width * col_count) + col_count - 1
                    local separator = '├' .. string.rep('─', total_width) .. '┤'
                    table.insert(lines, separator)
                elseif current_is_full_width and not prev_is_full_width then
                    -- 前が複数列、現在が全幅の場合
                    local separator = '├'
                    for col = 1, col_count do
                        separator = separator .. string.rep('─', cell_width)
                        if col < col_count then
                            separator = separator .. '┴'
                        else
                            separator = separator .. '┤'
                        end
                    end
                    table.insert(lines, separator)
                elseif not current_is_full_width and prev_is_full_width then
                    -- 前が全幅、現在が複数列の場合
                    local separator = '├'
                    for col = 1, col_count do
                        separator = separator .. string.rep('─', cell_width)
                        if col < col_count then
                            separator = separator .. '┬'
                        else
                            separator = separator .. '┤'
                        end
                    end
                    table.insert(lines, separator)
                else
                    -- 通常の境界線処理
                    local separator = '' -- 空文字で開始し、各列で記号を決定

                    -- 次の内容行を探す
                    local next_content_row_idx = nil
                    for i = row_idx + 1, #rows do
                        if has_content_rows[i] then
                            next_content_row_idx = i
                            break
                        end
                    end

                    for col = 1, col_count do
                        -- 各列のウィンドウ状況を確認
                        local above_has_window = false
                        local current_has_window = grid_row[col] ~= nil
                        local below_has_window = false

                        -- 上の行でこの列にウィンドウがあるか
                        for _, win in ipairs(rows[prev_content_row_idx].windows) do
                            for c, col_pos in ipairs(unique_cols) do
                                if c == col and math.abs(win.col - col_pos) <= 10 then
                                    above_has_window = true
                                    break
                                end
                            end
                            if above_has_window then
                                break
                            end
                        end

                        -- 下の行でこの列にウィンドウがあるか
                        if next_content_row_idx then
                            -- 下の行のgrid_rowを確認
                            local next_grid_row = {}
                            for _, win in ipairs(rows[next_content_row_idx].windows) do
                                for c, col_pos in ipairs(unique_cols) do
                                    if math.abs(win.col - col_pos) <= 50 then
                                        next_grid_row[c] = win
                                    end
                                end
                            end
                            below_has_window = next_grid_row[col] ~= nil
                        end

                        -- 横境界線が必要か：現在の列にファイルがある場合、または下の行にファイルがある場合
                        local needs_horizontal_line = current_has_window or below_has_window

                        -- 最初の列では左端記号を追加
                        if col == 1 then
                            separator = separator .. '│'
                        end

                        -- セルの横境界線を決定
                        if needs_horizontal_line then
                            separator = separator .. string.rep('─', cell_width)
                        else
                            separator = separator .. string.rep(' ', cell_width)
                        end

                        -- 各列の後に境界記号を追加
                        if col < col_count then
                            -- 次の列への境界記号（中間列で適切な記号を決定）
                            local next_symbol = ''
                            -- 次の列の状況を確認して適切な境界記号を決定
                            local next_col = col + 1
                            local next_current_has_window = grid_row[next_col] ~= nil
                            local next_below_has_window = false

                            if next_content_row_idx then
                                -- 次の行での次の列の状況をチェック
                                local next_grid_row = {}
                                for _, win in ipairs(rows[next_content_row_idx].windows) do
                                    for c, col_pos in ipairs(unique_cols) do
                                        if math.abs(win.col - col_pos) <= 50 then
                                            next_grid_row[c] = win
                                        end
                                    end
                                end
                                next_below_has_window = next_grid_row[next_col] ~= nil
                            end

                            local next_has_horizontal = next_current_has_window or next_below_has_window

                            if needs_horizontal_line and next_has_horizontal then
                                next_symbol = '┼'
                            elseif needs_horizontal_line then
                                next_symbol = '│' -- 縦線優先
                            elseif next_has_horizontal then
                                next_symbol = '│' -- 縦線優先
                            else
                                next_symbol = '│'
                            end
                            separator = separator .. next_symbol
                        else
                            -- 最後の列では右端記号
                            separator = separator .. '│'
                        end
                    end
                    table.insert(lines, separator)
                end
            end
        end

        -- 内容行（全幅ウィンドウの特別処理）
        local is_full_width = false
        local full_width_label = nil

        -- 全幅ウィンドウかチェック（1つのウィンドウで幅が大きい場合）
        if #row.windows == 1 and row.windows[1].width > 200 then
            is_full_width = true
            full_width_label = label_mapping[row.windows[1].win]
        end

        if is_full_width and full_width_label then
            -- 全幅ウィンドウの場合、全列にまたがる表示
            local content_line = '│'
            -- 全幅用のテキストを作成
            local total_inner_width = (cell_width * col_count) + (col_count - 1) -- セル幅 + 区切り文字
            local formatted_name = safe_format_text(full_width_label, total_inner_width - 2) -- 両端のスペース分引く
            content_line = content_line .. ' ' .. formatted_name .. ' │'
            table.insert(lines, content_line)
        else
            -- 通常の複数列表示
            local content_line = '│'
            for col = 1, col_count do
                local cell_content = grid_row[col] or ''
                local formatted_name = safe_format_text(cell_content, cell_width - 2)
                content_line = content_line .. ' ' .. formatted_name .. ' │'
            end
            table.insert(lines, content_line)
        end

        -- 最後の内容行の下境界線
        local is_last_content_row = true
        for i = row_idx + 1, #rows do
            if has_content_rows[i] then
                is_last_content_row = false
                break
            end
        end

        if is_last_content_row then
            -- 現在の行が全幅かチェック
            local current_is_full_width = #row.windows == 1 and row.windows[1].width > 200

            if current_is_full_width then
                -- 全幅の場合の下境界線
                local total_width = (cell_width * col_count) + col_count - 1
                local border = '└' .. string.rep('─', total_width) .. '┘'
                table.insert(lines, border)
            else
                -- 通常の下境界線
                local border = '└'
                for col = 1, col_count do
                    border = border .. string.rep('─', cell_width)
                    if col < col_count then
                        border = border .. '┴'
                    else
                        border = border .. '┘'
                    end
                end
                table.insert(lines, border)
            end
        end

        ::continue::
    end

    -- 実際の表示幅を計算
    local actual_width = (cell_width * col_count) + col_count + 1

    return lines, actual_width
end

-- Render buffer list
local function render_buffers(buffers)
    local lines = {}
    local highlights = {}
    local conf = config.get()

    -- Header with centered title
    local win_width = vim.api.nvim_win_get_width(state.win)
    local title = 'Bufferin'
    local title_padding = math.floor((win_width - vim.fn.strwidth(title)) / 2)
    local centered_title = string.rep(' ', title_padding) .. title
    table.insert(lines, centered_title)
    table.insert(lines, string.rep('─', win_width - 2))

    -- Buffer list
    for i, buf in ipairs(buffers) do
        local line = '  ' -- Left padding
        local col_offset = 2

        -- Current buffer indicator with pill emoji (moved to front)
        if buf.bufnr == state.original_buf then
            line = line .. ' ⭐️'
        else
            line = line .. '   '
        end
        col_offset = col_offset + 3

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
            line = line .. ' '
            col_offset = col_offset + 1
        end

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
        if buf.bufnr == state.original_buf then
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
    table.insert(lines, ' [Enter] Select  [dd] Delete  [K/J] Move  [q] Quit')

    -- Add window layout display (window map) - centered (experimental feature)
    local conf = config.get()
    if conf.show_window_layout then
        local windows = get_window_layout()
        local layout_lines = create_layout_display(windows)

        if #layout_lines > 0 then
            local win_width = vim.api.nvim_win_get_width(state.win)
            for _, line in ipairs(layout_lines) do
                if line:match('^Window Layout:') then
                    -- Center the title
                    local title = 'Window Layout:'
                    local title_padding = math.floor((win_width - vim.fn.strwidth(title)) / 2)
                    local centered_title = string.rep(' ', title_padding) .. title
                    table.insert(lines, centered_title)
                elseif line == '' then
                    -- Keep empty lines as-is
                    table.insert(lines, line)
                else
                    -- Center the layout map itself
                    local line_width = vim.fn.strdisplaywidth(line)
                    local padding = math.max(0, math.floor((win_width - line_width) / 2))
                    local centered_line = string.rep(' ', padding) .. line
                    table.insert(lines, centered_line)
                end
            end
        end
    end

    -- Set buffer content
    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.bo[state.buf].modifiable = false

    -- Apply highlights
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(state.buf, -1, hl.hl_group, hl.line - 1, hl.col_start, hl.col_end)
    end
end

-- Get buffer list
local function get_buffers()
    return buffer.get_buffers()
end

-- Calculate valid cursor range (only buffer lines, not header/footer/layout)
local function get_valid_cursor_range()
    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
        return 3, 3
    end

    local buffers = get_buffers()
    local line_count = vim.api.nvim_buf_line_count(state.buf)

    -- Header takes 2 lines, footer takes 2 lines
    -- Layout takes variable lines (calculate from content)
    local header_lines = 2
    local footer_lines = 2

    -- Count layout lines only if feature is enabled
    local layout_line_count = 0
    local conf = config.get()
    if conf.show_window_layout then
        local windows = get_window_layout()
        local layout_lines = create_layout_display(windows)
        layout_line_count = #layout_lines
    end

    local buffer_start = header_lines + 1 -- Line 3
    local buffer_end = line_count - footer_lines - layout_line_count

    return math.max(buffer_start, 3), math.max(buffer_end, buffer_start)
end

-- Refresh display with dynamic window resizing
local function refresh()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        local buffers = get_buffers()

        -- Recalculate window size based on current content
        local windows, layout_width = get_cached_window_info()

        -- Recalculate optimal height (only if feature enabled)
        local layout_height = 0
        local conf = config.get()
        if conf.show_window_layout and #windows > 1 then
            local unique_rows = {}
            for _, win in ipairs(windows) do
                local row_found = false
                for _, existing_row in ipairs(unique_rows) do
                    if win.row == existing_row then
                        row_found = true
                        break
                    end
                end
                if not row_found then
                    table.insert(unique_rows, win.row)
                end
            end

            local actual_row_count = #unique_rows
            layout_height = 2 + actual_row_count + (actual_row_count + 1)
        end

        local content_height = #buffers + 4 + layout_height
        local max_height = math.floor(vim.o.lines * 0.9)
        local min_height = math.min(15, content_height)
        local new_height = math.max(min_height, math.min(content_height, max_height))

        -- Recalculate optimal width (より正確に)
        local max_line_length = 0
        local conf = config.get()

        -- タイトル行の幅
        local title = 'Bufferin'
        max_line_length = math.max(max_line_length, vim.fn.strdisplaywidth(title))

        -- 各バッファ行の幅を正確に計算
        for _, buf in ipairs(buffers) do
            local line_length = 2 -- Left padding

            -- Current buffer indicator (➜ or spaces)
            line_length = line_length + 3

            -- Buffer number
            if conf.display.show_numbers then
                line_length = line_length + 5 -- "999: " format
            end

            -- File icon
            if conf.display.show_icons then
                line_length = line_length + 2 -- icon + space
            end

            -- Status icons (modified/readonly)
            line_length = line_length + 2 -- status icon + space

            -- Buffer name
            line_length = line_length + vim.fn.strdisplaywidth(buf.display_name)

            -- Path
            if conf.display.show_path and buf.name ~= '' then
                local dir = vim.fn.fnamemodify(buf.name, ':h')
                if dir ~= '.' then
                    line_length = line_length + 3 + vim.fn.strdisplaywidth(dir) -- " (" + dir + ")"
                end
            end

            max_line_length = math.max(max_line_length, line_length)
        end

        -- Footer line width
        local footer_text = ' [Enter] Select  [dd] Delete  [K/J] Move  [q] Quit'
        max_line_length = math.max(max_line_length, vim.fn.strdisplaywidth(footer_text))

        -- Calculate width considering layout map if enabled
        local buffer_content_width = max_line_length + 6 -- Buffer content width + padding
        local layout_map_width = 0

        -- Only include layout width if feature is enabled
        if conf.show_window_layout then
            layout_map_width = layout_width
        end

        local content_width = math.max(buffer_content_width, layout_map_width)

        local max_width = math.floor(vim.o.columns * 0.9)
        local new_width = math.min(content_width, max_width)

        -- Update window size if needed
        local current_config = vim.api.nvim_win_get_config(state.win)
        if current_config.width ~= new_width or current_config.height ~= new_height then
            local new_row = math.floor((vim.o.lines - new_height) / 2)
            local new_col = math.floor((vim.o.columns - new_width) / 2)

            vim.api.nvim_win_set_config(state.win, {
                relative = 'editor',
                width = new_width,
                height = new_height,
                row = new_row,
                col = new_col,
            })
        end

        render_buffers(buffers)

        -- Restore cursor position within valid range
        local min_line, max_line = get_valid_cursor_range()
        local cursor_line = math.min(state.selected_line + 2, max_line)
        cursor_line = math.max(min_line, cursor_line)

        if cursor_line <= vim.api.nvim_buf_line_count(state.buf) then
            vim.api.nvim_win_set_cursor(state.win, { cursor_line, 0 })
        end
    end
end

-- Get buffer at current line
local function get_current_buffer()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    local buffers = get_buffers()
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
        if buffer.move_buffer(idx, idx - 1, buffers) then
            state.selected_line = idx - 1
            refresh()
        end
    end
end

local function handle_move_down()
    local buf_info, idx, buffers = get_current_buffer()
    if buf_info and idx < #buffers then
        if buffer.move_buffer(idx, idx + 1, buffers) then
            state.selected_line = idx + 1
            refresh()
        end
    end
end

-- Restrict cursor movement to valid buffer lines
local function restrict_cursor_movement()
    local min_line, max_line = get_valid_cursor_range()
    local current_line = vim.api.nvim_win_get_cursor(state.win)[1]

    if current_line < min_line then
        vim.api.nvim_win_set_cursor(state.win, { min_line, 0 })
    elseif current_line > max_line then
        vim.api.nvim_win_set_cursor(state.win, { max_line, 0 })
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

    -- Restrict cursor movement with j/k and arrow keys
    vim.keymap.set('n', 'j', function()
        local min_line, max_line = get_valid_cursor_range()
        local current_line = vim.api.nvim_win_get_cursor(state.win)[1]
        if current_line < max_line then
            vim.api.nvim_win_set_cursor(state.win, { current_line + 1, 0 })
        end
    end, opts)

    vim.keymap.set('n', 'k', function()
        local min_line, max_line = get_valid_cursor_range()
        local current_line = vim.api.nvim_win_get_cursor(state.win)[1]
        if current_line > min_line then
            vim.api.nvim_win_set_cursor(state.win, { current_line - 1, 0 })
        end
    end, opts)

    vim.keymap.set('n', '<Down>', function()
        local min_line, max_line = get_valid_cursor_range()
        local current_line = vim.api.nvim_win_get_cursor(state.win)[1]
        if current_line < max_line then
            vim.api.nvim_win_set_cursor(state.win, { current_line + 1, 0 })
        end
    end, opts)

    vim.keymap.set('n', '<Up>', function()
        local min_line, max_line = get_valid_cursor_range()
        local current_line = vim.api.nvim_win_get_cursor(state.win)[1]
        if current_line > min_line then
            vim.api.nvim_win_set_cursor(state.win, { current_line - 1, 0 })
        end
    end, opts)

    -- Auto-correct cursor position on any cursor movement
    vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = state.buf,
        callback = restrict_cursor_movement,
    })

    -- パフォーマンス改善: debounced refresh
    local refresh_timer = nil
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete', 'WinNew', 'WinClosed' }, {
        callback = function()
            if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                -- キャッシュをクリア
                state.cached_layout = nil
                state.cached_layout_timestamp = 0

                if refresh_timer then
                    vim.fn.timer_stop(refresh_timer)
                end
                refresh_timer = vim.fn.timer_start(50, function() -- 50ms debounce
                    vim.schedule(refresh)
                    refresh_timer = nil
                end)
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

    -- Store the current buffer before opening bufferin window
    local original_buf = vim.api.nvim_get_current_buf()
    state.original_buf = original_buf

    -- Set global flag to prevent buffer switching during UI operations
    _G.bufferin_window_open = true

    state.buf, state.win = create_window()
    setup_mappings()
    refresh()
end

-- Close buffer manager
function M.close()
    -- Clear global flag when closing
    _G.bufferin_window_open = false

    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.buf = nil
    state.win = nil
    state.selected_line = 1
    state.original_buf = nil
    -- キャッシュクリア
    state.cached_layout = nil
    state.cached_layout_timestamp = 0
    state.cached_layout_width = 0
end

-- Toggle buffer manager
function M.toggle()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        M.close()
    else
        M.open()
    end
end

-- Test helper functions (always available for debugging)
function M._get_state()
    return state
end

function M._create_test_layout_display(windows)
    local lines, width = create_layout_display(windows)
    return lines
end

return M

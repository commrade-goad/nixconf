local M = {}

if Nvim_cc_split_size == nil then Nvim_cc_split_size = 15 end
if Nvim_cc_file_name == nil or Nvim_cc_file_name == "" then Nvim_cc_file_name = "nvim-cc.txt" end
if Nvim_cc_blacklist_dir_name == nil then Nvim_cc_blacklist_dir_name = { "src", "bin" } end
if Nvim_cc_modcwd == nil then Nvim_cc_modcwd = "" end
if Nvim_cc_start_insert == nil then Nvim_cc_start_insert = false end
if Nvim_cc_compile_command == nil then Nvim_cc_compile_command = "" end

-- Internal State
local term_buf_handle = nil
local vt_ns = vim.api.nvim_create_namespace("nvim-cc-virtual-jump")

--- Parses a string to find "file:line:col"
--- @return table|nil {filename, lnum, col} or nil if not found
local function parse_location(line)
    if not line then return nil end

    -- Try file:line:col
    local file, lnum, col = line:match("(/?[^%s:]+):(%d+):(%d+)")

    -- Try file:line (default col 1)
    if not col then
        file, lnum = line:match("(/?[^%s:]+):(%d+)")
        col = 1
    end

    if not file or not lnum then return nil end
    file = file:match("^%s*(.-)%s*$")
    if not file:match("([/A-Za-z%.][A-Za-z0-9/%.%-%_]*)") then return nil end

    return {
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col)
    }
end

local function get_project_root(current_dir)
    local dir = current_dir
    for _, item in ipairs(Nvim_cc_blacklist_dir_name) do
        if dir:sub(-#item - 1) == "/" .. item then
            dir = dir:sub(1, -#item - 2)
            break -- Assuming we only strip one level
        end
    end
    return dir
end

function M.set_compile_command_from_file()
    local directory = get_project_root(vim.fn.getcwd())
    local file_path = directory .. "/" .. Nvim_cc_file_name

    local success, file_content = pcall(vim.fn.readfile, file_path)

    if success and #file_content > 0 then
        local cmds = {}
        Nvim_cc_modcwd = ""
        local temp_modcwd = nil

        for _, line in ipairs(file_content) do
            -- Handle # directives (Lua code execution)
            if line:sub(1, 1) == "#" then
                local code = line:sub(2):match("^%s*(.-)%s*$")
                local chunk = load(code)
                if chunk then
                    chunk() -- Execute the lua code
                    -- If the lua code set the global ModCwd, capture it
                    if ModCwd then
                        Nvim_cc_modcwd = ModCwd
                        ModCwd = nil
                    end
                end
            elseif line ~= "" then
                table.insert(cmds, line)
            end
        end

        if #cmds > 0 then
            Nvim_cc_compile_command = table.concat(cmds, " && ")
            vim.opt_local.makeprg = Nvim_cc_compile_command
            print("nvim-cc: " .. Nvim_cc_compile_command)
        end
    else
        print("nvim-cc: Config file not found at " .. file_path)
    end
end

function M.input_compile_command()
    local input = vim.fn.input({
        prompt = "Enter Compile command: ",
        default = Nvim_cc_compile_command,
        completion = "shellcmd",
        wildchar = vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
    })

    if input ~= "" then
        Nvim_cc_compile_command = input
        vim.opt_local.makeprg = input
    end
end

function M.run_compile_command()
    if not Nvim_cc_compile_command or Nvim_cc_compile_command == "" then
        print("nvim-cc: No compile command specified!")
        return
    end

    -- Close existing terminal buffer if it exists
    if term_buf_handle and vim.api.nvim_buf_is_valid(term_buf_handle) then
        vim.api.nvim_buf_delete(term_buf_handle, { force = true })
    end

    local split_cmd = (Nvim_cc_vsplit_mode and "vsplit") or "split"
    vim.cmd(Nvim_cc_split_size .. split_cmd .. " | terminal " .. Nvim_cc_compile_command)

    term_buf_handle = vim.api.nvim_get_current_buf()
    local cwd_at_start = vim.fn.getcwd()

    -- Keymap: Enter to jump
    vim.keymap.set("n", "<CR>", function()
        M.jump_to_error_position()
    end, { buffer = term_buf_handle, silent = true, desc = "nvim-cc: Jump to error" })

    -- Autocmd: CursorMoved (Visual Indicator)
    local last_mark = nil
    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = term_buf_handle,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local row = cursor[1] - 1
            local line = vim.api.nvim_buf_get_lines(term_buf_handle, row, row + 1, false)[1]

            -- Clean up old mark
            if last_mark then
                pcall(vim.api.nvim_buf_del_extmark, term_buf_handle, vt_ns, last_mark)
                last_mark = nil
            end

            if parse_location(line) then
                last_mark = vim.api.nvim_buf_set_extmark(term_buf_handle, vt_ns, row, 0, {
                    virt_text = { { "<CR> Jump", "Comment" } },
                    virt_text_pos = "eol_right_align",
                })
            end
        end,
    })

    -- Autocmd: TermClose (Populate Quickfix)
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = term_buf_handle,
        once = true,
        callback = function()
            -- Generate Quickfix list
            local lines = vim.api.nvim_buf_get_lines(term_buf_handle, 0, -1, false)
            local qf_items = {}
            local resolve_cwd = cwd_at_start .. (Nvim_cc_modcwd ~= "" and ("/" .. Nvim_cc_modcwd) or "")

            for _, text in ipairs(lines) do
                local loc = parse_location(text)
                if loc then
                    -- Resolve relative paths
                    local filepath = loc.filename
                    if filepath:sub(1,1) ~= "/" then
                        filepath = resolve_cwd .. "/" .. filepath
                    end

                    table.insert(qf_items, {
                        filename = filepath,
                        lnum = loc.lnum,
                        col = loc.col,
                        text = text
                    })
                end
            end

            if #qf_items > 0 then
                vim.fn.setqflist({}, "r", { title = "nvim-cc", items = qf_items })
            end

            -- Restore original CWD just in case
            vim.cmd("tcd " .. cwd_at_start)
        end,
    })

    if Nvim_cc_start_insert then
        vim.cmd("startinsert")
    end
end

function M.jump_to_error_position()
    local line_content = vim.api.nvim_get_current_line()
    local loc = parse_location(line_content)

    if not loc then
        print("nvim-cc: Not a valid error line.")
        return
    end

    local base_cwd = vim.fn.getcwd()
    local target_cwd = base_cwd .. (Nvim_cc_modcwd ~= "" and ("/" .. Nvim_cc_modcwd) or "")

    local full_path = loc.filename
    if full_path:sub(1, 1) ~= "/" then
        full_path = target_cwd .. "/" .. full_path
    end

    local f = io.open(full_path, "r")
    if f then
        io.close(f)
    else
        local fallback_path = base_cwd .. "/" .. loc.filename
        local f2 = io.open(fallback_path, "r")
        if f2 then
            io.close(f2)
            full_path = fallback_path
        else
            print("nvim-cc: File not found: " .. full_path)
            return
        end
    end

    -- Find a suitable window (not the terminal one)
    local target_win = nil
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf ~= term_buf_handle and vim.bo[buf].buftype == "" then
            target_win = win
            break
        end
    end

    -- If no target window found, just stay here or split?
    -- Let's jump to the found window or split if strictly necessary
    if target_win then
        vim.api.nvim_set_current_win(target_win)
        vim.cmd("edit " .. full_path)
        vim.api.nvim_win_set_cursor(0, { loc.lnum, loc.col - 1 })
    else
        -- If we are in the terminal and it's the only window, split to open file
        vim.cmd("vsplit " .. full_path)
        vim.api.nvim_win_set_cursor(0, { loc.lnum, loc.col - 1 })
    end
end

function M.sync_directory_to_buffer()
    if vim.bo.filetype == 'netrw' or vim.b.netrw_bufnr then return end

    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file == "" then return end

    local file_dir = vim.fn.fnamemodify(current_file, ":h")
    local root_dir = get_project_root(file_dir)

    vim.cmd('tcd ' .. root_dir)
    print('nvim-cc: CWD set to ' .. root_dir)
end

function M.export_compile_command()
    local file = io.open(Nvim_cc_file_name, "w")
    if file then
        file:write(Nvim_cc_compile_command)
        file:close()
        print("nvim-cc: Saved command to " .. Nvim_cc_file_name)
    else
        print("nvim-cc: Failed to write to " .. Nvim_cc_file_name)
    end
end

vim.api.nvim_create_user_command("Compile", function(opts)
    local cmd = table.concat(opts.fargs, " ")
    if cmd ~= "" then
        Nvim_cc_compile_command = cmd
        vim.opt_local.makeprg = cmd
        M.run_compile_command()
    end
end, { nargs = "+", complete = "shellcmd" })

vim.api.nvim_create_user_command("Recompile", function()
    M.run_compile_command()
end, {})

function M.default_setup()
    Nvim_cc_start_insert = (Nvim_cc_start_insert == nil) and false or Nvim_cc_start_insert

    local map = vim.keymap.set
    map("n", "<leader>cC", M.input_compile_command, { desc = "Input Compile Command" })
    map("n", "<leader>cc", M.run_compile_command, { desc = "Run Compile Command" })
    map("n", "<leader>co", function() Nvim_cc_compile_command = "" end, { desc = "Clear compile command" })
    map("n", "<leader>cf", M.set_compile_command_from_file, { desc = "Set Command From File" })
    map("n", "<leader>cs", function()
        M.sync_directory_to_buffer()
        M.set_compile_command_from_file()
    end, { desc = "Sync Dir & Set Command" })
    map("n", "<leader>cw", M.export_compile_command, { desc = "Export Command" })
    map("n", "<leader>cj", M.jump_to_error_position, { desc = "Jump to Error" })
end

return M

local sbgit = require("mod.statusbar-git")

local function diagnostics(bufn)
    local counts = { 0, 0, 0, 0 }
    local diags = vim.diagnostic.get(bufn)
    if diags and not vim.tbl_isempty(diags) then
        for _, d in ipairs(diags) do
            if tonumber(d.severity) then
                counts[d.severity] = counts[d.severity] + 1
            end
        end
    end
    counts = {
        errors = counts[1],
        warnings = counts[2],
        infos = counts[3],
        hints = counts[4],
    }
    local items = {}
    local icons = {
        ["errors"] = "E",
        ["warnings"] = "W",
        ["infos"] = "I",
        ["hints"] = "H",
    }
    for _, k in ipairs({ "errors", "warnings", "infos", "hints" }) do
        if counts[k] > 0 then
            table.insert(items, ("%s%s"):format(icons[k], counts[k]))
        end
    end
    local fmt = "%s"
    if vim.tbl_isempty(items) then
        return ""
    end
    local contents = ("%s"):format(table.concat(items, ":"))
    local final = ":: [" .. fmt:format(contents) .. "]"
    return final
end

local function run_looping_task(interval_ms, action)
    local timer = vim.uv.new_timer()
    if timer ~= nil then
        timer:start(0, interval_ms, vim.schedule_wrap(function()
            action()
        end))
        return timer
    end
    return nil
end

-- DEFINITION --
local excluded_filetypes = { "undotree", "fugitive" }
local diag = ""
local branch = ""
local change = ""
-- local mode_s = ""
vim.wo.statusline = ""
vim.opt.laststatus = 0
----------------

local function is_buffer_excluded()
    local filetype = vim.bo.filetype
    local exclude = false
    for _, ft in ipairs(excluded_filetypes) do
        if filetype == ft then
            exclude = true
            break
        end
    end
    return exclude
end

local function update_display()
    if is_buffer_excluded() then
        vim.opt.laststatus = 0
        return;
    else
        diag = diagnostics(vim.api.nvim_get_current_buf())
        vim.opt.laststatus = 2
    end
    local buf = vim.api.nvim_get_current_buf()
    local filepath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:.")
    if filepath == "" then
        filepath = "temp"
    end
    local modified = vim.bo[buf].modified and "*" or ""
    local readonly = vim.bo[buf].readonly and "RO ::" or ""
    local filetype = vim.bo[buf].filetype ~= "" and vim.bo[buf].filetype .. " ::" or "N/A ::"
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line, col = cursor[1], cursor[2] + 1
    local final = string.format(" %s%s%s %s %%=%s %s %d:%d ", branch, filepath, modified, diag, readonly,
        filetype, line, col)
    vim.wo.statusline = final
end

local function setup_gitb()
    vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "BufWinEnter" }, {
        group = vim.api.nvim_create_augroup("statubar_gitb", { clear = true }),
        callback = function()
            local curbuff = vim.api.nvim_get_current_buf()
            local curbuffname = vim.api.nvim_buf_get_name(curbuff)
            local lb = sbgit.get_git_branch(nil, curbuffname)
            if lb then
                branch = lb .. ": "
            else
                branch = ""
            end
        end
    })
end

local function setup_cleanup()
    vim.api.nvim_create_autocmd("BufLeave", {
        group = vim.api.nvim_create_augroup("statubar_cleanup", { clear = true }),
        callback = function()
            diag = ""
            branch = "" -- because it check current cwd this will not change until cwd sync
        end
    })
end

setup_gitb()
-- setup_gitc()
setup_cleanup()

run_looping_task(250, update_display)

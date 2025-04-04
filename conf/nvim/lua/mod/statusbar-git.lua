M = {}
local Job = require "plenary.job"

function M.get_git_branch(_, buffer)
    local j = Job:new {
        command = "git",
        args = { "branch", "--show-current" },
        cwd = vim.fn.fnamemodify(buffer.name, ":h"),
    }

    local ok, result = pcall(function()
        return vim.trim(j:sync()[1])
    end)

    if ok then
        return result
    end
end

return M

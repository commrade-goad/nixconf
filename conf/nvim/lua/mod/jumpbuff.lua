local M = {}

JumpBuffTable = {}

local function get_current_idx()
    local bufnr = vim.api.nvim_get_current_buf()
    for i, val in ipairs(JumpBuffTable) do
        if val == bufnr then
            return i
        end
    end
    return -1
end

local function process_nop(i, op)
    if i == -1 then
        return 1
    end

    local new_i = (i + op - 1) % #JumpBuffTable + 1
    return new_i
end

function M.add_jumpbuff()
    local bufnr = vim.api.nvim_get_current_buf()

    if #JumpBuffTable <= 0 then
        table.insert(JumpBuffTable, bufnr)
    end

    for _, val in ipairs(JumpBuffTable) do
        if val ~= bufnr then
            table.insert(JumpBuffTable, bufnr)
            return
        end
    end
end

function M.rem_jumpbuff()
    local bufnr = vim.api.nvim_get_current_buf()
    for i, val in ipairs(JumpBuffTable) do
        if bufnr == val then
            table.remove(JumpBuffTable, i)
            return
        end
    end
end

function M.rem_jumpbuff_at(i)
    table.remove(JumpBuffTable, i)
end

function M.move_jumpbuff_to(i)
    if type(i) ~= "number" or i < 1 or i > #JumpBuffTable + 1 then
        error("Invalid index: " .. tostring(i))
    end
    if #JumpBuffTable <= 1 then
        return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local found_index = nil
    for j, val in ipairs(JumpBuffTable) do
        if bufnr == val then
            found_index = j
            break
        end
    end
    if not found_index then
        return
    end
    table.remove(JumpBuffTable, found_index)
    table.insert(JumpBuffTable, i, bufnr)
end

function M.print_jumpbuff()
    local str = table.concat(JumpBuffTable, " ")
    print(str)
end

function M.next_jumpbuff()
    local current_i = process_nop(get_current_idx(), 1)
    if vim.api.nvim_buf_is_valid(JumpBuffTable[current_i]) then
        vim.api.nvim_set_current_buf(JumpBuffTable[current_i])
    else
        table.remove(JumpBuffTable, current_i)
    end
end

function M.prev_jumpbuff()
    local current_i = process_nop(get_current_idx(), -1)
    if vim.api.nvim_buf_is_valid(JumpBuffTable[current_i]) then
        vim.api.nvim_set_current_buf(JumpBuffTable[current_i])
    else
        table.remove(JumpBuffTable, current_i)
    end
end

function M.jumpto_jumpbuff(i)
    if vim.api.nvim_buf_is_valid(JumpBuffTable[i]) then
        vim.api.nvim_set_current_buf(JumpBuffTable[i])
    end
end

-- function M.create_addbuffer_autocmd()
--     vim.api.nvim_create_autocmd("BufEnter", {
--         group = vim.api.nvim_create_augroup("jumpbuff_add_bufffer", {clear = true}),
--         callback = function ()
--             M.add_jumpbuff()
--         end
--     })
-- end
--
-- function M.create_rembuffer_autocmd()
--     vim.api.nvim_create_autocmd("BufLeave", {
--         group = vim.api.nvim_create_augroup("jumpbuff_add_bufffer", {clear = true}),
--         callback = function ()
--             M.rem_jumpbuff()
--         end
--     })
-- end

return M

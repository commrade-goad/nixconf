-- : RESTORE CURSOR POSITION
vim.api.nvim_create_autocmd('BufRead', {
    callback = function(opts)
        vim.api.nvim_create_autocmd('BufWinEnter', {
            once = true,
            buffer = opts.buf,
            callback = function()
                local ft = vim.bo[opts.buf].filetype
                local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                if
                    not (ft:match('commit') and ft:match('rebase'))
                    and last_known_line > 1
                    and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
                then
                    vim.api.nvim_feedkeys([[g`"]], 'nx', false)
                end
            end,
        })
    end,
})

-- : MAKE TRAILING WHITESPACE RED (USING TrailingWhitespace group)
vim.api.nvim_create_autocmd({ "BufWinEnter", "InsertLeave" }, {
    pattern = "*",
    callback = function()
        if vim.bo.buftype == "" then
            vim.fn.clearmatches()
            vim.fn.matchadd('TrailingWhitespace', [[\v\s+$|^\s+$]])
        end
    end
})

-- : .h FILES, SETS THE FILETYPE TO "CPP" IF .CPP FILES ARE FOUND, OTHERWISE SETS IT TO "C"
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.h",
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    local has_cpp = vim.fn.glob(dir .. "/*.cpp") ~= ""

    if has_cpp then
      vim.bo.filetype = "cpp"
    else
      vim.bo.filetype = "c"
    end
  end
})

-- : .h FILES, AUTOMATICALLY INSERT INCLUDE GUARD IN EMPTY FILE
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.h", "*.hpp" },
    callback = function()
        -- Check if file is empty
        local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
        if first_line == nil or first_line == "" then
            local filename = vim.fn.expand("%:t:r"):upper()
            local guard = string.format(
[[#ifndef %s_H_
#define %s_H_



#endif // %s_H_]], filename, filename, filename)
            vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(guard, "\n"))
            vim.api.nvim_win_set_cursor(0, { 4, 0 })
        end
    end
})

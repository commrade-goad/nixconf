local custom_color = {
    base00 = "#0D0D0D",        -- background         (default bg)
    base01 = "#0D0D0D",      -- surface/statusline (mode-line bg)
    base02 = "#2A2A2A",      -- selection bg       (region/visual)
    base03 = "#A8A8A8",      -- comments           (font-lock-comment-face via blend in emacs)
    base04 = "#C4C4C4",      -- line numbers / ui text
    base05 = "#E0E0E0",        -- foreground         (default fg)
    base06 = "#B3A57F",    -- cursor color
    base07 = "#E0E0E0",      -- bright fg
    base08 = "#E0E0E0",        -- variables          (font-lock-variable-name-face → fg+1)
    base09 = "#A493A4",    -- constants          (font-lock-constant-face → magenta)
    base0A = "#919C97",       -- types              (font-lock-type-face → cyan)
    base0B = "#70846D",      -- strings            (font-lock-string-face → green)
    base0C = "#919C97",       -- builtins/special   (font-lock-builtin-face → bright-cyan)
    base0D = "#7C93B0",       -- functions          (font-lock-function-name-face → blue)
    base0E = "#B3A57F",     -- keywords           (font-lock-keyword-face → yellow)
    base0F = "#7C93B0",       -- preprocessor       (font-lock-preprocessor-face → bright-blue)

    -- base00 = "#0D0D0D",        -- background         (default bg)
    -- base01 = "#0D0D0D",      -- surface/statusline (mode-line bg)
    -- base02 = "#2A2A2A",      -- selection bg       (region/visual)
    -- base03 = "#A8A8A8",      -- comments           (font-lock-comment-face via blend in emacs)
    -- base04 = "#C4C4C4",      -- line numbers / ui text
    -- base05 = "#E0E0E0",        -- foreground         (default fg)
    -- base06 = "#B3A57F",    -- cursor color
    -- base07 = "#E0E0E0",      -- bright fg
    -- base08 = "#E0E0E0",        -- variables          (font-lock-variable-name-face → fg+1)
    -- base09 = "#8B7A90",    -- constants          (font-lock-constant-face → magenta)
    -- base0A = "#727A78",       -- types              (font-lock-type-face → cyan)
    -- base0B = "#70846D",      -- strings            (font-lock-string-face → green)
    -- base0C = "#919C97",       -- builtins/special   (font-lock-builtin-face → bright-cyan)
    -- base0D = "#6C7F9C",       -- functions          (font-lock-function-name-face → blue)
    -- base0E = "#A3926F",     -- keywords           (font-lock-keyword-face → yellow)
    -- base0F = "#7C93B0",       -- preprocessor       (font-lock-preprocessor-face → bright-blue)
}

vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#B24B46" })

return custom_color

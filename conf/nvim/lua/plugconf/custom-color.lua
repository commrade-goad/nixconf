local custom_color = {
    base00 = '#2D353B', base01 = '#3D484D', base02 = '#4F585E', base03 = '#7A8478',
    base04 = '#877f6d', base05 = '#D3C6AA', base06 = '#DBBC7F', base07 = '#A7C080',
    base08 = '#E67E80', base09 = '#DBBC7F', base0A = '#83C092', base0B = '#A7C080',
    base0C = '#7FBBB3', base0D = '#D699B6', base0E = '#7FBBB3', base0F = '#baae96'
}

vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#E67E80" })

function Reapply_color()
    require('base16-colorscheme').setup(custom_color)
end

return custom_color

vim.g.material_style = "deep ocean"
-- Romper líneas automáticamente al alcanzar el límite
vim.opt.textwidth = 80 -- o 120, según prefieras
vim.opt.formatoptions:append("t") -- activa el auto-wrap en la inserción
vim.opt.linebreak = true -- evita cortar palabras a la mitad
vim.opt.wrap = true -- habilita el wrapping visual

return {
  {
    "marko-cerovac/material.nvim",
    name = "material",
    lazy = false,
    opts = {
      lualine_style = "stealth",
      disable = {
        background = true,
        term_colors = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "material",
    },
  },
}

-- This file contains the configuration for various UI-related plugins in Neovim.
return {
  { "folke/todo-comments.nvim", version = "*" },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      win = { border = "single" },
    },
  },

  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        cmdline = {
          view = "cmdline", -- Use the cmdline view for the command-line
        },
        presets = {
          bottom_search = true, -- Enable bottom search view
          command_palette = true, -- Enable command palette view
          lsp_doc_border = true, -- Enable LSP documentation border
        },
      })
    end,
  },

  {
    "amrbashir/nvim-docs-view",
    lazy = true, -- Load this plugin lazily
    cmd = "DocsViewToggle", -- Command to toggle the documentation view
    opts = {
      position = "right", -- Position the documentation view on the right
      width = 60, -- Set the width of the documentation view
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      image = {},
      picker = {
        matcher = {
          fuzzy = true,
          smartcase = true,
          ignorecase = true,
          filename_bonus = true,
        },
        sources = {
          explorer = {
            matcher = {
              fuzzy = true, -- Enables fuzzy matching, so you can be a bit imprecise with your search terms
              smartcase = true, -- If your search term has uppercase letters, the search becomes case-sensitive
              ignorecase = true, -- Ignores case when searching, unless smartcase is triggered
              filename_bonus = true, -- Gives a higher priority to matches in filenames
              sort_empty = false, -- If no matches are found, it won't sort the results
            },
          },
        },
      },
      dashboard = {
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
        preset = {
          header = [[
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡶⠶⠛⠛⠛⠛⠻⠶⢶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⡾⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠳⣦⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⡾⠋⢠⠀⠀⠀⠀⠀⠀⣠⠄⠀⠀⠀⠀⠀⠀⠈⠻⣦⠀⠀⠀⠀⠀
⠀⠀⠀⢠⡿⠁⠀⣸⡦⠾⢦⣤⡴⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣧⠀⠀⠀⠀
⣾⠛⠳⣾⠁⠀⠀⠿⠃⠀⢸⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣇⠀⠀⠀
⢻⡀⢸⡇⠀⡆⠀⠀⠀⠀⣀⣤⠴⢶⡆⠀⠀⠀⢀⣤⠖⠛⠉⠉⡷⠀⢿⡀⠀⠀
⠈⢷⣼⠃⠀⣿⠒⣶⢻⡏⣿⡀⠀⣿⡇⠀⠀⠀⠋⠀⠀⠀⢀⡼⠃⠀⢸⡇⠀⠀
⠀⠈⣿⠀⠀⢹⡀⣿⣾⠿⠛⢷⣸⢣⡇⠀⠀⠀⠀⠀⢀⣴⠟⠁⠀⠀⢸⡇⠀⠀
⠀⠀⢹⡆⠀⢸⣿⣿⠁⠀⠀⠀⠁⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀
⠀⠀⠸⣇⠀⠈⢿⡇⠀⠀⠀⠀⠀⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠓⠒⣶
⠀⠀⠀⢻⡄⠀⠘⣧⠀⠀⠀⠀⣸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠋
⠀⠀⠀⠀⠻⣆⠀⠈⠳⢦⣤⠾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠛⠀⠀
⠀⠀⠀⠀⠀⠈⠳⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⠶⠛⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠶⢦⣤⣤⣤⣤⣤⡴⠶⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀
]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },
}

local keymapc = vim.api.nvim_set_keymap
local keymap = vim.keymap.set

--global keymaps
keymapc("i", "jk", "<ESC>", { noremap = true }) --Esc

-- Position cursor at the middle of the screen after scrolling half page
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Move buffers
keymap("n", "<leader>h", ":bprevious<CR>")
keymap("n", "<leader>l", ":bNext<CR>")

-- Auto comments visual line
keymap("v", "<leader>wc", ":'<,'>CommentToggle<CR>")

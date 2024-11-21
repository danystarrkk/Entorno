local keymapc = vim.api.nvim_set_keymap
local keymap = vim.keymap.set

--global keymaps

keymapc("i", "jk", "<ESC>", { noremap = true }) --Esc

-- Position cursor at the middle of the screen after scrolling half page
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Map Ctrl+b in insert mode to delete to the end of the word without leaving insert mode
keymap("i", "<C-b>", "<C-o>de")

-- Live-server
keymap("n", "<leader>ws", ":LiveServerStart<CR>")
keymap("n", "<leader>wt", ":LiveServerStop<CR>")

-- Move buffers
keymap("n", "<leader>h", ":bprevious<CR>")
keymap("n", "<leader>l", ":bNext<CR>")

-- LoremIps
keymap("n", "<leader>wl", ":LoremIpsum paragraphs")

-- Auto comments visual line
keymap("v", "<leader>wc", ":'<,'>CommentToggle<CR>")

-----  OIL -----
keymap("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

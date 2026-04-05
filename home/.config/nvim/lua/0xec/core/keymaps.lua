local map = vim.keymap.set
local default_opts = { noremap = true, silent = true }

local function opts(desc, extra)
  return vim.tbl_extend("force", default_opts, { desc = desc }, extra or {})
end

-- Leader and setup
map({ "n", "v" }, "<Space>", "<Nop>", opts("Ignore space"))

-- Movement and search
map("n", "k", "v:count == 0 ? 'gk' : 'k'", opts("Move up display line", { expr = true }))
map("n", "j", "v:count == 0 ? 'gj' : 'j'", opts("Move down display line", { expr = true }))
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts("Clear search highlight"))
map("n", "<C-d>", "<C-d>zz", opts("Scroll down and center"))
map("n", "<C-u>", "<C-u>zz", opts("Scroll up and center"))
map("n", "n", "nzzzv", opts("Next search result and center"))
map("n", "N", "Nzzzv", opts("Previous search result and center"))

-- File and editing
map("n", "<C-s>", "<cmd>write<CR>", opts("Save file"))
map("n", "<leader>sn", "<cmd>noautocmd write<CR>", opts("Save without autocommands"))
map("n", "<C-q>", "<cmd>quit<CR>", opts("Quit window"))
map("n", "x", '"_x', opts("Delete character without yanking"))

-- Window resizing
map("n", "<Up>", "<cmd>resize -2<CR>", opts("Decrease window height"))
map("n", "<Down>", "<cmd>resize +2<CR>", opts("Increase window height"))
map("n", "<Left>", "<cmd>vertical resize -2<CR>", opts("Decrease window width"))
map("n", "<Right>", "<cmd>vertical resize +2<CR>", opts("Increase window width"))

-- Buffers
map("n", "<Tab>", "<cmd>bnext<CR>", opts("Next buffer"))
map("n", "<S-Tab>", "<cmd>bprevious<CR>", opts("Previous buffer"))
map("n", "<leader>sb", "<cmd>buffers<CR>:buffer ", opts("Select buffer", { silent = false }))
map("n", "<leader>x", "<cmd>bdelete<CR>", opts("Delete buffer"))
map("n", "<leader>b", "<cmd>enew<CR>", opts("New buffer"))

-- Numbers and wrapping
map("n", "<leader>+", "<C-a>", opts("Increment number"))
map("n", "<leader>-", "<C-x>", opts("Decrement number"))
map("n", "<leader>lw", "<cmd>set wrap!<CR>", opts("Toggle line wrap"))

-- Windows
map("n", "<leader>v", "<C-w>v", opts("Split window vertically"))
map("n", "<leader>h", "<C-w>s", opts("Split window horizontally"))
map("n", "<leader>se", "<C-w>=", opts("Equalize split sizes"))
map("n", "<leader>xs", "<cmd>close<CR>", opts("Close split"))
map("n", "<C-k>", "<cmd>wincmd k<CR>", opts("Focus upper window"))
map("n", "<C-j>", "<cmd>wincmd j<CR>", opts("Focus lower window"))
map("n", "<C-h>", "<cmd>wincmd h<CR>", opts("Focus left window"))
map("n", "<C-l>", "<cmd>wincmd l<CR>", opts("Focus right window"))

-- Tabs
map("n", "<leader>to", "<cmd>tabnew<CR>", opts("Open new tab"))
map("n", "<leader>tx", "<cmd>tabclose<CR>", opts("Close tab"))
map("n", "<leader>tn", "<cmd>tabnext<CR>", opts("Next tab"))
map("n", "<leader>tp", "<cmd>tabprevious<CR>", opts("Previous tab"))

-- Clipboard and explorer
map("v", "p", '"_dP', opts("Paste without replacing register"))
map({ "n", "v" }, "<leader>y", '"+y', opts("Yank to system clipboard"))
map("n", "<leader>Y", '"+Y', opts("Yank line to system clipboard"))
map("n", "<leader>e", "<cmd>Lexplore<CR>", opts("Open explorer"))

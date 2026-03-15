local map = vim.keymap.set
local silent = { noremap = true, silent = true }

map({ "n", "v" }, "<Space>", "<Nop>", silent)

map("n", "k", "v:count == 0 and 'gk' or 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 and 'gj' or 'j'", { expr = true, silent = true })

map("n", "<Esc>", "<cmd>nohlsearch<CR>", silent)
map("n", "<C-s>", "<cmd>write<CR>", silent)
map("n", "<leader>sn", "<cmd>noautocmd write<CR>", silent)
map("n", "<C-q>", "<cmd>quit<CR>", silent)

map("n", "x", '"_x', silent)

map("n", "<C-d>", "<C-d>zz", silent)
map("n", "<C-u>", "<C-u>zz", silent)
map("n", "n", "nzzzv", silent)
map("n", "N", "Nzzzv", silent)

map("n", "<Up>", "<cmd>resize -2<CR>", silent)
map("n", "<Down>", "<cmd>resize +2<CR>", silent)
map("n", "<Left>", "<cmd>vertical resize -2<CR>", silent)
map("n", "<Right>", "<cmd>vertical resize +2<CR>", silent)

map("n", "<Tab>", "<cmd>bnext<CR>", silent)
map("n", "<S-Tab>", "<cmd>bprevious<CR>", silent)
map("n", "<leader>sb", "<cmd>buffers<CR>:buffer ", { noremap = true })

map("n", "<leader>+", "<C-a>", silent)
map("n", "<leader>-", "<C-x>", silent)

map("n", "<leader>v", "<C-w>v", silent)
map("n", "<leader>h", "<C-w>s", silent)
map("n", "<leader>se", "<C-w>=", silent)
map("n", "<leader>xs", "<cmd>close<CR>", silent)

map("n", "<C-k>", "<cmd>wincmd k<CR>", silent)
map("n", "<C-j>", "<cmd>wincmd j<CR>", silent)
map("n", "<C-h>", "<cmd>wincmd h<CR>", silent)
map("n", "<C-l>", "<cmd>wincmd l<CR>", silent)

map("n", "<leader>to", "<cmd>tabnew<CR>", silent)
map("n", "<leader>tx", "<cmd>tabclose<CR>", silent)
map("n", "<leader>tn", "<cmd>tabnext<CR>", silent)
map("n", "<leader>tp", "<cmd>tabprevious<CR>", silent)

map("n", "<leader>x", "<cmd>bdelete<CR>", silent)
map("n", "<leader>b", "<cmd>enew<CR>", silent)
map("n", "<leader>lw", "<cmd>set wrap!<CR>", silent)

map("i", "jk", "<Esc>", silent)
map("i", "kj", "<Esc>", silent)

map("v", "p", '"_dP', silent)

map({ "n", "v" }, "<leader>y", '\"+y', silent)
map("n", "<leader>Y", '\"+Y', silent)

map("n", "<leader>e", "<cmd>Lexplore<CR>", silent)

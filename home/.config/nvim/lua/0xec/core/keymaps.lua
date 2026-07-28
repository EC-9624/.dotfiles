local map = vim.keymap.set
local default_opts = { noremap = true, silent = true }

local function opts(desc, extra)
	return vim.tbl_extend("force", default_opts, { desc = desc }, extra or {})
end

-- Movement and search
map("n", "k", "v:count == 0 ? 'gk' : 'k'", opts("Move up display line", { expr = true }))
map("n", "j", "v:count == 0 ? 'gj' : 'j'", opts("Move down display line", { expr = true }))
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts("Clear search highlight"))
map("n", "<C-d>", "<C-d>zz", opts("Scroll down and center"))
map("n", "<C-u>", "<C-u>zz", opts("Scroll up and center"))
map("n", "n", "nzzzv", opts("Next search result and center"))
map("n", "N", "Nzzzv", opts("Previous search result and center"))
map("n", "J", "mzJ`z", opts("Join line and keep cursor"))
map("v", "J", ":m '>+1<CR>gv=gv", opts("Move selected lines down"))
map("v", "K", ":m '<-2<CR>gv=gv", opts("Move selected lines up"))
map("v", "<", "<gv", opts("Indent left and reselect"))
map("v", ">", ">gv", opts("Indent right and reselect"))

-- File and editing
map("n", "<C-s>", "<cmd>write<CR>", opts("Save file"))
map("n", "<leader>sn", "<cmd>noautocmd write<CR>", opts("Save without autocommands"))
map("n", "<C-q>", "<cmd>quit<CR>", opts("Quit window"))
map("n", "U", "<C-r>", opts("Redo"))
map("n", "H", "^", opts("Go to first non-blank character"))
map("n", "L", "$", opts("Go to end of line"))
map("n", "x", '"_x', opts("Delete character without yanking"))

-- Window resizing
map("n", "<Up>", "<cmd>resize -2<CR>", opts("Decrease window height"))
map("n", "<Down>", "<cmd>resize +2<CR>", opts("Increase window height"))
map("n", "<Left>", "<cmd>vertical resize -2<CR>", opts("Decrease window width"))
map("n", "<Right>", "<cmd>vertical resize +2<CR>", opts("Increase window width"))

-- Buffers
map("n", "]b", "<cmd>bnext<CR>", opts("Next buffer"))
map("n", "[b", "<cmd>bprevious<CR>", opts("Previous buffer"))
map("n", "<leader>sb", "<cmd>buffers<CR>:buffer ", opts("Select buffer", { silent = false }))
map("n", "<leader>x", function()
	Snacks.bufdelete()
end, opts("Delete buffer"))
map("n", "<leader>b", "<cmd>enew<CR>", opts("New buffer"))

-- Numbers and wrapping
map("n", "<leader>+", "<C-a>", opts("Increment number"))
map("n", "<leader>_", "<C-x>", opts("Decrement number"))
map("n", "<leader>lw", "<cmd>set wrap!<CR>", opts("Toggle line wrap"))
map("n", "<leader>ln", function()
	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):toggle()
end, opts("Toggle relative line numbers"))
map("n", "<leader>ld", function()
	Snacks.toggle.diagnostics():toggle()
end, opts("Toggle diagnostics"))
map("n", "<leader>cl", function()
	Snacks.toggle.option("cursorline", { name = "Cursor Line" }):toggle()
end, opts("Toggle cursor line"))
map("n", "<leader>zm", function()
	Snacks.toggle.dim():toggle()
end, opts("Toggle dim mode"))
map("n", "<leader>tc", function()
	local tsc = require("treesitter-context")

	Snacks.toggle({
		name = "Treesitter Context",
		get = tsc.enabled,
		set = function(state)
			if state then
				tsc.enable()
			else
				tsc.disable()
			end
		end,
	}):toggle()
end, opts("Toggle Treesitter context"))
map("n", "<leader>ih", function()
	Snacks.toggle({
		name = "Inlay Hints",
		get = function()
			return vim.lsp.inlay_hint.is_enabled()
		end,
		set = function(state)
			vim.lsp.inlay_hint.enable(state)
		end,
	}):toggle()
end, opts("Toggle inlay hints"))

-- Windows
map("n", "<leader>v", "<C-w>v", opts("Split window vertically"))
map("n", "<leader>h", "<C-w>s", opts("Split window horizontally"))
map("n", "<leader>se", "<C-w>=", opts("Equalize split sizes"))
map("n", "<leader>xs", "<cmd>close<CR>", opts("Close split"))
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", opts("Focus upper window"))
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", opts("Focus lower window"))
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", opts("Focus left window"))
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", opts("Focus right window"))

-- Tabs
map("n", "<leader>to", "<cmd>tabnew<CR>", opts("Open new tab"))
map("n", "<leader>tx", "<cmd>tabclose<CR>", opts("Close tab"))
map("n", "<leader>tn", "<cmd>tabnext<CR>", opts("Next tab"))
map("n", "<leader>tp", "<cmd>tabprevious<CR>", opts("Previous tab"))

-- Git
map("n", "<leader>gg", function()
	Snacks.lazygit()
end, opts("Open lazygit"))

-- Clipboard and explorer
map("v", "p", '"_dP', opts("Paste without replacing register"))
map({ "n", "v" }, "<leader>y", '"+y', opts("Yank to system clipboard"))
map("n", "<leader>Y", '"+Y', opts("Yank line to system clipboard"))
map("n", "<leader>fp", function()
	local file_path = vim.fn.expand("%:~:.")

	if file_path == "" then
		vim.notify("No file path for current buffer", vim.log.levels.WARN)
		return
	end

	vim.fn.setreg("+", file_path)
	vim.notify("Copied file path: " .. file_path)
end, opts("Copy file path"))
map({ "n", "v" }, "<leader>og", function()
	Snacks.gitbrowse()
end, opts("Open git in browser"))
map("n", "<leader>nh", function()
	Snacks.notifier.show_history()
end, opts("Notification history"))
map("n", "<leader>nd", function()
	Snacks.notifier.hide()
end, opts("Dismiss notifications"))
map("n", "<leader>.", function()
	Snacks.scratch()
end, opts("Toggle scratch buffer"))
map("n", "<leader>s.", function()
	Snacks.scratch.select()
end, opts("Search scratch buffers"))
map("n", "<leader>e", function()
	require("neo-tree.command").execute({
		source = "filesystem",
		position = "right",
		reveal = true,
	})
end, opts("Toggle explorer and reveal current file"))
map("n", "-", "<cmd>Oil<CR>", opts("Open parent directory"))
map("n", "<leader>-", function()
	require("oil").toggle_float()
end, opts("Toggle Oil float"))

-- Find
map("n", "<leader>ff", function()
	require("fff").find_files()
end, opts("Find files"))
map("n", "<leader>fg", function()
	require("fff").live_grep()
end, opts("Live grep"))
map("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, opts("Find buffers"))
map("n", "<leader>fh", function()
	Snacks.picker.help()
end, opts("Find help"))

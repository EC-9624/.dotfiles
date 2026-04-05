local opt = vim.opt

-- Language and spelling
opt.spelllang = { "en_us", "de_de", "es_es" }

-- Search behavior
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true

-- Line numbers and interface
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.numberwidth = 4
opt.showtabline = 2
opt.laststatus = 2
opt.statusline = "%f%=%l/%L"
opt.termguicolors = true

-- Mouse, timing, and undo history
opt.mouse = "a"
opt.updatetime = 250
opt.timeoutlen = 500
opt.undofile = true

-- Backup and swap files
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Completion and cursor movement
opt.completeopt = { "menuone", "noselect" }
opt.whichwrap:append("<,>,[,],h,l")

-- Wrapping and scrolling
opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Indentation and tabs
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Window splitting
opt.splitbelow = true
opt.splitright = true

-- Editing behavior
opt.backspace = { "indent", "eol", "start" }
opt.iskeyword:append("-")
opt.showmatch = true

-- Popup menu and concealed text
opt.pumheight = 10
opt.conceallevel = 0

-- Clipboard integration
opt.clipboard = "unnamedplus"

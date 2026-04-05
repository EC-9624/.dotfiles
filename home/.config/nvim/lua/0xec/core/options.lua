local opt = vim.opt

opt.spelllang = { "en_us", "de_de", "es_es" }

opt.hlsearch = false
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300

opt.backup = false
opt.writebackup = false
opt.swapfile = false

opt.completeopt = { "menuone", "noselect" }
opt.whichwrap:append("<,>,[,],h,l")

opt.wrap = false
opt.linebreak = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.numberwidth = 4

opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

opt.splitbelow = true
opt.splitright = true
opt.showtabline = 2
opt.backspace = { "indent", "eol", "start" }
opt.pumheight = 10
opt.conceallevel = 0
opt.iskeyword:append("-")
opt.showmatch = true
opt.laststatus = 2
opt.statusline = "%f%=%l/%L"

opt.clipboard = "unnamedplus"
opt.termguicolors = true

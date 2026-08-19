local theme = require("0xec.theme")

return {
	{ "folke/tokyonight.nvim", lazy = false },
	{ "rose-pine/neovim", name = "rose-pine", lazy = false },
	{ "catppuccin/nvim", name = "catppuccin", lazy = false },
	theme.spec,
}

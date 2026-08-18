local colors = {
	base = "#191724",
	surface = "#1f1d2e",
	overlay = "#26233a",
	muted = "#6e6a86",
	subtle = "#908caa",
	text = "#e0def4",
	love = "#eb6f92",
	gold = "#f6c177",
	rose = "#ebbcba",
	pine = "#31748f",
	foam = "#9ccfd8",
	iris = "#c4a7e7",
	highlight_med = "#403d52",
	highlight_high = "#524f67",
	none = "NONE",
}

return {
	colors = colors,
	spec = {
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		opts = {
			variant = "main",
			dark_variant = "main",
			extend_background_behind_borders = true,
			styles = {
				transparency = true,
			},
			highlight_groups = {
				NeoTreeNormal = { fg = colors.text, bg = colors.none },
				NeoTreeNormalNC = { fg = colors.subtle, bg = colors.none },
				NeoTreeEndOfBuffer = { fg = colors.none, bg = colors.none },
				NeoTreeFloatBorder = { fg = colors.muted, bg = colors.none },
				NeoTreeFloatTitle = { fg = colors.base, bg = colors.foam, bold = true },
				NeoTreeTitleBar = { fg = colors.base, bg = colors.iris, bold = true },
				NeoTreeDirectoryName = { fg = colors.foam },
				NeoTreeDirectoryIcon = { fg = colors.foam },
				NeoTreeRootName = { fg = colors.iris, bold = true },
				NeoTreeGitAdded = { fg = colors.foam },
				NeoTreeGitModified = { fg = colors.gold },
				NeoTreeGitDeleted = { fg = colors.love },
				NeoTreeGitUntracked = { fg = colors.iris },
				NeoTreeIndentMarker = { fg = colors.highlight_med },
				NeoTreeExpander = { fg = colors.muted },
				NeoTreeCursorLine = { bg = colors.overlay },

				SnacksIndent = { fg = colors.highlight_med },
				SnacksIndentScope = { fg = colors.love },
				SnacksIndentChunk = { fg = colors.foam },

				OilFile = { fg = colors.text },
				OilLink = { fg = colors.iris },
				OilOrphanLink = { fg = colors.love },
				OilLinkTarget = { fg = colors.muted },
				OilSocket = { fg = colors.pine },
			},
		},
		config = function(_, opts)
			require("rose-pine").setup(opts)
			vim.cmd.colorscheme("rose-pine")
		end,
	},
}

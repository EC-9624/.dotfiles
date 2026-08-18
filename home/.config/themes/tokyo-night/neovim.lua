local colors = {
	base = "#1a1b26",
	surface = "#16161e",
	overlay = "#292e42",
	muted = "#565f89",
	subtle = "#737aa2",
	text = "#c0caf5",
	love = "#f7768e",
	gold = "#e0af68",
	rose = "#ff9e64",
	pine = "#7aa2f7",
	foam = "#7dcfff",
	iris = "#bb9af7",
	highlight_med = "#3b4261",
	highlight_high = "#414868",
	none = "NONE",
}

return {
	colors = colors,
	spec = {
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			transparent = true,
			on_highlights = function(highlights)
				highlights.NeoTreeNormal = { fg = colors.text, bg = colors.none }
				highlights.NeoTreeNormalNC = { fg = colors.subtle, bg = colors.none }
				highlights.NeoTreeEndOfBuffer = { fg = colors.none, bg = colors.none }
				highlights.NeoTreeFloatBorder = { fg = colors.muted, bg = colors.none }
				highlights.NeoTreeFloatTitle = { fg = colors.base, bg = colors.foam, bold = true }
				highlights.NeoTreeTitleBar = { fg = colors.base, bg = colors.iris, bold = true }
				highlights.NeoTreeDirectoryName = { fg = colors.foam }
				highlights.NeoTreeDirectoryIcon = { fg = colors.foam }
				highlights.NeoTreeRootName = { fg = colors.iris, bold = true }
				highlights.NeoTreeGitAdded = { fg = colors.foam }
				highlights.NeoTreeGitModified = { fg = colors.gold }
				highlights.NeoTreeGitDeleted = { fg = colors.love }
				highlights.NeoTreeGitUntracked = { fg = colors.iris }
				highlights.NeoTreeIndentMarker = { fg = colors.highlight_med }
				highlights.NeoTreeExpander = { fg = colors.muted }
				highlights.NeoTreeCursorLine = { bg = colors.overlay }

				highlights.SnacksIndent = { fg = colors.highlight_med }
				highlights.SnacksIndentScope = { fg = colors.love }
				highlights.SnacksIndentChunk = { fg = colors.foam }

				highlights.OilFile = { fg = colors.text }
				highlights.OilLink = { fg = colors.iris }
				highlights.OilOrphanLink = { fg = colors.love }
				highlights.OilLinkTarget = { fg = colors.muted }
				highlights.OilSocket = { fg = colors.pine }
			end,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
}

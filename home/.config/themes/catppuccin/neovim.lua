local colors = {
	base = "#24273a",
	surface = "#1e2030",
	overlay = "#363a4f",
	muted = "#8087a2",
	subtle = "#a5adce",
	text = "#cad3f5",
	love = "#ed8796",
	gold = "#eed49f",
	rose = "#f5a97f",
	pine = "#8aadf4",
	foam = "#91d7e3",
	iris = "#c6a0f6",
	highlight_med = "#363a4f",
	highlight_high = "#494d64",
	none = "NONE",
}

return {
	colors = colors,
	spec = {
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "macchiato",
			transparent_background = true,
			integrations = {
				fidget = true,
				gitsigns = true,
				native_lsp = { enabled = true },
				notify = true,
				render_markdown = true,
				snacks = {
					enabled = true,
					indent_scope_color = "mauve",
				},
				todo_comments = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
			},
			custom_highlights = function()
				return {
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
				}
			end,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin-macchiato")

			for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
				vim.api.nvim_set_hl(0, group, {})
			end
		end,
	},
}

return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = function()
		local colors = require("0xec.theme").colors
		local diagnostic_icons = {
			error = "",
			warning = "",
			info = "",
			hint = "󰌶",
		}

		return {
			options = {
				mode = "buffers",
				diagnostics = "nvim_lsp",
				separator_style = "thin",
				indicator = { style = "none" },
				show_buffer_close_icons = false,
				show_close_icon = false,
				always_show_bufferline = false,
				modified_icon = "●",
				diagnostics_indicator = function(_, _, diagnostics)
					local parts = {}

					if diagnostics.error then
						table.insert(parts, diagnostic_icons.error .. diagnostics.error)
					end

					if diagnostics.warning then
						table.insert(parts, diagnostic_icons.warning .. diagnostics.warning)
					end

					if diagnostics.info then
						table.insert(parts, diagnostic_icons.info .. diagnostics.info)
					end

					if diagnostics.hint then
						table.insert(parts, diagnostic_icons.hint .. diagnostics.hint)
					end

					return #parts > 0 and " " .. table.concat(parts, " ") or ""
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Explorer",
						text_align = "center",
						separator = true,
					},
				},
			},
			highlights = {
				fill = { fg = colors.muted, bg = colors.none },
				background = { fg = colors.muted, bg = colors.none },
				buffer_visible = { fg = colors.subtle, bg = colors.none },
				buffer_selected = { fg = colors.text, bg = colors.overlay, bold = true, italic = false },
				duplicate = { fg = colors.muted, bg = colors.none, italic = false },
				duplicate_visible = { fg = colors.subtle, bg = colors.none, italic = false },
				duplicate_selected = { fg = colors.text, bg = colors.overlay, bold = true, italic = false },
				modified = { fg = colors.gold, bg = colors.none },
				modified_visible = { fg = colors.gold, bg = colors.none },
				modified_selected = { fg = colors.gold, bg = colors.overlay },
				diagnostic = { fg = colors.muted, bg = colors.none },
				diagnostic_visible = { fg = colors.subtle, bg = colors.none },
				diagnostic_selected = { fg = colors.text, bg = colors.overlay, bold = true, italic = false },
				error = { fg = colors.love, bg = colors.none },
				error_visible = { fg = colors.love, bg = colors.none },
				error_selected = { fg = colors.love, bg = colors.overlay, bold = true, italic = false },
				warning = { fg = colors.gold, bg = colors.none },
				warning_visible = { fg = colors.gold, bg = colors.none },
				warning_selected = { fg = colors.gold, bg = colors.overlay, bold = true, italic = false },
				separator = { fg = colors.highlight_med, bg = colors.none },
				separator_visible = { fg = colors.highlight_med, bg = colors.none },
				separator_selected = { fg = colors.overlay, bg = colors.overlay },
				offset_separator = { fg = colors.highlight_med, bg = colors.none },
				trunc_marker = { fg = colors.muted, bg = colors.none },
			},
		}
	end,
}

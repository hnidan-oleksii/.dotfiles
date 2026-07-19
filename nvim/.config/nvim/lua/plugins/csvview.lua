-- csvview.nvim for better csv viewing.
-- Default = "border" grid (eye-friendly for narrow CSVs). Auto-enable and mode
-- selection live in lua/config/csv.lua, which skips the grid on fat/multi-line
-- files (where border blows one column across the screen) in favour of the
-- record view (<leader>cr).
return {
	"hat0uma/csvview.nvim",
	ft = { "csv", "tsv" },
	opts = {
		view = {
			display_mode = "border",
			min_column_width = 15,
			spacing = 2,
		},
	},
	config = function(_, opts)
		require("csvview").setup(opts)
	end,
}

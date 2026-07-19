return {
	-- Auto-close brackets/quotes
	"rstacruz/vim-closer",

	-- Undo history tree
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree toggle" },
		},
	},
}

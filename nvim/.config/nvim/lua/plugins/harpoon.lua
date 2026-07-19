return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		local function list(name)
			return name and harpoon:list(name) or harpoon:list()
		end

		-- default list: volatile working set
		vim.keymap.set("n", "<leader>a", function() list():add() end)
		vim.keymap.set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(list()) end)
		vim.keymap.set("n", "<leader>1", function() list():select(1) end)
		vim.keymap.set("n", "<leader>2", function() list():select(2) end)
		vim.keymap.set("n", "<leader>3", function() list():select(3) end)
		vim.keymap.set("n", "<leader>4", function() list():select(4) end)
		vim.keymap.set("n", "<leader>n", function() list():next() end)
		vim.keymap.set("n", "<leader>b", function() list():prev() end)

		-- pin list: durable anchors (l = list)
		vim.keymap.set("n", "<leader>la", function() list("pin"):add() end)
		vim.keymap.set("n", "<leader>le", function() harpoon.ui:toggle_quick_menu(list("pin")) end)
		vim.keymap.set("n", "<leader>l1", function() list("pin"):select(1) end)
		vim.keymap.set("n", "<leader>l2", function() list("pin"):select(2) end)
		vim.keymap.set("n", "<leader>l3", function() list("pin"):select(3) end)
		vim.keymap.set("n", "<leader>l4", function() list("pin"):select(4) end)
	end,
}

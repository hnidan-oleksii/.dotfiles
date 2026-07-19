return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		"nvim-treesitter/nvim-treesitter-textobjects",
	},

	config = function()
		require("telescope").setup({
			defaults = {
				file_ignore_patterns = {
					"helm%-charts/", "provisioning/", "%-k8s/", "/dev/", "/stage/", "/prod/",
					"model_deployment/", "experiments/", "qa_chatbot_automation/", "tests%-env/",
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		})

		pcall(require("telescope").load_extension, "fzf")

		local builtin = require("telescope.builtin")

		-- Your existing mappings
		vim.keymap.set("n", "<leader>pf", builtin.find_files)
		vim.keymap.set("n", "<C-p>", builtin.git_files)
		vim.keymap.set("n", "<leader>ps", builtin.live_grep)
		-- find_files but reach ignored infra dirs (helm/provisioning/k8s)
		vim.keymap.set("n", "<leader>pF", function()
			builtin.find_files({ no_ignore = true, file_ignore_patterns = {} })
		end)

		-- Existing Kickstart mappings
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
	end,
}

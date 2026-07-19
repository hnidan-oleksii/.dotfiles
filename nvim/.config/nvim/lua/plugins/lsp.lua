return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"williamboman/mason.nvim",
			build = ":MasonUpdate",
			opts = {},
		},
		{
			"williamboman/mason-lspconfig.nvim",
			opts = {
				ensure_installed = {
					"pylsp",
					"bashls",
					"ts_ls",
				},
			},
		},
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
		"L3MON4D3/LuaSnip",
	},

	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup()

		------------------------------------------------------------------
		-- Completion
		------------------------------------------------------------------
		local cmp = require("cmp")

		cmp.setup({
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),

			sources = {
				{ name = "nvim_lsp" },
				{ name = "path" },
				{ name = "buffer" },
			},
		})

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		------------------------------------------------------------------
		-- LSP keymaps
		------------------------------------------------------------------
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(event)
				local opts = { buffer = event.buf }

				local builtin = require("telescope.builtin")

				vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
				vim.keymap.set("n", "gr", builtin.lsp_references, opts)
				vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
				vim.keymap.set("n", "<leader>vws", builtin.lsp_dynamic_workspace_symbols, opts)

				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
				vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
			end,
		})

		------------------------------------------------------------------
		-- Shared defaults
		------------------------------------------------------------------
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		------------------------------------------------------------------
		-- pylsp
		------------------------------------------------------------------
		vim.lsp.config("pylsp", {
			settings = {
				pylsp = {
					plugins = {
						pycodestyle = {
							maxLineLength = 120,
						},
					},
				},
			},
		})

		------------------------------------------------------------------
		-- Enable servers
		------------------------------------------------------------------
		vim.lsp.enable("pylsp")
		vim.lsp.enable("bashls")
		vim.lsp.enable("ts_ls")
	end,
}

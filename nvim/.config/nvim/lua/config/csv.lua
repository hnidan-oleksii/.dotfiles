------------------------------------------------------------------------------
-- CSV workflow (data-science: wide chatbot-response dumps)
------------------------------------------------------------------------------
-- Record view: render the CSV record under the cursor vertically, one field
-- per section, in a scratch split. Robust to multi-line quoted cells (the
-- Python helper does byte-level RFC-4180 parsing). This is the real reader for
-- fat CSVs; the csvview border grid is only useful for narrow ones.
local csv_record_script = vim.fn.stdpath("config") .. "/scripts/csv_record.py"

local function csv_open_record(opts)
	opts = opts or {}
	local src = opts.src or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(src) then
		return
	end
	local path = vim.api.nvim_buf_get_name(src)
	if path == "" then
		vim.notify("csv record: buffer has no file on disk", vim.log.levels.WARN)
		return
	end

	local cmd = { "python3", csv_record_script, path }
	if opts.index ~= nil then
		vim.list_extend(cmd, { "--index", tostring(opts.index) })
	else
		-- 0-based byte offset of the cursor, matching the helper's parsing
		local off = vim.fn.line2byte(vim.fn.line(".")) - 1 + (vim.fn.col(".") - 1)
		vim.list_extend(cmd, { "--offset", tostring(off) })
	end

	local out = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify("csv record failed: " .. table.concat(out, "\n"), vim.log.levels.ERROR)
		return
	end

	-- First line is metadata: IDX <tab> idx <tab> total
	local meta = vim.split(table.remove(out, 1) or "", "\t")
	local idx = tonumber(meta[2]) or 0
	local total = tonumber(meta[3]) or 0

	-- Reuse one scratch buffer per source CSV
	local buf = vim.b[src].csv_record_buf
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then
		buf = vim.api.nvim_create_buf(false, true)
		vim.b[src].csv_record_buf = buf
		vim.bo[buf].bufhidden = "wipe"
		vim.api.nvim_buf_set_var(buf, "csv_src", src)
		-- record-local navigation
		vim.keymap.set("n", "]r", function()
			csv_open_record({ src = vim.b[buf].csv_src, index = vim.b[buf].csv_idx + 1 })
		end, { buffer = buf, desc = "CSV record: next" })
		vim.keymap.set("n", "[r", function()
			csv_open_record({ src = vim.b[buf].csv_src, index = vim.b[buf].csv_idx - 1 })
		end, { buffer = buf, desc = "CSV record: prev" })
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "CSV record: close" })
	end
	vim.api.nvim_buf_set_var(buf, "csv_idx", idx)
	vim.api.nvim_buf_set_var(buf, "csv_total", total)

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
	vim.bo[buf].modifiable = false

	local win = vim.fn.bufwinid(buf)
	if win == -1 then
		vim.cmd("vsplit")
		win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win, buf)
	else
		vim.api.nvim_set_current_win(win)
	end
	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].cursorline = false
	pcall(vim.api.nvim_win_set_cursor, win, { 1, 0 })
end

-- Heuristic: a "fat" CSV has very long lines (huge cells), where the border
-- grid would blow one column across the whole screen. On those, leave the
-- buffer as raw text and read it via <leader>cr instead. Narrow CSVs get the
-- eye-friendly border grid.
local function is_fat_csv(bufnr)
	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)) do
		if #line > 400 then
			return true
		end
	end
	return false
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "csv", "tsv" },
	callback = function(ev)
		-- Raw-view sanity: horizontal scroll beats wrap-mush; kill the 80-col ruler
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = ""

		-- Auto-enable csvview border grid, but only on narrow files. Deferred so
		-- it runs after lazy has loaded the plugin on this filetype. FileType
		-- fires twice per buffer and csvview attaches asynchronously, so guard
		-- with a synchronous buffer flag to avoid a duplicate enable.
		if not vim.b[ev.buf].csv_autoview_done then
			vim.b[ev.buf].csv_autoview_done = true
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(ev.buf) or is_fat_csv(ev.buf) then
					return
				end
				pcall(function()
					local cv = require("csvview")
					if not cv.is_enabled(ev.buf) then
						cv.enable(ev.buf)
					end
				end)
			end)
		end

		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
		end
		map("<leader>cr", csv_open_record, "CSV: record view (cursor row)")
		map("<leader>cv", "<cmd>CsvViewToggle<cr>", "CSV: toggle border grid")
	end,
})

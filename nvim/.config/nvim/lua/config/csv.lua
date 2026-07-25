------------------------------------------------------------------------------
-- CSV workflow (data-science: wide chatbot-response dumps)
------------------------------------------------------------------------------
-- Record view: render the CSV record under the cursor vertically, one field
-- per section, in a scratch split. Robust to multi-line quoted cells (the
-- Python helper does byte-level RFC-4180 parsing). This is the real reader for
-- fat CSVs; the csvview border grid is only useful for narrow ones.
local csv_record_script = vim.fn.stdpath("config") .. "/scripts/csv_record.py"

local csv_goto_record -- forward decl: referenced inside csv_open_record's record-view maps

local caches = {} -- [src bufnr] = { tick, total, hlen, starts, lens }; record byte-offsets, scanned once

local function get_cache(src, path)
	local c = caches[src]
	local tick = vim.b[src].changedtick
	if c and c.tick == tick then
		return c
	end
	local out = vim.fn.systemlist({ "python3", csv_record_script, path, "--offsets" })
	if vim.v.shell_error ~= 0 then
		vim.notify("csv offsets failed: " .. table.concat(out, "\n"), vim.log.levels.ERROR)
		return nil
	end
	local meta = vim.split(out[1] or "", "\t")
	local starts, lens = {}, {}
	for i = 2, #out do
		local p = vim.split(out[i], "\t")
		starts[#starts + 1] = tonumber(p[1])
		lens[#lens + 1] = tonumber(p[2])
	end
	c = { tick = tick, total = tonumber(meta[2]) or 0, hlen = tonumber(meta[3]) or 0, starts = starts, lens = lens }
	caches[src] = c
	return c
end

-- largest 1-based i with starts[i] <= off (maps cursor byte offset to record)
local function index_for_offset(starts, off)
	local lo, hi, ans = 1, #starts, 1
	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		if starts[mid] <= off then
			ans, lo = mid, mid + 1
		else
			hi = mid - 1
		end
	end
	return ans
end

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

	local cache = get_cache(src, path)
	if not cache or cache.total == 0 then
		vim.notify("csv record: no data records", vim.log.levels.WARN)
		return
	end

	local idx -- 0-based body index
	if opts.index ~= nil then
		idx = math.max(0, math.min(opts.index, cache.total - 1))
	else
		-- 0-based byte offset of the cursor, matching the helper's parsing
		local off = vim.fn.line2byte(vim.fn.line(".")) - 1 + (vim.fn.col(".") - 1)
		idx = index_for_offset(cache.starts, off) - 1
	end
	local total = cache.total

	local j = idx + 1 -- Lua lists are 1-based
	local out = vim.fn.systemlist({
		"python3", csv_record_script, path, "--slice",
		"--header-len", tostring(cache.hlen),
		"--start", tostring(cache.starts[j]),
		"--len", tostring(cache.lens[j]),
		"--idx", tostring(idx),
		"--total", tostring(total),
	})
	if vim.v.shell_error ~= 0 then
		vim.notify("csv record failed: " .. table.concat(out, "\n"), vim.log.levels.ERROR)
		return
	end
	table.remove(out, 1) -- drop IDX meta line (idx/total already known)

	-- Reuse one scratch buffer per source CSV
	local buf = vim.b[src].csv_record_buf
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then
		buf = vim.api.nvim_create_buf(false, true)
		vim.b[src].csv_record_buf = buf
		vim.bo[buf].bufhidden = "wipe"
		vim.api.nvim_buf_set_var(buf, "csv_src", src)
		-- record-local navigation
		vim.keymap.set("n", "<Right>", function()
			csv_open_record({ src = vim.b[buf].csv_src, index = vim.b[buf].csv_idx + 1 })
		end, { buffer = buf, desc = "CSV record: next" })
		vim.keymap.set("n", "<Left>", function()
			csv_open_record({ src = vim.b[buf].csv_src, index = vim.b[buf].csv_idx - 1 })
		end, { buffer = buf, desc = "CSV record: prev" })
		vim.keymap.set("n", "<leader>gi", function()
			csv_goto_record({ src = vim.b[buf].csv_src })
		end, { buffer = buf, desc = "CSV record: go to N" })
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

function csv_goto_record(opts)
	opts = opts or {}
	local n = tonumber(vim.fn.input("Go to record: "))
	if not n then
		return
	end
	csv_open_record({ src = opts.src, index = n - 1 }) -- 1-based (matches "record N / total")
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
		map("<leader>gi", function()
			csv_goto_record({ src = ev.buf })
		end, "CSV: go to record N")
		map("<leader>cv", "<cmd>CsvViewToggle<cr>", "CSV: toggle border grid")
	end,
})

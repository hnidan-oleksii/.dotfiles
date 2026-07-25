-- Strip ANSI SGR codes out of captured logs on read.
--
-- lib/ansi.c is ~5x faster than the Lua pattern matcher
-- but is x86-64 glibc only.

--- Build the C-backed stripper. Returns nil if unavailable for any reason.
---@return (fun(lines: string[]): boolean)|nil
local function load_c()
	local ok, ffi = pcall(require, "ffi")
	if not ok then
		return nil
	end

	local so = ("%s/lib/libansi-%s.so"):format(vim.fn.stdpath("config"), vim.uv.os_uname().machine)
	if vim.fn.filereadable(so) == 0 then
		return nil
	end

	ffi.cdef([[ size_t ansi_strip(char *buf, size_t len); ]])
	local loaded, lib = pcall(ffi.load, so)
	if not loaded then
		return nil
	end

	return function(lines)
		-- one scratch buffer, grown on demand
		local cap, scratch = 0, nil
		local changed = false

		for i = 1, #lines do
			local line = lines[i]
			if line:find("\27", 1, true) then
				local len = #line
				if len > cap then
					cap = len * 2
					scratch = ffi.new("char[?]", cap)
				end
				ffi.copy(scratch, line, len)

				local n = lib.ansi_strip(scratch, len)
				if n ~= len then
					lines[i] = ffi.string(scratch, n)
					changed = true
				end
			end
		end

		return changed
	end
end

--- Fallback stripper.
---@param lines string[] modified in place
---@return boolean changed
local function strip_lua(lines)
	local changed = false
	for i = 1, #lines do
		if lines[i]:find("\27", 1, true) then
			local new, n = lines[i]:gsub("\27%[[0-9;]*m", "")
			if n > 0 then
				lines[i] = new
				changed = true
			end
		end
	end
	return changed
end

local strip_lines = load_c() or strip_lua

--- Rewrite buf with every SGR sequence removed. Targets buf explicitly rather
--- than :%s, which would hit the current buffer - not always the one read.
local function strip(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	if not strip_lines(lines) then
		return
	end

	-- winsaveview reads the current window, which need not be showing buf
	local view = vim.api.nvim_get_current_buf() == buf and vim.fn.winsaveview() or nil
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	if view then
		vim.fn.winrestview(view)
	end
	vim.bo[buf].modified = false
end

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(ev)
		-- quick check, keeps ANSI-free files off the path
		for _, l in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, 200, false)) do
			if l:find("\27%[") then
				strip(ev.buf)
				break
			end
		end
	end,
})

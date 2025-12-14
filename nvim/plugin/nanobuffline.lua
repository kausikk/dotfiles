if _G.nbl_loaded then
	return
end
_G.nbl_loaded = true

local M = { buf = -1, lastmark = -1, ns_id = vim.api.nvim_create_namespace("_nbl") }

M.list_buffers = function(_)
	if M.buf == -1 or not vim.api.nvim_buf_is_valid(M.buf) then
		M.buf = -1
		M.nbl()
		return
	elseif vim.bo[M.buf].filetype ~= "_nbl" then
		M.buf = -1
		M.nbl()
		return
	end
	local buffers = { "  " }
	local curr_col = 2
	local hl_start = 0
	local hl_end = 0
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.fn.buflisted(buf) ~= 1 then
			goto next_iter
		end
		local name = vim.api.nvim_buf_get_name(buf)
		if name == "" then
			name = "no name"
		else
			name = vim.fn.fnamemodify(name, ":t")
		end
		if buf == vim.api.nvim_get_current_buf() then
			hl_start = curr_col
			hl_end = hl_start + #name
		end
		table.insert(buffers, name .. "  ")
		curr_col = curr_col + #name + 2
		::next_iter::
	end
	vim.bo[M.buf].readonly = false
	vim.api.nvim_buf_set_lines(M.buf, 0, 1, false, { table.concat(buffers, "") })
	if hl_end ~= hl_start then
		vim.api.nvim_buf_del_extmark(M.buf, M.ns_id, M.lastmark)
		M.lastmark = vim.api.nvim_buf_set_extmark(
			M.buf, M.ns_id, 0, hl_start,
			{ end_col = hl_end, hl_group = "Error" }
		)
		for _, win in ipairs(vim.fn.win_findbuf(M.buf)) do
			local pos = {}
			table.insert(pos, 1)
			table.insert(pos, hl_start)
			vim.api.nvim_win_set_cursor(win, pos)
		end
	end
	vim.bo[M.buf].readonly = true
end

M.nbl = function()
	if M.buf == -1 or not vim.api.nvim_buf_is_valid(M.buf) then
		M.buf = -1
	elseif vim.bo[M.buf].filetype ~= "_nbl" then
		M.buf = -1
	end
	if M.buf == -1 then
		M.buf = vim.api.nvim_create_buf(false, true)
		if M.buf == 0 then
			vim.notify("failed to create nbl", vim.log.levels.ERROR)
			M.buf = -1
			return
		end
		vim.bo[M.buf].readonly = true
		vim.bo[M.buf].filetype = "_nbl"
	end
	local win = vim.api.nvim_open_win(M.buf, false, {
		row = 0, col = 0, relative = "laststatus", height = 1,
		width = vim.o.columns, style = "minimal"
	})
	vim.wo[win].winfixheight = true
	vim.wo[win].winfixbuf = true
	M.list_buffers(nil)
end

vim.api.nvim_create_user_command("Nbl", M.nbl, { desc = "View open buffers in a small window" })
vim.api.nvim_create_autocmd("BufEnter", { callback = M.list_buffers })

M.nbl()

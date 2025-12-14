if _G.nbl_loaded then
	return
end
_G.nbl_loaded = true

local M = { buf = -1, buffers = {}, names = {}, columns = {}, lastmark = -1 }

NBL_ROW = 1
NS_ID = vim.api.nvim_create_namespace("_nbl_")

M.change_buffer = function(ev)
	local ibuf = 0 
	for i, buf in ipairs(M.buffers) do
		if buf == ev.buf then
			ibuf = i
			break
		end
	end
	if ibuf == 0 then
		return
	end
	vim.api.nvim_buf_del_extmark(M.buf, NS_ID, M.lastmark)
	local col = M.columns[ibuf] - #M.names[ibuf] + 2
	M.lastmark = vim.api.nvim_buf_set_extmark(
		M.buf, NS_ID, 0, col, { end_col = M.columns[ibuf], hl_group = "Error"
	})
	for _, win in ipairs(vim.fn.win_findbuf(M.buf)) do
		vim.api.nvim_win_set_cursor(win, { NBL_ROW, col })
	end
end

M.list_buffer = function(ev)
	if vim.fn.buflisted(ev.buf) ~= 1 then
		return
	end
	M.window()
	local name = vim.api.nvim_buf_get_name(ev.buf)
	if name == "" then
		name = "  no name"
	else
		name = "  " .. vim.fn.fnamemodify(name, ":t")
	end
	local last = 0
	if #M.columns > 0 then
		last = M.columns[#M.columns]
	end
	table.insert(M.buffers, ev.buf)
	table.insert(M.names, name)
	table.insert(M.columns, last + #name)
	vim.api.nvim_buf_set_lines(M.buf, 0, 1, false, { table.concat(M.names, "") })
	vim.bo[M.buf].modified = false
end

M.unlist_buffer = function(ev)
	if vim.fn.buflisted(ev.buf) ~= 1 then
		return
	end
	M.window()
	local ibuf = 0 
	for i, buf in ipairs(M.buffers) do
		if buf == ev.buf then
			ibuf = i
			break
		end
	end
	if ibuf == 0 then
		return
	end
	local shift = #M.names[ibuf]
	for i = ibuf + 1, #M.columns do
		M.columns[i] = M.columns[i] - shift
	end
	table.remove(M.buffers, ibuf)
	table.remove(M.names, ibuf)
	table.remove(M.columns, ibuf)
	vim.api.nvim_buf_set_lines(M.buf, 0, 1, false, { table.concat(M.names, "") })
	vim.bo[M.buf].modified = false
end

M.window = function()
	if vim.fn.bufwinid(M.buf) ~= -1 then
		return
	end
	if not vim.api.nvim_buf_is_valid(M.buf) then
		M.buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(M.buf, "_nbl_")
		vim.bo[M.buf].readonly = true
	end
	-- This fails when doing :%bd or :%bw, idk why, so wrap in pcall
	local res, win = pcall(vim.api.nvim_open_win, M.buf, false, {
		row = 0, col = 0, relative = "laststatus", height = 1,
		width = vim.o.columns - 20, style = "minimal"
	})
	if not res then
		return
	end
	vim.wo[win].winfixheight = true
	vim.wo[win].winfixbuf = true
end

vim.api.nvim_create_autocmd("BufEnter", { callback = M.change_buffer })
vim.api.nvim_create_autocmd("BufAdd", { callback = M.list_buffer })
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, { callback = M.unlist_buffer })

M.window()

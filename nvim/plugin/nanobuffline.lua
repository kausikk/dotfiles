if _G.nbl_loaded then
	return
end
_G.nbl_loaded = true

nbl_buf = -1
buffers = {}
names = {}
columns = {}
lastmark = -1
ns_id = vim.api.nvim_create_namespace("_nbl_")

_change_buffer = function(ev)
	local ibuf = 0 
	for i, buf in ipairs(buffers) do
		if buf == ev.buf then
			ibuf = i
			break
		end
	end
	if ibuf == 0 then
		return
	end
	vim.api.nvim_buf_del_extmark(nbl_buf, ns_id, lastmark)
	local col = columns[ibuf] - #names[ibuf] + 2
	lastmark = vim.api.nvim_buf_set_extmark(
		nbl_buf, ns_id, 0, col, { end_col = columns[ibuf], hl_group = "Error" }
	)
	local row = 1
	for _, win in ipairs(vim.fn.win_findbuf(nbl_buf)) do
		vim.api.nvim_win_set_cursor(win, { row, col })
	end
end

_list_buffer = function(ev)
	if vim.fn.buflisted(ev.buf) ~= 1 then
		return
	end
	_window()
	local name = vim.api.nvim_buf_get_name(ev.buf)
	if name == "" then
		name = "  no name"
	else
		name = "  " .. vim.fn.fnamemodify(name, ":t")
	end
	local last = 0
	if #columns > 0 then
		last = columns[#columns]
	end
	table.insert(buffers, ev.buf)
	table.insert(names, name)
	table.insert(columns, last + #name)
	vim.api.nvim_buf_set_lines(nbl_buf, 0, 1, false, { table.concat(names, "") })
	vim.bo[nbl_buf].modified = false
end

_unlist_buffer = function(ev)
	if vim.fn.buflisted(ev.buf) ~= 1 then
		return
	end
	_window()
	local ibuf = 0 
	for i, buf in ipairs(buffers) do
		if buf == ev.buf then
			ibuf = i
			break
		end
	end
	if ibuf == 0 then
		return
	end
	local shift = #names[ibuf]
	for i = ibuf + 1, #columns do
		columns[i] = columns[i] - shift
	end
	table.remove(buffers, ibuf)
	table.remove(names, ibuf)
	table.remove(columns, ibuf)
	vim.api.nvim_buf_set_lines(nbl_buf, 0, 1, false, { table.concat(names, "") })
	vim.bo[nbl_buf].modified = false
end

_window = function()
	if vim.fn.bufwinid(nbl_buf) ~= -1 then
		return
	end
	if not vim.api.nvim_buf_is_valid(nbl_buf) then
		nbl_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(nbl_buf, "_nbl_")
		vim.bo[nbl_buf].readonly = true
	end
	-- This fails when doing :%bd or :%bw, idk why, so wrap in pcall
	local res, win = pcall(vim.api.nvim_open_win, nbl_buf, false, {
		row = 0, col = 0, relative = "laststatus", height = 1,
		width = vim.o.columns - 20, style = "minimal"
	})
	if not res then
		return
	end
	vim.wo[win].winfixheight = true
	vim.wo[win].winfixbuf = true
end

vim.api.nvim_create_autocmd("BufEnter", { callback = _change_buffer })
vim.api.nvim_create_autocmd("BufAdd", { callback = _list_buffer })
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, { callback = _unlist_buffer })

_window()

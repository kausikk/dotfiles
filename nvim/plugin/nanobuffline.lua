local M = {}

vim.g.nanobuffline_status = ""
vim.opt.statusline = " %{%g:nanobuffline_status%}%=%l,%v nbl by krkm <3"
vim.opt.laststatus = 3

function M.generate_status(_)
	local status = { "" }
	for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
		if vim.fn.buflisted(buf_id) ~= 1 then
			goto next_iter
		end
		local name = vim.api.nvim_buf_get_name(buf_id)
		if name == "" then
			name = "no name"
		else
			name = vim.fn.fnamemodify(name, ":t")
		end
		if buf_id == vim.api.nvim_get_current_buf() then
			table.insert(status, " %#Label#" .. name .. "%*")
		else
			table.insert(status, " " .. name)
		end
		::next_iter::
	end
	vim.g.nanobuffline_status = table.concat(status, "")
end

vim.api.nvim_create_autocmd("BufEnter", { callback = M.generate_status })

return M

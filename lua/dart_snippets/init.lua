local M = {}
local private = {}

M.opts = {}

M.setup = function(opts)
	if opts then
		M.opts = vim.tbl_deep_extend("force", M.opts, opts)
	end

	private.init()

	-- vim.notify("hello world form dart_snippets", vim.log.levels.INFO)
end

private.init = function()
	vim.api.nvim_create_user_command("GenerateDataClass", function()
		private.generate_data_class()
	end, { desc = "Generate Data Class" })
end

private.read_buffer = function()
	return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

private.regexps = {
	class = [[[ ]*class ([a-zA-Z]+)]],
	datatype_and_variable = [[[ \t]*final[ \t\n\r]+([a-zA-Z\<\>\,\? ]+)[ \t\n\r]+([a-zA-Z\_]+);]],
}

private.class_data = {}

private.generate_data_class = function()
	private.find_class_names()
	private.find_class_dt_and_variables()
end

private.find_class_names = function()
	local content = private.read_buffer()

	local index = 1
	for _, line in ipairs(content) do
		local match = string.match(line, private.regexps.class)

		if match then
			private.class_data[index] = match
			index = index + 1
		end
	end

	for i, class in ipairs(private.class_data) do
		print(string.format("%d %s", i, class), vim.log.levels.INFO)
	end
end

private.find_class_dt_and_variables = function()
	local content = private.read_buffer()

	local all_d_v = {}
	local index = 1

	for _, line in ipairs(content) do
		for d, v in string.gmatch(line, private.regexps.datatype_and_variable) do
			all_d_v[index] = { d = d, v = v }
			index = index + 1
		end
	end

	print(vim.inspect(all_d_v))
end

return M

local M = {}
local private = {}

local generate_data_class = require("dart_snippets.generate_data_class")

M.opts = {
	data_class = {
		copy_with = true,
		to_map = true,
		from_map = true,
		to_json = true,
		from_json = true,
		to_string = true,
		hash_code = true,
		operator = true,
		props = true,
	},
}

M.setup = function(opts)
	if opts then
		M.opts = vim.tbl_deep_extend("force", M.opts, opts)
	end

	private.init()
end

private.init = function()
	vim.api.nvim_create_user_command("GenerateDartDataClass", function()
		generate_data_class.generate_dart_data_class(M.opts)
	end, { desc = "Generate Dart Data Class" })
end

return M

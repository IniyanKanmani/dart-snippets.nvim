local M = {}
local private = {}

local read_class = require("dart_snippets.read_class")
local copy_with = require("dart_snippets.copy_with")
local to_map = require("dart_snippets.to_map")

M.opts = {}

M.setup = function(opts)
	if opts then
		M.opts = vim.tbl_deep_extend("force", M.opts, opts)
	end

	private.init()

	vim.notify("Loaded dart_snippets.nvim", vim.log.levels.INFO)
end

private.init = function()
	vim.api.nvim_create_user_command("GenerateDataClass", function()
		private.generate_data_class()
	end, { desc = "Generate Data Class" })
end

private.data = {}

private.generate_data_class = function()
	private.data = read_class.find_class_and_d_v()
	copy_with.create_fun_copy_with(private.data)
	to_map.create_fun_to_map(private.data)
end

return M

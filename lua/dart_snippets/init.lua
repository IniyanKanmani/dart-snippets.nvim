local M = {}
local private = {}

local read_class = require("dart_snippets.read_class")
local copy_with = require("dart_snippets.copy_with")
local to_map = require("dart_snippets.to_map")
local from_map = require("dart_snippets.from_map")
local to_json = require("dart_snippets.to_json")
local from_json = require("dart_snippets.from_json")
local to_string = require("dart_snippets.to_string")
local hash_code = require("dart_snippets.hash_code")
local operator = require("dart_snippets.operator")
local props = require("dart_snippets.props")

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
	copy_with.generate_fun_copy_with(private.data)
	to_map.generate_fun_to_map(private.data)
	from_map.generate_fun_from_map(private.data)
		to_json.generate_fun_to_json()
		from_json.generate_fun_from_json(private.data)
		to_string.generate_fun_to_string(private.data)
		props.generate_fun_props(private.data)
		hash_code.generate_fun_hash_code(private.data)
		operator.generate_fun_operator(private.data)
end

return M

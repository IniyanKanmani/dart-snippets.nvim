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
		private.generate_dart_data_class()
	end, { desc = "Generate Dart Data Class" })
end

private.data = {}

private.generate_dart_data_class = function()
	private.data = read_class.find_class_and_d_v()

	for i, class_data in ipairs(private.data) do
		if M.opts.data_class.copy_with then
			private.data[i].copy_with = {}
			private.data[i].copy_with.function_code = copy_with.generate_fun_copy_with(class_data)
		end

		if M.opts.data_class.to_map then
			private.data[i].to_map = {}
			private.data[i].to_map.function_code = to_map.generate_fun_to_map(class_data)
		end

		if M.opts.data_class.from_map then
			private.data[i].from_map = {}
			private.data[i].from_map.function_code = from_map.generate_fun_from_map(class_data)
		end

		if M.opts.data_class.to_json then
			private.data[i].to_json = {}
			private.data[i].to_json.function_code = to_json.generate_fun_to_json()
		end

		if M.opts.data_class.from_json then
			private.data[i].from_json = {}
			private.data[i].from_json.function_code = from_json.generate_fun_from_json(class_data)
		end

		if M.opts.data_class.to_string then
			private.data[i].to_string = {}
			private.data[i].to_string.function_code = to_string.generate_fun_to_string(class_data)
		end

		if M.opts.data_class.hash_code then
			private.data[i].hash_code = {}
			private.data[i].hash_code.function_code = hash_code.generate_fun_hash_code(class_data)
		end

		if M.opts.data_class.operator then
			private.data[i].operator = {}
			private.data[i].operator.function_code = operator.generate_fun_operator(class_data)
		end

		if M.opts.data_class.props and class_data.equatable then
			private.data[i].props = {}
			private.data[i].props.function_code = props.generate_fun_props(class_data)
		end
	end
end

return M

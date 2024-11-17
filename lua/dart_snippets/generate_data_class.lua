local generate_data_class = {}
local private = {}

local utils = require("dart_snippets.utils")

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

local write_class = require("dart_snippets.write_class")

generate_data_class.generate_dart_data_class = function(opts)
	private.data = read_class.find_class()

	for i, class_data in ipairs(private.data) do
		if opts.data_class.copy_with then
			utils.op_list(private.data[i].f, "copy_with", "code_lines", copy_with.generate_fun_copy_with(class_data))
		end

		if opts.data_class.to_map then
			utils.op_list(private.data[i].f, "to_map", "code_lines", to_map.generate_fun_to_map(class_data))
		end

		if opts.data_class.from_map then
			utils.op_list(private.data[i].f, "from_map", "code_lines", from_map.generate_fun_from_map(class_data))
		end

		if opts.data_class.to_json then
			utils.op_list(private.data[i].f, "to_json", "code_lines", to_json.generate_fun_to_json())
		end

		if opts.data_class.from_json then
			utils.op_list(private.data[i].f, "from_json", "code_lines", from_json.generate_fun_from_json(class_data))
		end

		if opts.data_class.to_string then
			utils.op_list(private.data[i].f, "to_string", "code_lines", to_string.generate_fun_to_string(class_data))
		end

		if opts.data_class.hash_code and not class_data.class.equatable then
			utils.op_list(private.data[i].f, "hash_code", "code_lines", hash_code.generate_fun_hash_code(class_data))
		end

		if opts.data_class.operator and not class_data.class.equatable then
			utils.op_list(private.data[i].f, "operator", "code_lines", operator.generate_fun_operator(class_data))
		end

		if opts.data_class.props and class_data.class.equatable then
			utils.op_list(private.data[i].f, "props", "code_lines", props.generate_fun_props(class_data))
		end

		write_class.write_class_functions(opts, private.data[i])
	end
end

return generate_data_class

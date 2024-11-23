local generate_data_class = {}

local utils = require("dart_snippets.utils")

local read_buffer = require("dart_snippets.read_buffer")
local write_buffer = require("dart_snippets.write_buffer")

local copy_with = require("dart_snippets.copy_with")
local to_map = require("dart_snippets.to_map")
local from_map = require("dart_snippets.from_map")
local to_json = require("dart_snippets.to_json")
local from_json = require("dart_snippets.from_json")
local to_string = require("dart_snippets.to_string")
local hash_code = require("dart_snippets.hash_code")
local operator = require("dart_snippets.operator")
local props = require("dart_snippets.props")

generate_data_class.generate_dart_data_class = function(opts)
    local data = read_buffer.read()
    local has_written_a_class = false
    local prev_diff = 0

    for _, class_data in ipairs(data.classes) do
        if #class_data.d_v == 0 then
            vim.notify(
                string.format(
                    'dart-snippets.nvim: Could not find datatypes and variables for class "%s"',
                    class_data.class.name
                ),
                vim.log.levels.INFO
            )

            goto continue
        end

        has_written_a_class = true

        if opts.data_class.copy_with then
            utils.op_list(class_data.f, "copy_with", "code_lines", copy_with.generate_fun_copy_with(class_data))
        end

        if opts.data_class.to_map then
            utils.op_list(class_data.f, "to_map", "code_lines", to_map.generate_fun_to_map(class_data))
        end

        if opts.data_class.from_map then
            utils.op_list(class_data.f, "from_map", "code_lines", from_map.generate_fun_from_map(class_data))
        end

        if opts.data_class.to_json then
            utils.op_list(class_data.f, "to_json", "code_lines", to_json.generate_fun_to_json(class_data))
        end

        if opts.data_class.from_json then
            utils.op_list(class_data.f, "from_json", "code_lines", from_json.generate_fun_from_json(class_data))
        end

        if opts.data_class.to_string then
            utils.op_list(class_data.f, "to_string", "code_lines", to_string.generate_fun_to_string(class_data))
        end

        if opts.data_class.hash_code and not class_data.class.equatable then
            utils.op_list(class_data.f, "hash_code", "code_lines", hash_code.generate_fun_hash_code(class_data))
        end

        if opts.data_class.operator and not class_data.class.equatable then
            utils.op_list(class_data.f, "operator", "code_lines", operator.generate_fun_operator(class_data))
        end

        if opts.data_class.props and class_data.class.equatable then
            utils.op_list(class_data.f, "props", "code_lines", props.generate_fun_props(class_data))
        end

        prev_diff = write_buffer.write_functions(opts, class_data, prev_diff)

        ::continue::
    end

    if has_written_a_class then
        write_buffer.write_imports(opts, data.imports)
    end
end

return generate_data_class

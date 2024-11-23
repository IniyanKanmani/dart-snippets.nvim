local write_buffer = {}

write_buffer.function_order = {
    "copy_with",
    "to_map",
    "from_map",
    "to_json",
    "from_json",
    "to_string",
    "hash_code",
    "operator",
    "props",
}

write_buffer.write_imports = function(opts, import_data)
    if not import_data.equatable then
        if opts.data_class.props then
            vim.api.nvim_buf_set_lines(0, 0, 0, false, { "import 'package:equatable/equatable.dart';", "" })
        end
    end

    if not import_data.foundation then
        if opts.data_class.operator then
            vim.api.nvim_buf_set_lines(0, 0, 0, false, { "import 'package:flutter/foundation.dart';", "" })
        end
    end

    if not import_data.convert then
        if opts.data_class.to_json or opts.data_class.from_json then
            vim.api.nvim_buf_set_lines(0, 0, 0, false, { "import 'dart:convert';", "" })
        end
    end
end

write_buffer.remove_previous_functions = function(opts, class_data, prev_diff)
    local line_diff = 0 - prev_diff

    for _, f in ipairs(class_data.f) do
        if opts.data_class[f.name] then
            if f.start_line and f.end_line then
                local start_line = f.start_line - 1 - line_diff
                local end_line = f.end_line - line_diff

                vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})

                line_diff = line_diff + f.end_line - f.start_line + 1
            end
        end
    end

    return line_diff
end

write_buffer.write_functions = function(opts, class_data, prev_diff)
    -- Remove Previous Functions
    local line_diff = write_buffer.remove_previous_functions(opts, class_data, prev_diff)
    local end_line = class_data.class.end_line - 1 - line_diff

    -- Write New Functions
    for _, func in ipairs(write_buffer.function_order) do
        if opts.data_class[func] then
            for _, f in ipairs(class_data.f) do
                if f.name == func and f.code_lines then
                    vim.api.nvim_buf_set_lines(0, end_line, end_line, false, f.code_lines)

                    end_line = end_line + #f.code_lines

                    break
                end
            end
        end
    end

    return end_line + 1 - class_data.class.end_line
end

return write_buffer

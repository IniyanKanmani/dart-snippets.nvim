local write_class = {}

write_class.write_class_functions = function(opts, class_data)
	local end_line = class_data.end_line - 1

	if opts.data_class.copy_with then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.copy_with.code_lines)

		end_line = end_line + #class_data.copy_with.code_lines
	end

	if opts.data_class.to_map then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.to_map.code_lines)

		end_line = end_line + #class_data.to_map.code_lines
	end

	if opts.data_class.from_map then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.from_map.code_lines)

		end_line = end_line + #class_data.from_map.code_lines
	end

	if opts.data_class.to_json then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.to_json.code_lines)

		end_line = end_line + #class_data.to_json.code_lines
	end

	if opts.data_class.from_json then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.from_json.code_lines)

		end_line = end_line + #class_data.from_json.code_lines
	end

	if opts.data_class.to_string then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.to_string.code_lines)

		end_line = end_line + #class_data.to_string.code_lines
	end

	if opts.data_class.hash_code then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.hash_code.code_lines)

		end_line = end_line + #class_data.hash_code.code_lines
	end

	if opts.data_class.operator then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.operator.code_lines)

		end_line = end_line + #class_data.operator.code_lines
	end

	if opts.data_class.props and class_data.equatable then
		vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.props.code_lines)

		end_line = end_line + #class_data.props.code_lines
	end
end

return write_class

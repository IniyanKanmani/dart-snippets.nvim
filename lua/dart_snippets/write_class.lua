local write_class = {}

write_class.write_class_functions = function(opts, class_data)
	-- Remove Previous Functions
	local line_diff = write_class.remove_previous_functions(opts, class_data)

	local end_line = class_data.class.end_line - 1 - line_diff

	for _, f in ipairs(class_data.f) do
		if opts.data_class[f.name] then
			vim.api.nvim_buf_set_lines(0, end_line, end_line, false, f.code_lines)

			end_line = end_line + #f.code_lines
		end
	end

	-- if opts.data_class.copy_with then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.copy_with.code_lines)
	--
	-- 	end_line = end_line + #class_data.copy_with.code_lines
	-- end
	--
	-- if opts.data_class.to_map then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.to_map.code_lines)
	--
	-- 	end_line = end_line + #class_data.to_map.code_lines
	-- end
	--
	-- if opts.data_class.from_map then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.from_map.code_lines)
	--
	-- 	end_line = end_line + #class_data.from_map.code_lines
	-- end
	--
	-- if opts.data_class.to_json then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.to_json.code_lines)
	--
	-- 	end_line = end_line + #class_data.to_json.code_lines
	-- end
	--
	-- if opts.data_class.from_json then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.from_json.code_lines)
	--
	-- 	end_line = end_line + #class_data.from_json.code_lines
	-- end
	--
	-- if opts.data_class.to_string then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.to_string.code_lines)
	--
	-- 	end_line = end_line + #class_data.to_string.code_lines
	-- end
	--
	-- if opts.data_class.hash_code then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.hash_code.code_lines)
	--
	-- 	end_line = end_line + #class_data.hash_code.code_lines
	-- end
	--
	-- if opts.data_class.operator then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.operator.code_lines)
	--
	-- 	end_line = end_line + #class_data.operator.code_lines
	-- end
	--
	-- if opts.data_class.props and class_data.class.equatable then
	-- 	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, class_data.props.code_lines)
	--
	-- 	end_line = end_line + #class_data.props.code_lines
	-- end
end

write_class.remove_previous_functions = function(opts, class_data)
	local line_diff = 0

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

	-- if opts.data_class.copy_with then
	-- 	if class_data.copy_with.start_line and class_data.copy_with.end_line then
	-- 		local start_line = class_data.copy_with.start_line - 1 - line_diff
	-- 		local end_line = class_data.copy_with.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.copy_with.end_line - class_data.copy_with.start_line + 1
	-- 	end
	-- end
	--
	-- if opts.data_class.to_map then
	-- 	if class_data.to_map.start_line and class_data.to_map.end_line then
	-- 		local start_line = class_data.to_map.start_line - 1 - line_diff
	-- 		local end_line = class_data.to_map.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.to_map.end_line - class_data.to_map.start_line + 1
	-- 	end
	-- end
	--
	-- if opts.data_class.from_map then
	-- 	if class_data.from_map.start_line and class_data.from_map.end_line then
	-- 		local start_line = class_data.from_map.start_line - 1 - line_diff
	-- 		local end_line = class_data.from_map.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.from_map.end_line - class_data.from_map.start_line + 1
	-- 	end
	-- end
	--
	-- if opts.data_class.to_json then
	-- 	if class_data.to_json.start_line and class_data.to_json.end_line then
	-- 		local start_line = class_data.to_json.start_line - 1 - line_diff
	-- 		local end_line = class_data.to_json.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.to_json.end_line - class_data.to_json.start_line + 1
	-- 	end
	-- end
	--
	-- if opts.data_class.from_json then
	-- 	if class_data.from_json.start_line and class_data.from_json.end_line then
	-- 		local start_line = class_data.from_json.start_line - 1 - line_diff
	-- 		local end_line = class_data.from_json.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.from_json.end_line - class_data.from_json.start_line + 1
	-- 	end
	-- end
	--
	-- if opts.data_class.to_string then
	-- 	if class_data.to_string.start_line and class_data.to_string.end_line then
	-- 		local start_line = class_data.to_string.start_line - 1 - line_diff
	-- 		local end_line = class_data.to_string.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.to_string.end_line - class_data.to_string.start_line + 1
	-- 	end
	-- end
	--
	-- if opts.data_class.hash_code then
	-- 	if class_data.hash_code.start_line and class_data.hash_code.end_line then
	-- 		local start_line = class_data.hash_code.start_line - 1 - line_diff
	-- 		local end_line = class_data.hash_code.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.hash_code.end_line - class_data.hash_code.start_line + 1
	-- 	end
	-- end
	--
	-- if opts.data_class.operator then
	-- 	if class_data.operator.start_line and class_data.operator.end_line then
	-- 		local start_line = class_data.operator.start_line - 1 - line_diff
	-- 		local end_line = class_data.operator.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.operator.end_line - class_data.operator.start_line + 1
	-- 	end
	-- end
	--
	-- if opts.data_class.props and class_data.class.equatable then
	-- 	if class_data.props.start_line and class_data.props.end_line then
	-- 		local start_line = class_data.props.start_line - 1 - line_diff
	-- 		local end_line = class_data.props.end_line - line_diff
	--
	-- 		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})
	--
	-- 		line_diff = line_diff + class_data.props.end_line - class_data.props.start_line + 1
	-- 	end
	-- end

	return line_diff
end

return write_class

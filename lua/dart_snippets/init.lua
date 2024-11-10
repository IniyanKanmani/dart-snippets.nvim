local M = {}
local private = {}

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

private.read_buffer = function()
	return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

private.regexps = {
	class = "class ([a-zA-Z]+)",
	opening_b = "{",
	final = "[ \t]*(final)",
	datatype_1 = "[ \t]final ([a-zA-Z<>,? ]+) [a-zA-Z_]+;$",
	datatype_2 = "[ \t]final ([a-zA-Z<>,? ]+)$",
	variable = "([a-zA-Z_]+);",
	semicolon = ";",
	closing_b = "}",
}

private.class_data = {}

private.generate_data_class = function()
	private.find_class_and_d_v()
end

private.find_class_and_d_v = function()
	local content = private.read_buffer()

	local class_index = 0
	local curly_counter = 0
	local d_v_counter = 0

	local inside_class = false
	local seen_final = false
	local datatype_name = nil
	local is_nullable = nil
	local variable_name = nil

	for _, line in ipairs(content) do
		local class_match = string.gmatch(line, private.regexps.class)

		-- Check for class match
		for c in class_match do
			inside_class = true
			class_index = class_index + 1

			table.insert(private.class_data, class_index, {
				class = c,
			})
		end

		-- Check for Opening "{"
		if inside_class then
			local opening_b_match = string.gmatch(line, private.regexps.opening_b)

			for _ in opening_b_match do
				curly_counter = curly_counter + 1
			end
		end

		-- Check for final
		if inside_class then
			local final_match = string.gmatch(line, private.regexps.final)

			for _ in final_match do
				seen_final = true
			end
		end

		-- Check for datatype
		if inside_class and seen_final then
			local datatype1_match = string.gmatch(line, private.regexps.datatype_1)

			for d in datatype1_match do
				datatype_name = d

				local null_check = string.match(d, "?$")

				if null_check then
					is_nullable = true
					datatype_name = string.sub(d, 1, #d - 1)
				end

				break
			end

			local datatype2_match = string.gmatch(line, private.regexps.datatype_2)

			for d in datatype2_match do
				datatype_name = d

				local null_check = string.match(d, "?$")

				if null_check then
					is_nullable = true
					datatype_name = string.sub(d, 1, #d - 1)
				end

				break
			end
		end

		-- Check for variable
		if inside_class and seen_final and datatype_name then
			local variable_match = string.gmatch(line, private.regexps.variable)

			for v in variable_match do
				variable_name = v
				break
			end
		end

		-- Check for semicolon
		if inside_class and seen_final and datatype_name and variable_name then
			local semicolon_match = string.gmatch(line, private.regexps.semicolon)

			for _ in semicolon_match do
				d_v_counter = d_v_counter + 1

				if d_v_counter == 1 then
					private.class_data[class_index].d_v = {}
				end

				table.insert(private.class_data[class_index].d_v, d_v_counter, {
					d = datatype_name,
					v = variable_name,
					null = is_nullable and true or false,
				})

				variable_name = nil
				is_nullable = nil
				datatype_name = nil
				seen_final = false
			end
		end

		-- Check for Closing "}"
		if inside_class then
			local closing_b_match = string.gmatch(line, private.regexps.closing_b)

			for _ in closing_b_match do
				curly_counter = curly_counter - 1

				if curly_counter == 0 then
					d_v_counter = 0
					inside_class = false
				end
			end
		end
	end

	vim.notify(vim.inspect(private.class_data), vim.log.levels.INFO)
end



		end
	end

end

return M

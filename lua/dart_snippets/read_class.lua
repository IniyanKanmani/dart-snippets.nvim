local read_class = {}

local utils = require("dart_snippets.utils")

read_class.data = {}

read_class.regexps = {
	class = "class ([a-zA-Z]+)",
	extends = "[ ]*(extends)[ ]*",
	equatable = "[ ]*(Equatable)[ ]*",
	opening_b = "{",
	final = "[ \t]*(final) ",
	datatype_1 = "[ \t]final ([a-zA-Z<>,? ]+) [a-zA-Z_]+;$",
	datatype_2 = "[ \t]final ([a-zA-Z<>,? ]+)$",
	variable = "([a-zA-Z_]+);",
	semicolon = ";",
	closing_b = "}",
}

read_class.read_buffer = function()
	return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

read_class.find_class_and_d_v = function()
	local content = read_class.read_buffer()

	local class_index = 0
	local curly_counter = 0
	local d_v_counter = 0

	local seen_class = false
	local seen_extends = false
	local seen_final = false
	local datatype_name = nil
	local nullable = nil
	local variable_name = nil

	for i, line in ipairs(content) do
		-- Check for class match
		if curly_counter == 0 then
			local class_match = string.gmatch(line, read_class.regexps.class)

			for c in class_match do
				seen_class = true
				class_index = class_index + 1

				table.insert(read_class.data, class_index, {
					class = c,
				})

				break
			end
		end

		-- Check for extends
		if seen_class and not seen_extends then
			local extends_match = string.gmatch(line, read_class.regexps.extends)

			for _ in extends_match do
				seen_extends = true

				break
			end
		end

		-- Check for Equatable
		if seen_class and seen_extends then
			local equatable_match = string.gmatch(line, read_class.regexps.equatable)

			for _ in equatable_match do
				read_class.data[class_index].equatable = true

				if seen_extends then
					seen_extends = false
				end

				break
			end
		end

		-- Check for Opening "{"
		if seen_class then
			local opening_b_match = string.gmatch(line, read_class.regexps.opening_b)

			for _ in opening_b_match do
				curly_counter = curly_counter + 1

				if curly_counter == 1 then
					read_class.data[class_index].start_line = i
				end
			end
		end

		-- Check for final
		if seen_class then
			local final_match = string.gmatch(line, read_class.regexps.final)

			for _ in final_match do
				seen_final = true
			end
		end

		-- Check for datatype
		if seen_class and seen_final then
			local datatype1_match = string.gmatch(line, read_class.regexps.datatype_1)

			for d in datatype1_match do
				local null_check = utils.null_check(d)

				nullable = null_check.nullable
				datatype_name = null_check.value

				break
			end

			local datatype2_match = string.gmatch(line, read_class.regexps.datatype_2)

			for d in datatype2_match do
				local null_check = utils.null_check(d)

				nullable = null_check.nullable
				datatype_name = null_check.value

				break
			end
		end

		-- Check for variable
		if seen_class and seen_final and datatype_name then
			local variable_match = string.gmatch(line, read_class.regexps.variable)

			for v in variable_match do
				variable_name = v
				break
			end
		end

		-- Check for semicolon
		if seen_class and seen_final and datatype_name and variable_name then
			local semicolon_match = string.gmatch(line, read_class.regexps.semicolon)

			for _ in semicolon_match do
				d_v_counter = d_v_counter + 1

				if d_v_counter == 1 then
					read_class.data[class_index].d_v = {}
				end

				table.insert(read_class.data[class_index].d_v, d_v_counter, {
					d = datatype_name,
					v = variable_name,
					nullable = nullable,
				})

				variable_name = nil
				nullable = nil
				datatype_name = nil
				seen_final = false
			end
		end

		-- Check for Closing "}"
		if seen_class then
			local closing_b_match = string.gmatch(line, read_class.regexps.closing_b)

			for _ in closing_b_match do
				curly_counter = curly_counter - 1

				if curly_counter == 1 then
					read_class.data[class_index].end_line = i
				end

				if curly_counter == 0 then
					d_v_counter = 0
					seen_class = false
				end
			end
		end
	end

	vim.notify(vim.inspect(read_class.data), vim.log.levels.INFO)

	return read_class.data
end

return read_class

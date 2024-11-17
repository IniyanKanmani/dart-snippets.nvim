local read_class = {}

local utils = require("dart_snippets.utils")

read_class.regexps = {
	class = "class ([a-zA-Z_]+)",
	extends = "[ ]*(extends)[ ]*",
	equatable = "[ ]*(Equatable)[ ]*",

	opening_b = "{",

	final = "[ \t]*(final) ",
	datatype_1 = "[ \t]*final ([a-zA-Z_<>,? ]+) [a-zA-Z_]+;$",
	datatype_2 = "[ \t]*final ([a-zA-Z_<>,? ]+)$",
	variable = "([a-zA-Z_]+);",
	semicolon = ";",

	empty_line = "^%s*$",

	override = "[ \t]*@override",
	one_line_return = "=>",

	copy_with = "[ \t]*[a-zA-Z_]+[ ]+copyWith",
	to_map = "[ \t]*Map.*[ ]+toMap",
	from_map = "[ \t]*factory[ ]+.*fromMap",
	to_json = "[ \t]*String[ ]+toJson",
	from_json = "[ \t]*factory[ ]+.*fromJson",
	to_string = "[ \t]*String[ ]+toString",
	hash_code = "[ \t]*int[ ]+get[ ]+hashCode",
	operator = "[ \t]*bool[ ]+operator[ ]*==",
	props = "[ \t]*.*[ ]+get[ ]+props",

	closing_b = "}",
}

read_class.read_buffer = function()
	return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

read_class.find_class = function()
	read_class.data = {}

	local content = read_class.read_buffer()

	local class_index = 0
	local curly_counter = 0
	local d_v_counter = 0
	local f_counter = 0
	local empty_line_counter = 0

	local seen_class = false
	local seen_extends = false
	local seen_final = false
	local seen_one_line_return = false

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
					class = {
						name = c,
					},
					d_v = {},
					f = {},
				})

				break
			end
		end

		-- Check for empty line and override
		-- override = empty line
		if seen_class then
			local empty_line_match = string.match(line, read_class.regexps.empty_line)
			local override_match = string.match(line, read_class.regexps.override)

			if empty_line_match or override_match then
				empty_line_counter = empty_line_counter + 1
			end
		end

		-- Check copy_with
		if seen_class then
			local copy_with_match = string.gmatch(line, read_class.regexps.copy_with)

			for _ in copy_with_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "copy_with",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check to_map
		if seen_class then
			local to_map_match = string.gmatch(line, read_class.regexps.to_map)

			for _ in to_map_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "to_map",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check from_map
		if seen_class then
			local from_map_match = string.gmatch(line, read_class.regexps.from_map)

			for _ in from_map_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "from_map",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check to_json
		if seen_class then
			local to_json_match = string.gmatch(line, read_class.regexps.to_json)

			for _ in to_json_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "to_json",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check from_json
		if seen_class then
			local from_json_match = string.gmatch(line, read_class.regexps.from_json)

			for _ in from_json_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "from_json",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check to_string
		if seen_class then
			local to_string_match = string.gmatch(line, read_class.regexps.to_string)

			for _ in to_string_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "to_string",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check hash_code
		if seen_class then
			local hash_code_match = string.gmatch(line, read_class.regexps.hash_code)

			for _ in hash_code_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "hash_code",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check operator
		if seen_class then
			local operator_match = string.gmatch(line, read_class.regexps.operator)

			for _ in operator_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "operator",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check props
		if seen_class then
			local props_match = string.gmatch(line, read_class.regexps.props)

			for _ in props_match do
				if curly_counter == 1 then
					f_counter = f_counter + 1

					table.insert(read_class.data[class_index].f, {
						name = "props",
						start_line = i - empty_line_counter,
					})
				end

				break
			end
		end

		-- Check for one line return
		if seen_class then
			local one_line_return_match = string.gmatch(line, read_class.regexps.one_line_return)

			for _ in one_line_return_match do
				seen_one_line_return = true
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
				read_class.data[class_index].class.equatable = true

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
					read_class.data[class_index].class.start_line = i
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
		if seen_class then
			local semicolon_match = string.gmatch(line, read_class.regexps.semicolon)

			for _ in semicolon_match do
				if seen_final and datatype_name and variable_name then
					d_v_counter = d_v_counter + 1

					table.insert(read_class.data[class_index].d_v, {
						d = datatype_name,
						v = variable_name,
						nullable = nullable,
					})

					variable_name = nil
					nullable = nil
					datatype_name = nil
					seen_final = false
				elseif seen_one_line_return then
					seen_one_line_return = false

					if f_counter > 0 then
						read_class.data[class_index].f[f_counter].end_line = i
					end
				end
			end
		end

		-- Check for Closing "}"
		if seen_class then
			local closing_b_match = string.gmatch(line, read_class.regexps.closing_b)

			for _ in closing_b_match do
				curly_counter = curly_counter - 1

				if curly_counter == 1 then
					if f_counter > 0 then
						read_class.data[class_index].f[f_counter].end_line = i
					end
				end

				if curly_counter == 0 then
					d_v_counter = 0
					f_counter = 0
					seen_class = false
					read_class.data[class_index].class.end_line = i
				end
			end
		end

		-- Check for not empty line or override
		-- override = empty line
		if seen_class then
			local empty_line_match = string.match(line, read_class.regexps.empty_line)
			local override_match = string.match(line, read_class.regexps.override)

			if not empty_line_match and not override_match then
				empty_line_counter = 0
			end
		end
	end

	vim.notify(vim.inspect(read_class.data), vim.log.levels.INFO)

	return read_class.data
end

return read_class

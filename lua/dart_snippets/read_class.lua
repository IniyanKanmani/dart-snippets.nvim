local read_class = {}

local utils = require("dart_snippets.utils")

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

	override = [[[ ]*@override]],
	copy_with = [[[ ]+copyWith]],
	to_map = [[[ ]+toMap]],
	from_map = [[[ ]*factory.*fromMap]],
	to_json = [[[ ]+toJson]],
	from_json = [[[ ]*factory.*fromJson]],
	to_string = [[[ ]+toString]],
	hash_code = [[[ ]+hashCode]],
	operator = [[[ ]+operator[ ]*==]],
	props = [[[ ]+props]],

	closing_b = "}",
}

read_class.read_buffer = function()
	return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

read_class.find_class_and_d_v = function()
	read_class.data = {}

	local content = read_class.read_buffer()

	local class_index = 0
	local curly_counter = 0
	local d_v_counter = 0

	local seen = {
		seen_class = false,
		seen_extends = false,
		seen_final = false,

		seen_copy_with = false,
		seen_to_map = false,
		seen_from_map = false,
		seen_to_json = false,
		seen_from_json = false,
		seen_to_string = false,
		seen_hash_code = false,
		seen_operator = false,
		seen_props = false,
	}

	local datatype_name = nil
	local nullable = nil
	local variable_name = nil

	for i, line in ipairs(content) do
		-- Check for class match
		if curly_counter == 0 then
			local class_match = string.gmatch(line, read_class.regexps.class)

			for c in class_match do
				seen.seen_class = true
				class_index = class_index + 1

				table.insert(read_class.data, class_index, {
					class = {
						name = c,
					},
					f = {},
				})

				break
			end
		end

		-- Check copy_with
		if seen.seen_class and not seen.seen_copy_with then
			local copy_with_match = string.gmatch(line, read_class.regexps.copy_with)

			for _ in copy_with_match do
				if curly_counter == 1 then
					seen.seen_copy_with = true

					table.insert(read_class.data[class_index].f, {
						copy_with = {
							start_line = i,
						},
					})

					-- read_class.data[class_index].f.copy_with = {
					-- 	start_line = i,
					-- }
				end

				break
			end
		end

		-- Check to_map
		if seen.seen_class and not seen.seen_to_map then
			local to_map_match = string.gmatch(line, read_class.regexps.to_map)

			for _ in to_map_match do
				if curly_counter == 1 then
					seen.seen_to_map = true

					table.insert(read_class.data[class_index].f, {
						to_map = {
							start_line = i,
						},
					})

					-- read_class.data[class_index].f.to_map = {
					-- 	start_line = i,
					-- }
				end

				break
			end
		end

		-- Check from_map
		if seen.seen_class and not seen.seen_from_map then
			local from_map_match = string.gmatch(line, read_class.regexps.from_map)

			for _ in from_map_match do
				if curly_counter == 1 then
					seen.seen_from_map = true

					table.insert(read_class.data[class_index].f, {
						from_map = {
							start_line = i,
						},
					})

					-- read_class.data[class_index].f.from_map = {
					-- 	start_line = i,
					-- }
				end

				break
			end
		end

		-- Check to_json
		if seen.seen_class and not seen.seen_to_json then
			local to_json_match = string.gmatch(line, read_class.regexps.to_json)

			for _ in to_json_match do
				if curly_counter == 1 then
					seen.seen_to_json = true

					table.insert(read_class.data[class_index].f, {
						to_json = {
							start_line = i,
						},
					})

					-- read_class.data[class_index].f.to_json = {
					-- 	start_line = i,
					-- }
				end

				break
			end
		end

		-- Check from_json
		if seen.seen_class and not seen.seen_from_json then
			local from_json_match = string.gmatch(line, read_class.regexps.from_json)

			for _ in from_json_match do
				if curly_counter == 1 then
					seen.seen_from_json = true

					table.insert(read_class.data[class_index].f, {
						from_json = {
							start_line = i,
						},
					})

					-- read_class.data[class_index].f.from_json = {
					-- 	start_line = i,
					-- }
				end

				break
			end
		end

		-- Check to_string
		if seen.seen_class and not seen.seen_to_string then
			local to_string_match = string.gmatch(line, read_class.regexps.to_string)

			for _ in to_string_match do
				if curly_counter == 1 then
					seen.seen_to_string = true

					table.insert(read_class.data[class_index].f, {
						to_string = {
							start_line = i - 1,
						},
					})

					-- read_class.data[class_index].f.to_string = {
					-- 	start_line = i - 1,
					-- }
				end

				break
			end
		end

		-- Check hash_code
		if seen.seen_class and not seen.seen_hash_code then
			local hash_code_match = string.gmatch(line, read_class.regexps.hash_code)

			for _ in hash_code_match do
				if curly_counter == 1 then
					seen.seen_hash_code = true

					table.insert(read_class.data[class_index].f, {
						hash_code = {
							start_line = i - 1,
						},
					})

					-- read_class.data[class_index].f.hash_code = {
					-- 	start_line = i - 1,
					-- }
				end

				break
			end
		end

		-- Check operator
		if seen.seen_class and not seen.seen_operator then
			local operator_match = string.gmatch(line, read_class.regexps.operator)

			for _ in operator_match do
				if curly_counter == 1 then
					seen.seen_operator = true

					table.insert(read_class.data[class_index].f, {
						operator = {
							start_line = i - 1,
						},
					})

					-- read_class.data[class_index].f.operator = {
					-- 	start_line = i - 1,
					-- }
				end

				break
			end
		end

		-- Check props
		if seen.seen_class and not seen.seen_props then
			local props_match = string.gmatch(line, read_class.regexps.props)

			for _ in props_match do
				if curly_counter == 1 then
					seen.seen_props = true

					table.insert(read_class.data[class_index].f, {
						props = {
							start_line = i - 1,
						},
					})

					-- read_class.data[class_index].f.props = {
					-- 	start_line = i - 1,
					-- }
				end

				break
			end
		end

		-- Check for extends
		if seen.seen_class and not seen.seen_extends then
			local extends_match = string.gmatch(line, read_class.regexps.extends)

			for _ in extends_match do
				seen.seen_extends = true

				break
			end
		end

		-- Check for Equatable
		if seen.seen_class and seen.seen_extends then
			local equatable_match = string.gmatch(line, read_class.regexps.equatable)

			for _ in equatable_match do
				read_class.data[class_index].class.equatable = true

				if seen.seen_extends then
					seen.seen_extends = false
				end

				break
			end
		end

		-- Check for Opening "{"
		if seen.seen_class then
			local opening_b_match = string.gmatch(line, read_class.regexps.opening_b)

			for _ in opening_b_match do
				curly_counter = curly_counter + 1

				if curly_counter == 1 then
					read_class.data[class_index].class.start_line = i
				end
			end
		end

		-- Check for final
		if seen.seen_class then
			local final_match = string.gmatch(line, read_class.regexps.final)

			for _ in final_match do
				seen.seen_final = true
			end
		end

		-- Check for datatype
		if seen.seen_class and seen.seen_final then
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
		if seen.seen_class and seen.seen_final and datatype_name then
			local variable_match = string.gmatch(line, read_class.regexps.variable)

			for v in variable_match do
				variable_name = v
				break
			end
		end

		-- Check for semicolon
		if seen.seen_class and seen.seen_final and datatype_name and variable_name then
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
				seen.seen_final = false
			end
		end

		-- Check for Closing "}"
		if seen.seen_class then
			local closing_b_match = string.gmatch(line, read_class.regexps.closing_b)

			for _ in closing_b_match do
				curly_counter = curly_counter - 1

				if curly_counter == 1 then
					if seen.seen_copy_with then
						seen.seen_copy_with = false

						utils.list_replace(read_class.data[class_index].f, "copy_with", "end_line", i)

						-- read_class.data[class_index].f.copy_with.end_line = i
					elseif seen.seen_to_map then
						seen.seen_to_map = false

						utils.list_replace(read_class.data[class_index].f, "to_map", "end_line", i)

						-- read_class.data[class_index].f.to_map.end_line = i
					elseif seen.seen_from_map then
						seen.seen_from_map = false

						utils.list_replace(read_class.data[class_index].f, "from_map", "end_line", i)

						-- read_class.data[class_index].f.from_map.end_line = i
					elseif seen.seen_to_json then
						seen.seen_to_json = false

						utils.list_replace(read_class.data[class_index].f, "to_json", "end_line", i)

						-- read_class.data[class_index].f.to_json.end_line = i
					elseif seen.seen_from_json then
						seen.seen_from_json = false

						utils.list_replace(read_class.data[class_index].f, "from_json", "end_line", i)

						-- read_class.data[class_index].f.from_json.end_line = i
					elseif seen.seen_to_string then
						seen.seen_to_string = false

						utils.list_replace(read_class.data[class_index].f, "to_string", "end_line", i)

						-- read_class.data[class_index].f.to_string.end_line = i
					elseif seen.seen_hash_code then
						seen.seen_hash_code = false

						utils.list_replace(read_class.data[class_index].f, "hash_code", "end_line", i)

						-- read_class.data[class_index].f.hash_code.end_line = i
					elseif seen.seen_operator then
						seen.seen_operator = false

						utils.list_replace(read_class.data[class_index].f, "operator", "end_line", i)

						-- read_class.data[class_index].f.operator.end_line = i
					elseif seen.seen_props then
						seen.seen_props = false

						utils.list_replace(read_class.data[class_index].f, "props", "end_line", i)

						-- read_class.data[class_index].f.props.end_line = i
					end
				end

				if curly_counter == 0 then
					d_v_counter = 0
					seen.seen_class = false
					read_class.data[class_index].class.end_line = i
				end
			end
		end
	end

	vim.notify(vim.inspect(read_class.data), vim.log.levels.INFO)

	return read_class.data
end

return read_class

local to_map = {}

local utils = require("dart_snippets.utils")

to_map.generate_fun_to_map = function(class_data)
	local to_map_code_lines = {}
	local to_map_string = ""

	if class_data.d_v then
		local to_map_return = {}
		for _, d_v in ipairs(class_data.d_v) do
			table.insert(
				to_map_return,
				string.format(
					'"%s": %s,',
					utils.to_lower_snake_case(d_v.v),
					to_map.handle_datatypes(d_v.d, d_v.v, d_v.nullable)
				)
			)
		end

		to_map_string = string.format(
			[[
	Map<String, dynamic> toMap() {
		return <String, dynamic>{
			%s
		};
	}
			]],
			table.concat(to_map_return, "\n\t\t\t")
		)
	end

	if to_map_string ~= "" then
		table.insert(to_map_code_lines, "")

		for line in string.gmatch(to_map_string, "[^\r\n]+") do
			table.insert(to_map_code_lines, line)
		end

		table.remove(to_map_code_lines, #to_map_code_lines)
	end

	return to_map_code_lines
end

to_map.handle_datatypes = function(datatype, variable, nullable)
	local variable_value = ""

	if nullable then
		datatype = string.format("%s?", datatype)
	end

	-- breakdown datatype
	local datatype_data = utils.breakdown_datatype(datatype)
	-- print(vim.inspect(datatype_data))

	-- get variable value
	variable_value = to_map.get_variable_value(datatype_data[1], variable)

	return variable_value
end

to_map.get_variable_value = function(datatype_data, variable_value)
	if datatype_data.child then
		if datatype_data.parent == "List" then
			local child_value = to_map.get_variable_value(datatype_data.child[1], "e")

			local s = ""
			if child_value == "e" then
				s = string.format("%s", variable_value)
			else
				s = string.format(
					"%s%s.map((e) => %s).toList()",
					variable_value,
					datatype_data.nullable and "?" or "",
					child_value
				)
			end

			variable_value = s
		elseif datatype_data.parent == "Set" then
			local child_value = to_map.get_variable_value(datatype_data.child[1], "e")

			local s = ""
			if child_value == "e" then
				s = string.format("%s.toList()", variable_value)
			else
				s = string.format(
					"%s%s.map((e) => %s).toList()",
					variable_value,
					datatype_data.nullable and "?" or "",
					child_value
				)
			end

			variable_value = s
		elseif datatype_data.parent == "Map" then
			local child1_value = to_map.get_variable_value(datatype_data.child[1], "k")
			local child2_value = to_map.get_variable_value(datatype_data.child[2], "v")

			local s = ""
			if child1_value == "k" and child2_value == "v" then
				s = string.format("%s", variable_value)
			else
				s = string.format(
					"%s%s.map((k, v) => MapEntry(%s, %s))",
					variable_value,
					datatype_data.nullable and "?" or "",
					child1_value,
					child2_value
				)
			end

			variable_value = s
		end
	else
		if
			not utils.contains(
				{ "int", "double", "Number", "String", "bool", "null", "DateTime", "dynamic", "Object" },
				datatype_data.parent
			)
		then
			variable_value = string.format("%s%s.toMap()", variable_value, datatype_data.nullable and "?" or "")
		else
			variable_value = string.format("%s", variable_value)
		end
	end

	return variable_value
end

return to_map

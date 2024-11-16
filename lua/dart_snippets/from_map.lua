local from_map = {}

local utils = require("dart_snippets.utils")

from_map.generate_fun_from_map = function(class_data)
	local from_map_code_lines = {}
	local from_map_string = ""

	if class_data.d_v then
		local from_map_return = {}

		for _, d_v in ipairs(class_data.d_v) do
			table.insert(from_map_return, string.format("%s: %s,", d_v.v, from_map.handle_datatypes(d_v.d, d_v.v)))
		end

		from_map_string = string.format(
			[[
	factory %s.fromMap(Map<String, dynamic> map) {
		return %s(
			%s
		);
	}
			]],
			class_data.class,
			class_data.class,
			table.concat(from_map_return, "\n\t\t\t")
		)
	end

	if from_map_string ~= "" then
		table.insert(from_map_code_lines, "")

		for line in string.gmatch(from_map_string, "[^\r\n]+") do
			table.insert(from_map_code_lines, line)
		end

		table.remove(from_map_code_lines, #from_map_code_lines)
	end

	return from_map_code_lines
end

from_map.handle_datatypes = function(datatype, variable)
	local variable_value = ""

	-- breakdown datatype
	local datatype_data = utils.breakdown_datatype(datatype)

	-- get variable value
	variable_value =
		from_map.get_variable_value(datatype_data[1], string.format('map["%s"]', utils.to_lower_snake_case(variable)))

	return variable_value
end

from_map.get_sub_datatype_value = function(datatype_data)
	local datatype = utils.join_datatype(datatype_data)

	if string.sub(datatype, #datatype) == "?" then
		datatype = string.sub(datatype, 1, #datatype - 1)
	end

	return datatype
end

from_map.get_variable_value = function(datatype_data, variable_value)
	if datatype_data.child then
		if datatype_data.parent == "List" then
			local child_value = ""
			local s = ""

			if
				not utils.contains(
					{ "int", "double", "Number", "String", "bool", "null", "DateTime", "dynamic", "Object" },
					datatype_data.child[1].parent
				)
			then
				child_value = from_map.get_variable_value(datatype_data.child[1], "e")
				s = string.format(
					"%s.from(%s.map((e) => %s))",
					from_map.get_sub_datatype_value(datatype_data),
					variable_value,
					child_value
				)
			else
				s = string.format("%s.from(%s)", from_map.get_sub_datatype_value(datatype_data), variable_value)
			end

			if datatype_data.nullable then
				s = string.format("%s != null ? %s : null", variable_value, s)
			end

			variable_value = s
		elseif datatype_data.parent == "Set" then
			local child_value = ""
			local s = ""

			if
				not utils.contains(
					{ "int", "double", "Number", "String", "bool", "null", "DateTime", "dynamic", "Object" },
					datatype_data.child[1].parent
				)
			then
				child_value = from_map.get_variable_value(datatype_data.child[1], "e")
				s = string.format(
					"%s.from(%s.map((e) => %s))",
					from_map.get_sub_datatype_value(datatype_data),
					variable_value,
					child_value
				)
				child_value = from_map.get_variable_value(datatype_data.child[1], "e")
			else
				s = string.format("%s.from(%s)", from_map.get_sub_datatype_value(datatype_data), variable_value)
			end

			if datatype_data.nullable then
				s = string.format("%s != null ? %s : null", variable_value, s)
			end

			variable_value = s
		elseif datatype_data.parent == "Map" then
			local child1_value = ""
			local child2_value = ""
			local s = ""

			if
				not utils.contains(
					{ "int", "double", "Number", "String", "bool", "null", "DateTime", "dynamic", "Object" },
					datatype_data.child[1].parent
				)
				or not utils.contains(
					{ "int", "double", "Number", "String", "bool", "null", "DateTime", "dynamic", "Object" },
					datatype_data.child[2].parent
				)
			then
				child1_value = from_map.get_variable_value(datatype_data.child[1], "k")
				child2_value = from_map.get_variable_value(datatype_data.child[2], "v")

				s = string.format(
					"%s.from(%s.map((k, v) => MapEntry(%s, %s)))",
					from_map.get_sub_datatype_value(datatype_data),
					variable_value,
					child1_value,
					child2_value
				)
			else
				s = string.format("%s.from(%s)", from_map.get_sub_datatype_value(datatype_data), variable_value)
			end

			if datatype_data.nullable then
				s = string.format("%s != null ? %s : null", variable_value, s)
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
			local s = string.format("%s.fromMap(%s)", datatype_data.parent, variable_value)

			if datatype_data.nullable then
				s = string.format("%s != null ? %s : null", variable_value, s)
			end

			variable_value = s
		else
			variable_value = string.format("%s", variable_value)
		end
	end

	return variable_value
end

return from_map

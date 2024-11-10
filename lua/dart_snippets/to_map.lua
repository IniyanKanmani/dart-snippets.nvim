local to_map = {}

local utils = require("dart_snippets.utils")

to_map.create_fun_to_map = function(data)
	for _, class_data in ipairs(data) do
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

			local to_map_string = string.format(
				[[
	Map<String, dynamic> toMap() {
		return <String, dynamic>{
			%s
		};
	}
				]],
				table.concat(to_map_return, "\n\t\t\t")
			)

			vim.notify(to_map_string, vim.log.levels.INFO)
		end
	end
end

to_map.handle_datatypes = function(datatype, variable, nullable)
	local variable_value = ""

	if nullable then
		datatype = string.format("%s?", datatype)
	end

	-- breakdown datatype
	local datatype_data = to_map.breakdown_datatype(datatype)

	-- get variable value
	variable_value = to_map.get_variable_value(datatype_data[1], variable)

	return variable_value
end

to_map.breakdown_datatype = function(datatype)
	local datatype_split = {}

	for c in string.gmatch(datatype, ".") do
		table.insert(datatype_split, c)
	end

	local datatype_data = {}
	local seen = ""

	for i, c in ipairs(datatype_split) do
		if c == "<" then
			local advanced_null_check = utils.advanced_null_check(string.sub(datatype, i + 1))

			table.insert(datatype_data, {
				parent = seen,
				nullable = advanced_null_check.nullable,
				child = to_map.breakdown_datatype(advanced_null_check.value),
			})

			return datatype_data
		elseif c == ">" then
			local null_check = utils.null_check(seen)

			table.insert(datatype_data, {
				parent = null_check.value,
				nullable = null_check.nullable,
			})

			return datatype_data
		elseif c == "," then
			local null_check = utils.null_check(seen)

			table.insert(datatype_data, {
				parent = null_check.value,
				nullable = null_check.nullable,
			})

			seen = ""
		elseif c == " " then
			-- continue
		else
			seen = string.format("%s%s", seen, c)
		end
	end

	local null_check = utils.null_check(seen)

	table.insert(datatype_data, {
		parent = null_check.value,
		nullable = null_check.nullable,
	})

	return datatype_data
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
				s = string.format("%s", variable_value)
			else
				s = string.format(
					"%s%s.map((e) => %s)",
					variable_value,
					datatype_data.nullable and "?" or "",
					child_value
				)
			end

			variable_value = string.format("%s.toList()", s)
		elseif datatype_data.parent == "Map" then
			local child1_value = to_map.get_variable_value(datatype_data.child[1], "k")
			local child2_value = to_map.get_variable_value(datatype_data.child[2], "v")

			variable_value = string.format(
				"%s%s.map((k, v) => MapEntry(%s, %s))",
				variable_value,
				datatype_data.nullable and "?" or "",
				child1_value,
				child2_value
			)
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

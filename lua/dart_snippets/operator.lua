local operator = {}

local utils = require("dart_snippets.utils")

operator.generate_fun_operator = function(class_data)
	local operator_code_lines = {}
	local operator_string = ""

	if class_data.d_v then
		local operator_return = {}

		for _, d_v in ipairs(class_data.d_v) do
			table.insert(operator_return, string.format("%s", operator.handle_datatypes(d_v.d, d_v.v)))
		end

		operator_string = string.format(
			[[
	@override
	bool operator ==(covariant %s other) {
		if (identical(this, other)) return true;
		return
			%s;
	}
			]],
			class_data.class.name,
			table.concat(operator_return, " &&\n\t\t\t")
		)

		if operator_string ~= "" then
			table.insert(operator_code_lines, "")

			for line in string.gmatch(operator_string, "[^\r\n]+") do
				table.insert(operator_code_lines, line)
			end

			table.remove(operator_code_lines, #operator_code_lines)
		end
	end

	return operator_code_lines
end

operator.handle_datatypes = function(datatype, variable)
	local variable_value = ""

	-- breakdown datatype
	local datatype_data = utils.breakdown_datatype(datatype)

	-- get variable value
	variable_value = operator.get_variable_value(datatype_data[1], variable)

	return variable_value
end

operator.get_variable_value = function(datatype_data, variable_value)
	local s = ""

	if datatype_data.parent == "List" then
		s = string.format("listEquals(other.%s, %s)", variable_value, variable_value)
	elseif datatype_data.parent == "Set" then
		s = string.format("setEquals(other.%s, %s)", variable_value, variable_value)
	elseif datatype_data.parent == "Map" then
		s = string.format("mapEquals(other.%s, %s)", variable_value, variable_value)
	else
		s = string.format("other.%s == %s", variable_value, variable_value)
	end

	return s
end

return operator

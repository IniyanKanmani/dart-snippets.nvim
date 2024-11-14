local operator = {}

local utils = require("dart_snippets.utils")

operator.generate_fun_operator = function(data)
	for _, class_data in ipairs(data) do
		if class_data.d_v then
			local operator_return = {}

			for _, d_v in ipairs(class_data.d_v) do
				table.insert(operator_return, string.format("%s", operator.handle_datatypes(d_v.d, d_v.v)))
			end

			local operator_string = string.format(
				[[
	@override
	bool operator ==(covariant %s other) {
		if (identical(this, other)) return true;

		return
			%s;
	}
			]],
				class_data.class,
				table.concat(operator_return, " &&\n\t\t\t")
			)

			vim.notify(operator_string, vim.log.levels.INFO)
		end
	end
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

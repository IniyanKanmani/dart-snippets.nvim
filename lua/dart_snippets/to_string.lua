local to_string = {}

to_string.generate_fun_to_string = function(class_data)
	local to_string_code_lines = {}
	local to_string_string = ""

	if class_data.d_v then
		local to_string_return = {}

		for _, d_v in ipairs(class_data.d_v) do
			table.insert(to_string_return, string.format("%s : %s", d_v.v, d_v.v))
		end

		to_string_string = string.format(
			[[
	@override
	String toString() {
		return "%s(%s)";
	} 
			]],
			class_data.class.name,
			table.concat(to_string_return, ", ")
		)

		if to_string_string ~= "" then
			table.insert(to_string_code_lines, "")

			for line in string.gmatch(to_string_string, "[^\r\n]+") do
				table.insert(to_string_code_lines, line)
			end

			table.remove(to_string_code_lines, #to_string_code_lines)
		end
	end

	return to_string_code_lines
end

return to_string

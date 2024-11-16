local from_json = {}

from_json.generate_fun_from_json = function(class_data)
	local from_json_code_lines = {}
	local from_json_string = string.format(
		[[
	factory %s.fromJson(String source) {
		return %s.fromMap(json.decode(source) as Map<String, dynamic>);
	}
		]],
		class_data.class.name,
		class_data.class.name
	)

	if from_json_string ~= "" then
		table.insert(from_json_code_lines, "")

		for line in string.gmatch(from_json_string, "[^\r\n]+") do
			table.insert(from_json_code_lines, line)
		end

		table.remove(from_json_code_lines, #from_json_code_lines)
	end

	return from_json_code_lines
end

return from_json

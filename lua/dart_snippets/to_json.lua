local to_json = {}

to_json.generate_fun_to_json = function()
	local to_json_code_lines = {}
	local to_json_string = string.format([[
	String toJson() => json.encode(toMap());
		]])

	if to_json_string ~= "" then
		table.insert(to_json_code_lines, "")

		for line in string.gmatch(to_json_string, "[^\r\n]+") do
			table.insert(to_json_code_lines, line)
		end

		table.remove(to_json_code_lines, #to_json_code_lines)
	end

	return to_json_code_lines
end

return to_json

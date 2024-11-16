local hash_code = {}

hash_code.generate_fun_hash_code = function(class_data)
	local hash_code_code_lines = {}
	local hash_code_string = ""

	if class_data.d_v then
		local hash_code_return = {}

		for _, d_v in ipairs(class_data.d_v) do
			table.insert(hash_code_return, string.format("%s.hashCode", d_v.v))
		end

		hash_code_string = string.format(
			[[
	@override
	int get hashCode {
		return %s;
	}
			]],
			table.concat(hash_code_return, " ^\n\t\t\t")
		)

		if hash_code_string ~= "" then
			table.insert(hash_code_code_lines, "")

			for line in string.gmatch(hash_code_string, "[^\r\n]+") do
				table.insert(hash_code_code_lines, line)
			end

			table.remove(hash_code_code_lines, #hash_code_code_lines)
		end
	end

	return hash_code_code_lines
end

return hash_code

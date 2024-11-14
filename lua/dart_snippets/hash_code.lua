local hash_code = {}

hash_code.generate_fun_hash_code = function(data)
	for _, class_data in ipairs(data) do
		if class_data.d_v then
			local hash_code_return = {}

			for _, d_v in ipairs(class_data.d_v) do
				table.insert(hash_code_return, string.format("%s.hashCode", d_v.v))
			end

			local hash_code_string = string.format(
				[[
	@override
	int get hashCode =>
			%s;
				]],
				table.concat(hash_code_return, " ^\n\t\t\t")
			)

			vim.notify(hash_code_string, vim.log.levels.INFO)
		end
	end
end

return hash_code

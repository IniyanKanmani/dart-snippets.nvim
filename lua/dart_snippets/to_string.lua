local to_string = {}

to_string.generate_fun_to_string = function(data)
	for _, class_data in ipairs(data) do
		if class_data.d_v then
			local to_string_return = {}

			for _, d_v in ipairs(class_data.d_v) do
				table.insert(to_string_return, string.format("%s : %s,", d_v.v, d_v.v))
			end

			local to_string_string = string.format(
				[[
	@override
	String toString() => "%s";
				]],
				table.concat(to_string_return, " ")
			)

			vim.notify(to_string_string, vim.log.levels.INFO)
		end
	end
end

return to_string

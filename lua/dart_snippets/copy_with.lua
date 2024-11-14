local copy_with = {}

copy_with.generate_fun_copy_with = function(class_data)
	local copy_with_string = ""

	if class_data.d_v then
		-- copy_with parameters
		local copy_with_parameters = {}
		for _, d_v in ipairs(class_data.d_v) do
			table.insert(copy_with_parameters, string.format("%s? %s,", d_v.d, d_v.v))
		end

		-- copy_with return
		local copy_with_return = {}
		for _, d_v in ipairs(class_data.d_v) do
			table.insert(copy_with_return, string.format("%s: %s ?? this.%s,", d_v.v, d_v.v, d_v.v))
		end

		copy_with_string = string.format(
			[[
	%s copyWith({
		%s
	}) {
		return %s(
			%s
		);
	}
				]],
			class_data.class,
			table.concat(copy_with_parameters, "\n\t\t"),
			class_data.class,
			table.concat(copy_with_return, "\n\t\t\t")
		)

		copy_with.function_string = copy_with_string

		vim.notify(copy_with_string, vim.log.levels.INFO)
	end

	return copy_with_string
end

return copy_with

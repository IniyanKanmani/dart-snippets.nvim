local props = {}

props.generate_fun_props = function(data)
	for _, class_data in ipairs(data) do
		if class_data.d_v then
			local props_return = {}
			local any_is_nullable = false

			for _, d_v in ipairs(class_data.d_v) do
				table.insert(props_return, string.format("%s,", d_v.v))

				if d_v.nullable and not any_is_nullable then
					any_is_nullable = true
				end
			end

			local props_string = string.format(
				[[
	@override
	List<Object%s> get props => [
			%s
		];
				]],
				any_is_nullable and "?" or "",
				table.concat(props_return, "\n\t\t\t")
			)

			vim.notify(props_string, vim.log.levels.INFO)
		end
	end
end

return props

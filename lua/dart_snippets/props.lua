local props = {}

props.generate_fun_props = function(class_data)
	local props_code_lines = {}
	local props_string = ""

	if #class_data.d_v > 0 then
		local props_return = {}
		local any_is_nullable = false

		for _, d_v in ipairs(class_data.d_v) do
			table.insert(props_return, string.format("%s,", d_v.v))

			if d_v.nullable and not any_is_nullable then
				any_is_nullable = true
			end
		end

		props_string = string.format(
			[[
  @override
  List<Object%s> get props {
    return [
      %s
    ];
  }
			]],
			any_is_nullable and "?" or "",
			table.concat(props_return, "\n      ")
		)

		if props_string ~= "" then
			table.insert(props_code_lines, "")

			for line in string.gmatch(props_string, "[^\r\n]+") do
				table.insert(props_code_lines, line)
			end

			table.remove(props_code_lines, #props_code_lines)
		end
	end

	return props_code_lines
end

return props

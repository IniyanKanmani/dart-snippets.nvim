local from_json = {}

from_json.generate_fun_from_json = function(class_data)
	local from_json_string = string.format(
		[[
	factory %s.fromJson(String source) => %s.fromMap(json.decode(source) as Map<String, dynamic>);
			]],
		class_data.class,
		class_data.class
	)

	vim.notify(from_json_string, vim.log.levels.INFO)

	return from_json_string
end

return from_json

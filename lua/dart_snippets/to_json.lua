local to_json = {}

to_json.generate_fun_to_json = function()
	local to_json_string = string.format([[
	String toJson() => json.encode(toMap());
		]])

	vim.notify(to_json_string, vim.log.levels.INFO)

	return to_json_string
end

return to_json

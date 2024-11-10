local utils = {}

utils.to_lower_snake_case = function(value)
	local new_value = ""
	for c in string.gmatch(value, ".") do
		if string.match(c, "[A-Z]") then
			new_value = string.format("%s_%s", new_value, string.lower(c))
		else
			new_value = string.format("%s%s", new_value, c)
		end
	end

	return new_value
end

utils.contains = function(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end

	return false
end

utils.null_check = function(value)
	local nullable = false

	if string.match(value, "?$") then
		nullable = true
		value = string.sub(value, 1, #value - 1)
	end

	return {
		nullable = nullable,
		value = value,
	}
end

utils.advanced_null_check = function(datatype)
	local datatype_reversed = string.reverse(datatype)

	local i = string.find(datatype_reversed, ">")

	if i == 1 then
		return {
			value = string.sub(datatype, 1, #datatype - 1),
			nullable = false,
		}
	elseif i == 2 and string.sub(datatype_reversed, 1, 1) == "?" then
		return {
			value = string.sub(datatype, 1, #datatype - 2),
			nullable = true,
		}
	end
end

return utils

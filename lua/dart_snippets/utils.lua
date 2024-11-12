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

utils.breakdown_datatype = function(datatype)
	local datatype_split = {}

	for c in string.gmatch(datatype, ".") do
		table.insert(datatype_split, c)
	end

	local datatype_data = {}
	local seen = ""

	for i, c in ipairs(datatype_split) do
		if c == "<" then
			local advanced_null_check = utils.advanced_null_check(string.sub(datatype, i + 1))

			table.insert(datatype_data, {
				parent = seen,
				nullable = advanced_null_check.nullable,
				child = utils.breakdown_datatype(advanced_null_check.value),
			})

			return datatype_data
		elseif c == ">" then
			local null_check = utils.null_check(seen)

			table.insert(datatype_data, {
				parent = null_check.value,
				nullable = null_check.nullable,
			})

			return datatype_data
		elseif c == "," then
			local null_check = utils.null_check(seen)

			table.insert(datatype_data, {
				parent = null_check.value,
				nullable = null_check.nullable,
			})

			seen = ""
		elseif c == " " then
			-- continue
		else
			seen = string.format("%s%s", seen, c)
		end
	end

	local null_check = utils.null_check(seen)

	table.insert(datatype_data, {
		parent = null_check.value,
		nullable = null_check.nullable,
	})

	return datatype_data
end

utils.join_datatype = function(datatype_data)
	local d = ""

	if datatype_data.child then
		if datatype_data.parent == "List" then
			d = string.format(
				"%s<%s>%s",
				datatype_data.parent,
				utils.join_datatype(datatype_data.child[1]),
				datatype_data.nullable and "?" or ""
			)
		elseif datatype_data.parent == "Set" then
			d = string.format(
				"%s<%s>%s",
				datatype_data.parent,
				utils.join_datatype(datatype_data.child[1]),
				datatype_data.nullable and "?" or ""
			)
		elseif datatype_data.parent == "Map" then
			d = string.format(
				"%s<%s, %s>%s",
				datatype_data.parent,
				utils.join_datatype(datatype_data.child[1]),
				utils.join_datatype(datatype_data.child[2]),
				datatype_data.nullable and "?" or ""
			)
		end
	else
		d = string.format("%s%s", datatype_data.parent, datatype_data.nullable and "?" or "")
	end

	return d
end

return utils

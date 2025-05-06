local log_path = "/tmp/sketchybar.log"

local logger = {}

local objToString = function(obj)
	local str = ""
	for k, v in pairs(obj) do
		str = str .. k .. ": " .. tostring(v) .. ","
	end
	return str
end

function logger.log(...)
	local log_file = io.open(log_path, "a")

	local args = { ... }
	local value = ""

	for _, v in ipairs(args) do
		if type(v) == "table" then
			value = value .. "{" .. objToString(v) .. "}, "
		else
			value = value .. tostring(v) .. ", "
		end
	end

	if log_file then
		log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. value .. "\n")
		log_file:flush()
		log_file:close()
	end
end

return logger

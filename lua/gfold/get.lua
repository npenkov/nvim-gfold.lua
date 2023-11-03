local settings = require("gfold.settings")
local Job = require("plenary.job")

local get_repos = function(callback, condition)
	local jsonStr = ""
	local parse_result = function(rawJson)
		if jsonStr == "" then
			vim.notify_once(
				"Warning (gfold.nvim): takes too long to fetch the repositories or no repositories found !",
				vim.log.levels.WARN
			)
			return {}
		end
		local ret = vim.fn.json_decode(rawJson)
		local filtered = {}
		for _, v in pairs(ret) do
			v.status = v.status:lower()
			v.path = v.parent .. "/" .. v.name
			v.remote = v.url
			v.user = v.email
			if condition == nil or condition(v) then
				filtered[#filtered + 1] = v
			end
		end
		return filtered
	end
	local job = Job:new({
		command = "gfold",
		args = { "--display-mode", "json" },
		cwd = settings.cwd,
		enable_recording = false,
		buffer_output = false,
		on_stdout = function(_, line, _)
			jsonStr = jsonStr .. line .. "\n"
		end,
		on_stderr = function(_, data, _)
			if settings.no_error then
				return
			end
			local text = data .. "\n"
			if text ~= "" then
				vim.notify_once("Error (gfold.nvim): " .. text, vim.log.levels.WARN)
			end
		end,
	})
	job:sync(settings.timeout)
	local res = parse_result(jsonStr)
	vim.schedule(function()
		callback(res)
	end)
end

return {
	get_repos = get_repos,
}

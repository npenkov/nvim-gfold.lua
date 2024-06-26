local settings = require("gfold.settings")
local utils = require("gfold.utils")

local update_settings = function(user_opts)
	utils.recursive_tbl_update(settings, user_opts)
end

local setup = function(user_opts)
	update_settings(user_opts)
	if settings.status.enable then
		require("gfold.status").update_summary()
	end
end

local pick_repo = function(condition)
	return require("gfold.picker").pick_repo(condition)
end

local pick_repo_and = function(condition, func)
	return require("gfold.picker").pick_repo_and(condition, func)
end

local get_summary = function()
	return require("gfold.status").get_summary()
end

return {
	setup = setup,
	pick_repo = pick_repo,
	pick_repo_and = pick_repo_and,
	get_summary = get_summary,
}

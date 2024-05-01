local settings = require("gfold.settings")
local get_repos = require("gfold.get").get_repos

-- This can wrap pick_repo_and with default on select function
local pick_repo = function(condition)
	get_repos(function(repos)
		vim.ui.select(repos, {
			prompt = "gfold",
			format_item = settings.picker.format_item,
			kind = "gfold",
		}, settings.picker.on_select)
	end, condition)
end

local pick_repo_and = function(condition, func)
	get_repos(function(repos)
		vim.ui.select(repos, {
			prompt = "gfold",
			format_item = settings.picker.format_item,
			kind = "gfold",
		}, func)
	end, condition)
end

return {
	pick_repo = pick_repo,
	pick_repo_and = pick_repo_and,
}

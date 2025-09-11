data:extend({
	{
		type = "int-setting",
		name = "clones-start-of-game-count",
		setting_type = "runtime-global",
		default_value = 0,
		order = "a",
	},
	{
		type = "bool-setting",
		name = "clones-enable-technology",
		setting_type = "startup",
		default_value = true,
		order = "b",
	},
	{
		type = "bool-setting",
		name = "clones-always-enable-cloning-recipe",
		setting_type = "startup",
		default_value = false,
		order = "c",
	},
})

data:extend({
	{
		type = "recipe-category",
		name = "hand-crafting",
	},
	{
		type = "custom-input",
		name = "clones-switch-character",
		key_sequence = "CONTROL + TAB",
		consuming = "game-only",
		action = "lua",
	},
	{
		type = "custom-input",
		name = "clones-switch-character-reverse",
		key_sequence = "CONTROL + SHIFT + TAB",
		consuming = "game-only",
		action = "lua",
	},
	{
		type = "recipe",
		name = "clones-clone",
		icon = "__Clones__/graphics/icons/cloning.png",
		enabled = settings.startup["clones-always-enable-cloning-recipe"].value,
		energy_required = 4,
		-- energy_required = 1,
		ingredients = {
			{ type = "item", name = "nutrients", amount = 50 },
			{ type = "item", name = "bioflux", amount = 25 },
		},
		results = { { type = "item", name = "clones-clone", amount = 1 } },
		category = "hand-crafting",
		subgroup = "transport",
		order = "a",
	},
	{
		type = "item",
		name = "clones-clone",
		icon = "__Clones__/graphics/icons/cloning.png",
		--icon = data.raw.character.character.icon,
		--icon_size = data.raw.character.character.icon_size or 64,
		subgroup = "intermediate-product",
		order = "h[clones-clone]",
		stack_size = 1,
	},
})

if settings.startup["clones-enable-technology"].value then
	data:extend({
		{
			type = "technology",
			name = "character-cloning",
			icon = "__Clones__/graphics/technology/clones-technology.png",
			icon_size = 256,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "clones-clone",
				},
			},
			prerequisites = { "agricultural-science-pack" },
			unit = {
				count = 1000,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "space-science-pack", 1 },
					{ "agricultural-science-pack", 1 },
				},
				time = 60,
			},
		},
	})
end

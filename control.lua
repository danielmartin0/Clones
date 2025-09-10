local Public = {}

local WARN_COLOR = { r = 255, g = 90, b = 54 }

script.on_event(defines.events.on_player_crafted_item, function(event)
	if not (event.item_stack and event.item_stack.valid and event.item_stack.valid_for_read) then
		return
	end

	local name = event.item_stack.name
	if name ~= "clones-clone" then
		return
	end

	local quality = event.item_stack.quality

	local player = game.players[event.player_index]
	if not (player and player.character and player.character.valid) then
		return
	end

	player.remove_item({ name = name, quality = quality, count = 1 })

	local crafting_queue = player.crafting_queue
	if crafting_queue then
		for i = #crafting_queue, 1, -1 do
			local craft = crafting_queue[i]
			if craft.recipe == "clones-clone" then
				local recipe = prototypes.recipe["clones-clone"]
				local ingredients = recipe.ingredients

				player.cancel_crafting({ index = i, count = craft.count })

				for _, ingredient in pairs(ingredients) do
					player.insert({
						name = ingredient.name,
						count = ingredient.amount * craft.count,
						quality = quality,
					})
				end
			end
		end
	end

	storage.characters = storage.characters or {}
	storage.characters[player.index] = storage.characters[player.index] or {}

	local current_character = player.character
	local current_character_found = false
	local current_index = 1
	for i, char in ipairs(storage.characters[player.index]) do
		if char == current_character then
			current_character_found = true
			current_index = i
			break
		end
	end

	if not current_character_found then
		table.insert(storage.characters[player.index], current_character)
		current_index = #storage.characters[player.index]
	end

	local pos = player.surface.find_non_colliding_position("character", player.position, 100, 1)
	if pos then
		local clone = player.surface.create_entity({
			name = player.character.name,
			position = pos,
			force = player.force,
		})

		table.insert(storage.characters[player.index], current_index + 1, clone)

		local next_character = Public.get_next_character(player.index, current_character)
		Public.switch_to_character(player, next_character)
	end
end)

script.on_event("clones-switch-character", function(event)
	local player = game.players[event.player_index]
	storage.characters = storage.characters or {}
	if not (player and player.character and storage.characters[player.index]) then
		return
	end

	local next_character = Public.get_next_character(player.index, player.character)
	if next_character ~= player.character then
		Public.switch_to_character(player, next_character)
	else
		player.print("[Whisper] No next character found.", { color = WARN_COLOR })
	end
end)

script.on_event("clones-switch-character-reverse", function(event)
	local player = game.players[event.player_index]
	storage.characters = storage.characters or {}
	if not (player and player.character and storage.characters[player.index]) then
		return
	end

	local previous_character = Public.get_next_character(player.index, player.character, true)
	if previous_character ~= player.character then
		Public.switch_to_character(player, previous_character)
	else
		player.print("[Whisper] No previous character found.", { color = WARN_COLOR })
	end
end)

script.on_event(defines.events.on_pre_player_died, function(event)
	local player = game.players[event.player_index]
	local previous_character = Public.get_next_character(player.index, player.character, true)

	if previous_character then
		Public.switch_to_character(player, previous_character)
	end
end)

script.on_event(defines.events.on_player_controller_changed, function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then
		return
	end

	local controller = player.physical_controller_type
	if controller ~= defines.controllers.character then
		return
	end

	local entity = player.character
	if not (entity and entity.valid) then
		return
	end

	Public.register_character_if_missing(player.index, entity)
end)

function Public.register_character_if_missing(player_index, character)
	storage.characters = storage.characters or {}
	storage.characters[player_index] = storage.characters[player_index] or {}

	local found = false
	for _, char in ipairs(storage.characters[player_index]) do
		if char == character then
			found = true
			break
		end
	end

	if not found then
		table.insert(storage.characters[player_index], character)
	end
end

function Public.get_next_character(player_index, current_character, backwards)
	storage.characters = storage.characters or {}
	local characters = storage.characters[player_index]

	if not characters or #characters == 0 then
		return
	end

	local valid_characters = {}
	for _, char in ipairs(characters) do
		if char and char.valid then
			table.insert(valid_characters, char)
		end
	end

	if #valid_characters == 0 then
		return nil
	end

	local current_index = 1
	for i, char in ipairs(valid_characters) do
		if char == current_character then
			current_index = i
			break
		end
	end

	local next_index
	if backwards then
		next_index = ((current_index - 2 + #valid_characters) % #valid_characters) + 1
	else
		next_index = current_index % #valid_characters + 1
	end

	storage.characters[player_index] = valid_characters

	return valid_characters[next_index]
end

function Public.switch_to_character(player, target_character)
	if not (player and target_character and target_character.valid) then
		return
	end

	if player.character then
		Public.register_character_if_missing(player.index, player.character)
	end

	player.set_controller({
		type = defines.controllers.remote,
	})

	player.set_controller({
		type = defines.controllers.god,
	})

	local target_surface = target_character.surface

	player.teleport(target_character.position, target_surface)

	player.set_controller({
		type = defines.controllers.character,
		character = target_character,
	})

	if
		target_surface.platform
		and target_surface.platform.valid
		and target_surface.platform.hub
		and target_surface.platform.hub.valid
	then
		player.enter_space_platform(target_surface.platform)
	end
end

return Public

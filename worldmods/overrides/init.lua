sneak_enabled = true
sneak_glitch_enabled = false

minetest.override_item("bakedclay:dark_grey", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1}
})

minetest.override_item("bakedclay:brown", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1}
})

minetest.override_item("bakedclay:dark_green", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1, bouncy = 100, disable_jump = 1}
})

minetest.override_item("bakedclay:violet", {
	sunlight_propogates = true,
	walkable = false,
	groups = {cracky = 1}
})

minetest.override_item("bakedclay:yellow", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1, disable_jump = 1}
})

minetest.override_item("bakedclay:cyan", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1, disable_jump = 1}
})

minetest.override_item("bakedclay:blue", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1}
})

minetest.override_item("bakedclay:red", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1}
})

minetest.override_item("bakedclay:orange", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1}
})

minetest.override_item("bakedclay:green", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1}
})

minetest.override_item("bakedclay:black", {
	sunlight_propogates = true,
	groups = {fall_damage_add_percent = -100, cracky = 1}
})

local function get_wool(oper, bool)
	if oper == 0 and bool then
		return "wool:green"
	elseif oper == 0 and not bool then
		return "wool:red"
	elseif oper == 1 and bool then
		return "wool:yellow"
	elseif oper == 1 and not bool then
		return "wool:orange"
	end
end

local function pos_is(name, pos)
	local p = minetest.get_player_by_name(name)
	if not p and pos then return false end
	local rnd_pos = vector.round(p:getpos())
	pos = vector.round(pos)
	
	if rnd_pos.x == pos.x and rnd_pos.y == pos.y and rnd_pos.z == pos.z then
		return true
	else
		return false
	end
end

local timer = 0
local end_lvl = {
	{x = 2, y = 0, z = 0}, -- Hub
	{x = 16, y = 4, z = -69}, -- Level 1
	{x = 3, y = 8, z = -32}, -- Level 2
	{x = 28, y = 14, z = -62}, -- Level 3
	{x = 1, y = 8, z = -88}, -- Level 4
	{x = 58, y = 17, z = 56}, -- Level 5
	{x = 75, y = 20, z = -108}, -- Level 6
	{x = 107, y = 20, z = 19}, -- Level 7
	{x = 80, y = 52, z = 22}, -- Level 8
	{x = 109, y = 18, z = -62}, -- Level 9
	{x = -51, y = 15, z = 51}, -- Level 10
}

local level = {
	{x = 15, y = 4.5, z = -9}, --  Level 1
	{x = -19, y = 7.5, z = 27}, -- Level 2
	{x = 2, y = 14.5, z = 13}, -- Level 3
	{x = -26, y = 12.5, z = -41}, -- Level 4
	{x = 25, y = 14.5, z = 30}, -- Level 5
	{x = 16, y = 19.5, z = -105}, -- Level 6
	{x = 48, y = 22.5, z = 17}, -- Level 7
	{x = 48, y = 22.5, z = -7}, -- Level 8
	{x = 58, y = 17.5, z = -58}, -- Level 9
	{x = -37, y = 9.5, z = 65}, -- Level 10
	{x = -68, y = 10.5, z = 25}, -- Map End
}

local level_names = {
	minetest.colorize("#00bf00", "Easy Time"),
	minetest.colorize("#00bf00", "Applying Knowledge"),
	minetest.colorize("#50ff50", "How Even?"),
	minetest.colorize("#50ff50", "Jump Jump Jump"),
	minetest.colorize("#ffff00", "Bouncy Bounce"),
	minetest.colorize("#ffff00", "Emoticon Parkour!"),
	minetest.colorize("#ff7f00", "New Blocks!"),
	minetest.colorize("#ff7f00", "Trivial Trivia"),
	minetest.colorize("#ff0000", "Obstical Course"),
	minetest.colorize("#ff0000", "Grand Finale!"),
}

local speed_timer = {}
local jump_timer = {}

minetest.register_globalstep(function(dtime)
	local p
	timer = timer + dtime
	for _, p in pairs(minetest.get_connected_players()) do
		local name = p:get_player_name()
		if p:is_player() then
			local inv = p:get_inventory()
			if name == minetest.setting_get("name") or name == "singleplayer" then
				if minetest.setting_getbool("creative_mode") then
					inv:set_list("main", {"default:stick", "default:pick_diamond", "default:sign_wall_steel", "bakedclay:red", "bakedclay:orange", "bakedclay:yellow", "bakedclay:green", "bakedclay:dark_green", "bakedclay:blue", "bakedclay:cyan", "bakedclay:violet", "bakedclay:dark_grey", "bakedclay:brown", "bakedclay:black"})
				else
					inv:set_list("main", {"default:stick", get_wool(0, sneak_enabled), get_wool(1, sneak_glitch_enabled)})
				end
			else
				inv:set_list("main", {"default:stick"})
			end
		end
		local node_under = minetest.get_node({x = p:getpos().x, y = p:getpos().y - 0.5, z = p:getpos().z}).name
		if p and p:getpos() then
			if node_under == "bakedclay:red" and not respawning_players[name] then
				p:set_hp(0)
			elseif minetest.get_node({x = p:getpos().x, y = p:getpos().y - 1.5, z = p:getpos().z}).name == "bakedclay:orange" and not respawning_players[name] then
				p:set_hp(0)
			elseif node_under == "bakedclay:yellow" then
				p:setpos({x = p:getpos().x, y = p:getpos().y + 5, z = p:getpos().z})
			elseif node_under == "bakedclay:cyan" then
				p:setpos({x = p:getpos().x, y = p:getpos().y - 5, z = p:getpos().z})
			elseif node_under == "bakedclay:brown" and not respawning_players[name] then
				p:set_hp(20)
				beds.spawn[name] = vector.round(p:getpos())
			elseif node_under == "bakedclay:blue" and not respawning_players[name] then
				local i, pos
				
				for i, pos in pairs(end_lvl) do
					if pos_is(name, pos) then
						p:setpos(level[i] or {x = 0, y = -0.5, z = 0})
						if i == 1 then
							minetest.chat_send_all(name .. " left the hub and is now on level 1.")
							minetest.setting_set("void_height", "-1")
							minetest.setting_set("void_dmg_pause", "0.25")
							minetest.setting_set("time_speed", "0")
							minetest.setting_set("free_move", "false")
							minetest.setting_set("fast_move", "false")
							minetest.setting_set("noclip", "false")
							minetest.setting_set("viewing_range", "200")
							minetest.setting_set("respawn_on_die", "true")
							minetest.set_timeofday(0.5)
							minetest.chat_send_player(name, "Welcome to level " .. tostring(i) .. ": \"" .. level_names[i] .. "\".")
						elseif i == 11 then
							minetest.chat_send_all(name .. " finished the map!")
						else
							minetest.chat_send_all(name .. " finished level " .. tostring(i - 1) .. " and is now on level " .. tostring(i) .. ".")
							minetest.chat_send_player(name, "Welcome to level " .. tostring(i) .. ": \"" .. level_names[i] .. "\".")
						end
					end
				end
			elseif node_under == "bakedclay:green" then
				speed_timer[name] = 0.5
			elseif node_under == "bakedclay:black" then
				jump_timer[name] = 0.5
				p:set_physics_override(1, 2, 1)
			end
			
			if (speed_timer[name] or 0) > 0 then
				p:set_physics_override(5, p:get_physics_override().jump, 1)
				speed_timer[name] = speed_timer[name] - dtime
			end
			if (jump_timer[name] or 0) > 0 then
				p:set_physics_override(p:get_physics_override().speed, 2, 1)
				jump_timer[name] = jump_timer[name] - dtime
			end
		end	
		if timer >= 2 then
			local obj
			for _, obj in pairs(minetest.luaentities) do
				if obj.name == "__builtin:item" then
					obj.object:remove()
				end
			end
			if name == minetest.setting_get("name") or name == "singleplayer" then
				if minetest.setting_getbool("creative_mode") then
					p:hud_set_hotbar_itemcount(14)
				else
					p:hud_set_hotbar_itemcount(3)
				end
			else
				p:hud_set_hotbar_itemcount(1)
			end
		end
		local c = p:get_player_control()
		if not minetest.setting_getbool("creative_mode") then
			if c.sneak and c.jump and p:get_hp() ~= 0 and not respawning_players[name] and not sneak_glitch_enabled then
				p:set_hp(0)
				minetest.chat_send_all(name .. " was caught using the sneak glitch.")
			end -- Sneak Glitch
			if c.sneak and p:get_hp() ~= 0 and not respawning_players[name] and not sneak_enabled then
				p:set_hp(0)
				minetest.chat_send_all(name .. " was caught being sneaky.")
			end
		end
		if node_under ~= "bakedclay:green" and node_under ~= "bakedclay:black" and c.aux1 and (speed_timer[name] or 0) <= 0 and (jump_timer[name] or 0) <= 0 then
			p:set_physics_override(1.8, 1.1, 1)
		elseif node_under ~= "bakedclay:green" and node_under ~= "bakedclay:black" and not c.aux1 and (speed_timer[name] or 0) <= 0 and (jump_timer[name] or 0) <= 0 then
			p:set_physics_override(1, 1, 1)
		end
	end
	if timer >= 2 then
		beds.save_spawns()
		timer = 0
	end
end)

minetest.register_chatcommand("restart", {
	func = function(name, param)
		local p
		minetest.chat_send_all(name .. " restarted the map. Teleporting...")
		for _, p in pairs(minetest.get_connected_players()) do
			p:setpos({x = 0, y = 0, z = 0})
		end
		minetest.chat_send_all("Teleported all.")
	end
})

minetest.register_on_dieplayer(function(player)
	minetest.sound_play("player_damage", {to_player = player:get_player_name(), gain = 100.0})
end)

minetest.override_item("default:stick", {
	inventory_image = "checkpoint.png",
	on_drop = function(item, dropper, pos)
		if dropper:get_hp() == 0 or respawning_players[dropper:get_player_name()] then return end
		dropper:set_hp(0)
	end,
	description = "Press "..minetest.colorize("#FBFB00", "Q").." to Restart"
})

minetest.override_item("wool:red", {
	inventory_image = "shift_disable.png",
	wield_image = "shift_disable.png",
	description = "Sneaking "..minetest.colorize("#FF0000", "Disabled"),
	on_drop = function(itemstack, dropper, pos)
		sneak_enabled = true
		minetest.chat_send_all(dropper:get_player_name() .. minetest.colorize("#00FF00", " ENABLED") .. " sneaking.")
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		minetest.set_node(pos, {name = "air"})
	end
})

minetest.override_item("wool:green", {
	inventory_image = "shift_enable.png",
	wield_image = "shift_enable.png",
	description = "Sneaking "..minetest.colorize("#007F00", "Enabled"),
	on_drop = function(itemstack, dropper, pos)
		sneak_enabled = false
		minetest.chat_send_all(dropper:get_player_name() .. minetest.colorize("#FF0000", " DISABLED") .. " sneaking.")
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		minetest.set_node(pos, {name = "air"})
	end
})

minetest.override_item("wool:orange", {
	inventory_image = "shift_glitch_disable.png",
	wield_image = "shift_glitch_disable.png",
	description = "Sneak Glitch "..minetest.colorize("#FF0000", "Disabled"),
	tiles = {"wool_red.png"},
	on_drop = function(itemstack, dropper, pos)
		sneak_glitch_enabled = true
		minetest.chat_send_all(dropper:get_player_name() .. minetest.colorize("#00FF00", " ENABLED") .. " sneak glitch.")
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		minetest.set_node(pos, {name = "air"})
	end
})

minetest.override_item("wool:yellow", {
	inventory_image = "shift_glitch_enable.png",
	wield_image = "shift_glitch_enable.png",
	description = "Sneak Glitch "..minetest.colorize("#007F00", "Enabled"),
	tiles = {"wool_green.png"},
	on_drop = function(itemstack, dropper, pos)
		sneak_glitch_enabled = false
		minetest.chat_send_all(dropper:get_player_name() .. minetest.colorize("#FF0000", " DISABLED") .. " sneak glitch.")
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		minetest.set_node(pos, {name = "air"})
	end
})

minetest.register_abm({
	nodenames = {"bones:bones", "fire:basic_flame", "default:lava_source", "default:lava_flowing", "default:water_source", "default:water_flowing", "tnt:tnt_burning", "tnt:tnt"},
	chance = 1,
	interval = 1,
	action = function(pos)
		minetest.set_node(pos, {name = "air"})
	end
})

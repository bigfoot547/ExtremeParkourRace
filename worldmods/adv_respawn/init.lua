respawning_players = {}
death_pos = {}
minetest.register_on_dieplayer(function(player)
	local name = player:get_player_name()
	death_pos[name] = player:getpos()
	minetest.after(0, minetest.close_formspec, name, "")
	default.player_attached[name] = true
	default.player_set_animation(player, "lay" , 0)
	if not respawning_players[name] then
		respawning_players[name] = 3
		respawn_countdown(name)
	end
	player:hud_set_flags({hotbar = false, healthbar = false, crosshair = false, wielditem = false})
	player:set_physics_override(0,0,0)
	player:set_hp(20)
end)

minetest.register_on_respawnplayer(function(player)
	return true
end)

minetest.register_globalstep(function(dtime)
	local pname, p
	for pname in pairs(respawning_players) do
		p = minetest.get_player_by_name(pname)
		p:set_hp(20)
		p:set_breath(11)
		p:setpos(death_pos[pname])
	end
end)

function respawn_countdown(name)
	local p = minetest.get_player_by_name(name)
	if not p then return end
	if respawning_players[name] and respawning_players[name] <= 0 then
		respawning_players[name] = nil
		minetest.chat_send_player(name, "Respawned")
		default.player_attached[name] = false
		default.player_set_animation(p, "stand" , 30)
		--minetest.set_node({x = 0, y = -1, z = 0}, {name = "default:cloud"})
		p:hud_set_flags({hotbar = true, healthbar = true, crosshair = true, wielditem = true})
		p:set_physics_override({jump = 1, speed = 1, gravity = 1})
		if minetest.setting_getbool("respawn_on_die") then
			p:setpos(beds.spawn[name] or minetest.string_to_pos(minetest.setting_get("static_spawnoint")) or {x = 0, y = 0, z = 0})
		else
			if minetest.registered_nodes[minetest.get_node(death_pos[name]).name].groups.lava then
				p:setpos(beds.spawn[name] or minetest.string_to_pos(minetest.setting_get("static_spawnoint")) or {x = 0, y = 0, z = 0})
			else
				p:setpos(death_pos[name])
			end
		end
		death_pos[name] = nil
		return
	end
	minetest.chat_send_player(name, "Respawning in "..tostring(respawning_players[name] or 0).." seconds.")
	respawning_players[name] = respawning_players[name] - 1
	minetest.after(1, respawn_countdown, name)
end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if respawning_players[placer:get_player_name()] then
		minetest.set_node(pos, oldnode)
		return true
	end
end)

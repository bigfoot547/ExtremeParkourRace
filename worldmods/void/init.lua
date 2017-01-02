local timer = 0
minetest.register_globalstep(function(dtime)
	local death_messages = {" died in the void.", " fell out of the world.", " took a dive in a bottomless pit."}
	timer = dtime + timer
	if timer >= (tonumber(minetest.setting_get("void_dmg_pause")) or 1) then
		for i = 1, #minetest.get_connected_players() do
			local hp = minetest.get_connected_players()[i]:get_hp()
			if hp > 0 and minetest.get_connected_players()[i]:getpos()["y"] < (tonumber(minetest.setting_get("void_height")) or -20) and not respawning_players[minetest.get_connected_players()[i]:get_player_name()] then
				minetest.get_connected_players()[i]:set_sky({r=0,b=0,g=0}, "plain", nil)
				minetest.get_connected_players()[i]:set_hp(hp - 4)
				print("[Void] "..minetest.get_connected_players()[i]:get_player_name().." was damaged in the void at y: "..tostring(minetest.get_connected_players()[i]:getpos()["y"])..".")
				if minetest.get_connected_players()[i]:get_hp() <= 0 then
					minetest.chat_send_all(minetest.get_connected_players()[i]:get_player_name()..death_messages[math.random(#death_messages)])
					print("[Void] "..minetest.get_connected_players()[i]:get_player_name().." died in the void.")
				end
			else
				minetest.get_connected_players()[i]:set_sky(nil, "regular", nil)
			end
		end
		for i in pairs(minetest.object_refs) do
			if minetest.object_refs[i]:getpos().y < tonumber(minetest.setting_get("void_height") or 0) then
				minetest.object_refs[i]:remove()
			end
		end
		timer = 0
	end
end)

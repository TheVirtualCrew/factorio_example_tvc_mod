local mod_gui = require("mod-gui")
local gui = {}

gui.init_player = function(player, reset)
	gui.get_table(player, reset)
end

gui.update_tables = function()
	local totals = gui.get_totals()
	for _, player in pairs(game.players) do
		gui.update_player_table(player, totals)
	end
end

gui.get_totals = function()
	-- Collect totals/display values here

	return {members = 1, total = 20}
end

gui.update_player_table = function(player, totals)
	if not totals then
		totals = gui.get_totals()
	end

	if player and player.valid and player.gui then
		local guitable = gui.get_table(player)
		if (guitable and guitable.valid) then
		-- update the values here
		--guitable[defs.gui.amount_member .. '_value'].caption = totals.total .. " / " .. totals.members
		end
	end
end

gui.get_table = function(player, reset)
	reset = reset or false
	if not player.gui then
		return
	end
	local frame = player.gui.left
	local info_frame

	if frame == nil or not frame.valid then
		return
	end

	local name_prefix = defs.prefix .. "info_table"
	local player_settings = settings.get_player_settings(player)
	local setting = player_settings[defs.settings.show_table].value
	if not setting then
		local flow = frame[name_prefix .. "_flow"]
		if flow and flow.valid then
			flow.destroy()
		end

		return
	end

	local flow = frame[name_prefix .. "_flow"]
	if flow == nil or not flow.valid or reset then
		if flow and flow.valid then
			flow.destroy()
		end
		-- Create location for flows
		flow =
			frame.add {
			type = "flow",
			name = name_prefix .. "_flow",
			direction = "vertical"
		}
		flow.style.horizontally_stretchable = false
	end

	info_frame = flow[name_prefix .. "_frame"]
	if info_frame == nil or not info_frame.valid then
		if info_frame then
			info_frame.destroy()
		end
		-- Create the (scrollable) frame with title
		info_frame =
			flow.add {
			type = "frame",
			name = name_prefix .. "_frame",
			direction = "vertical",
			style = mod_gui.frame_style,
			caption = player_settings[defs.settings.table_label].value
		}
		info_frame.style.horizontally_stretchable = false
	end

	local table = info_frame[name_prefix]
	if table == nil then
		table =
			info_frame.add {
			type = "table",
			column_count = 2,
			name = name_prefix
		}
	-- Add your table fields here
	--table.add { type = 'label', name = defs.gui.amount_donation .. '_label', caption = { defs.gui.amount_donation.. '_label' }, style = 'bold_label' }
	--table.add { type = 'label', name = defs.gui.amount_donation .. '_value', caption = '0' }
	end

	return table
end

gui.init_events = function()
	Event.register(
		-120,
		function()
			gui.update_tables()
		end
	)

	Event.register(
		defines.events.on_runtime_mod_setting_changed,
		function(event)
			if (event.setting:find("^" .. s36.prefix) ~= nil) then
				local player = game.players[event.player_index]
				gui.get_table(player, true)
			end
		end
	)
end

return gui

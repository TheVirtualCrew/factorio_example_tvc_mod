require "util"
require "defines"

Game = require "__stdlib__/stdlib/game"
Area = require "__stdlib__/stdlib/area/area"
Position = require "__stdlib__/stdlib/area/position"
Entity = require "__stdlib__/stdlib/entity/entity"
Inventory = require "__stdlib__/stdlib/entity/inventory"
Event = require "__stdlib__/stdlib/event/event"
Gui = require "__stdlib__/stdlib/event/gui"
table = require "__stdlib__/stdlib/utils/table"

local gui = require "script.gui"

global.allow_test = false

local events = {
	api_on_donation = false,
	api_on_member = false,
	api_on_follow = false,
	api_on_raid = false,
	api_on_host = false,
	api_on_merch = false,
	api_on_subgift = false
}

local function init_globals()
	if remote.interfaces.tvc_api then
		events = remote.call("tvc_api", "get_events")
	end
end

local register_api_events = function()
	-- Ensure no duplicate event registration
	if events and #events then
		local remove =
			table.filter(
			events,
			function(value)
				return value ~= false
			end
		)
		if #remove then
			Event.remove(remove)
		end
	end
	events = remote.call("tvc_api", "get_events")

	Event.register(
		events.api_on_donation,
		function(event)
			local message = event.message
			if not message.isTest or (message.isTest and global.allow_test) then
				-- do your magic here
				local amount = tonumber(message.amount)
				if message.type == "bits" then
					-- convert to dollar
					amount = amount / 100
				end
			else
				game.print("Found test message, ignoring")
			end

			if message.type == "bits" then
				game.print(
					{"tvc-message-donation", message.name, message.amount .. " Bits", message.message, message.streamer_source}
				)
			else
				local amount = message.formatted_amount or message.amount .. message.currency
				game.print({"tvc-message-donation", message.name, amount, message.message, message.streamer_source})
			end
		end
	)

	Event.register(
		events.api_on_member,
		function(event)
			local message = event.message
			if not message.isTest or (message.isTest and global.allow_test) then
				-- do your magic here
			else
				game.print("Found test message, ignoring")
			end
			gui:update_tables()

			if message["streak_months"] and message["streak_months"] > 1 then
				game.print({"tvc-message-resub", message.name, message.months, message.streamer_source})
			elseif message.gifter_display_name or message.gifter then
				game.print(
					{"tvc-message-member-gift", message.name, message.gifter_display_name or message.gifter, message.streamer_source}
				)
			else
				local name = message.display_name or message.name
				if message.type == "pledge" then
					name = "A new patreon"
				end
				game.print({"tvc-message-member", name, message.streamer_source})
			end
		end
	)

	Event.register(
		events.api_on_raid,
		function(event)
			local message = event.message
			-- do your magic here
			game.print({"tvc-raid", message.name, message.raiders, message.streamer_source})
		end
	)

	Event.register(
		events.api_on_host,
		function(event)
			local message = event.message
			-- do your magic here
			game.print({"tvc-host", message.name, message.viewers, message.streamer_source})
		end
	)
	Event.register(
		events.api_on_follow,
		function(event)
			local message = event.message
			-- do your magic here
			game.print({"tvc-message-follow", message.name, message.streamer_source})
		end
	)
	-- [[
	-- Example message
	-- 	{
	-- 		sub_plan: '1000',
	-- 		sub_type: 'submysterygift',
	-- 		gifter: 'gifterName',
	-- 		gifter_display_name: 'gifterDisplayName',
	-- 		name: 'gifterName',
	-- 		amount: '5',
	-- 		_id: 'eventIdUnique',
	-- 		event_id: 'eventIdUnique',
	-- 		type: 'subMysteryGift',
	-- 		for: 'twitch_account',
	-- 		streamer_source: 'twitchName'
	-- 	  }
	-- ]]
	Event.register(
		events.api_on_subgift,
		function(event)
			local message = event.message
			-- do your magic here
			game.print({"tvc-message-subgift", message.name, message.amount, message.streamer_source})
		end
	)
end

Event.on_init(
	function(event)
		init_globals()
		register_api_events()
	end
)

Event.on_load(
	function(event)
		register_api_events()
	end
)

gui.init_events()

-- Reset player tables on join
Event.register(
	{defines.events.on_player_created, defines.events.on_player_joined_game},
	function(event)
		local player = Game.get_player(event)
		if player then
			gui.get_table(player, true)
			gui.update_player_table(player)
		end
	end
)

Event.register(
	defines.events.on_runtime_mod_setting_changed,
	function(event)
		if event.setting:match(defs.prefix) ~= nil then
			local gui = gui
			for _, p in pairs(game.players) do
				gui.init_player(p, true)
			end
		end
	end
)

-- Interface to do something extra (remote control options)
remote.add_interface(
	"example_mod",
	{
		allow_test = function(bool)
			global.allow_test = bool
		end
	}
)

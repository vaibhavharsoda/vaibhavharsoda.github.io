-- prosody-plugins/mod_lobby_autostart_custom.lua

local jid_bare = require "util.jid".bare;

-- Enable lobby for the room
local function enable_lobby(room)
    if room.set_lobby_enabled and not room:get_lobby_enabled() then
        room:set_lobby_enabled(true);
        module:log("info", "Lobby enabled for room %s", room.jid);
    end
end

-- Hook when a user attempts to join the room
module:hook("muc-occupant-pre-join", function(event)
    local room = event.room;
    local occupant = event.occupant;
    local user_jid = occupant.bare_jid;

    -- Enable lobby for guests (non-authenticated users)
    local user = module:get_bare_session(user_jid);
    if not (user and user.authenticated) then
        enable_lobby(room);
    else
        module:log("info", "Authenticated user %s is joining, bypassing lobby for room %s", user_jid, room.jid);
    end
end);

-- Hook when a user leaves the room
module:hook("muc-occupant-left", function(event)
    local room = event.room;
    local occupants = room:each_occupant();

    -- Check if there are no more occupants, disable lobby
    local occupant_count = 0;
    for _ in occupants do
        occupant_count = occupant_count + 1;
    end

    if occupant_count == 0 then
        room:set_lobby_enabled(false);
        module:log("info", "Lobby disabled for room %s as it is now empty", room.jid);
    end
end);

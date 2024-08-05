local st = require "util.stanza";
local jid_bare = require "util.jid".bare;

module:hook("muc-occupant-pre-join", function(event)
    local room = event.room;
    local occupant = event.occupant;
    local user_jid = occupant.bare_jid;
    
    -- Check if user is authenticated
    local user = module:get_bare_session(user_jid);
    if user and user.authenticated then
        -- Enable lobby if not moderator
        if not occupant.role == "moderator" then
            module:log("info", "Authenticated user %s is joining, enabling lobby for room %s", user_jid, room.jid);
            room:set_lobby_enabled(true);
        end
    end
end);

module:hook("muc-occupant-left", function(event)
    local room = event.room;
    local occupant = event.occupant;
    local user_jid = occupant.bare_jid;

    -- Disable lobby if moderator leaves
    if occupant.role == "moderator" then
        module:log("info", "Moderator %s left, disabling lobby for room %s", user_jid, room.jid);
        room:set_lobby_enabled(false);
    end
end);

local REPO = "https://raw.githubusercontent.com/gnochi5000bea/Miku-chan/refs/heads/main/games/"
local SCRIPTS = {
    [18794863104] = "Demonology",
}

local place_id = game.PlaceID
local script_url = SCRIPTS[place_id]

if not script_url then
    return
end

script_url = REPO .. script_url .. ".lua"

http.Get(script_url, {}, function(response)
    if not response then
        return
    end

    cheat.LoadString(response, "loaded_script_" .. tostring(place_id))
end)

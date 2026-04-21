local REPO = "https://raw.githubusercontent.com/gnochi5000bea/Miku-chan/refs/heads/main/games/"
local SCRIPTS = {
    [18794863104] = "Demonology",
    [134282808814904] = "hunting game",
    [1.342828088149e+14] = "hunting game"
}

local place_id = game.PlaceID
local script_url = SCRIPTS[place_id]

if (not script_url) then
    return
end

script_url = REPO .. script_url .. ".lua"

http.Get(script_url, {}, function(response)
    if not response then
        print("Request failed, no response received.")
        return
    end

    cheat.LoadString(response, "loaded_script_" .. SCRIPTS[place_id])
end)

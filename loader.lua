local REPO = "https://raw.githubusercontent.com/gnochi5000bea/Miku-chan/refs/heads/main/games/"
local SCRIPTS = {
    ["18794863104"] = "Demonology",
    ["1.342828088149e+14"] = "hunting game",
    ["18680867089"] = "Ultimate Mining Tycoon",
    ["1.2401231600025e+14"] = "It Hears You"
}

local place_id = tostring(game.PlaceID)
local script_name = SCRIPTS[place_id]

if (not script_name) then
    print("No script found for place id: " .. place_id)
    return
end

local script_url = REPO .. script_name .. ".lua"

http.Get(script_url, {}, function(response)
    if (not response) then
        print("Request failed, no response received.")
        return
    end

    print("Loading script: " .. script_name)
    loadstring(response)()
end)

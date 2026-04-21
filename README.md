```lua
http.Get("https://raw.githubusercontent.com/gnochi5000bea/Miku-chan/refs/heads/main/loader.lua", {}, function(response)
    if not response then
        return
    end

    cheat.LoadString(response, "Miku-chan")
end)

local ORES = { "Tin", "Iron", "Lead", "Cobalt", "Silver", "Aluminium", "Uranium", "Vanadium", "Titanium", "Gold", "Tungsten", "Molybdenum", "Plutonium", "Palladium", "Iridium", "Adamantium", "Thorium", "Mithril", "Rhodium", "Unobtainium", "Topaz", "Emerald", "Ruby", "Sapphire", "Diamond", "Poudretteite", "Zultanite", "Grandidierite", "Musgravite", "Painite" }
local ORE_DATA = {
    ["Tin"] = {
        Value = 10,
        Color = Color3.fromRGB(123, 133, 133)
    },
    ["Iron"] = {
        Value = 20,
        Color = Color3.fromRGB(189, 125, 84)
    },
    ["Lead"] = {
        Value = 30,
        Color = Color3.fromRGB(54, 56, 73)
    },
    ["Cobalt"] = {
        Value = 50,
        Color = Color3.fromRGB(64, 116, 199)
    },
    ["Silver"] = {
        Value = 150,
        Color = Color3.fromRGB(133, 171, 185)
    },
    ["Aluminium"] = {
        Value = 65,
        Color = Color3.fromRGB(107, 108, 107)
    },
    ["Uranium"] = {
        Value = 180,
        Color = Color3.fromRGB(87, 175, 87)
    },
    ["Vanadium"] = {
        Value = 240,
        Color = Color3.fromRGB(166, 64, 46)
    },
    ["Titanium"] = {
        Value = 400,
        Color = Color3.fromRGB(74, 77, 122)
    },
    ["Gold"] = {
        Value = 350,
        Color = Color3.fromRGB(241, 213, 121)
    },
    ["Tungsten"] = {
        Value = 300,
        Color = Color3.fromRGB(65, 83, 76)
    },
    ["Molybdenum"] = {
        Value = 600,
        Color = Color3.fromRGB(138, 159, 153)
    },
    ["Plutonium"] = {
        Value = 1000,
        Color = Color3.fromRGB(41, 137, 211)
    },
    ["Palladium"] = {
        Value = 1200,
        Color = Color3.fromRGB(209, 160, 34)
    },
    ["Iridium"] = {
        Value = 3700,
        Color = Color3.fromRGB(171, 221, 2089)
    },
    ["Adamantium"] = {
        Value = 4500,
        Color = Color3.fromRGB(80, 159, 116)
    },
    ["Thorium"] = {
        Value = 3200,
        Color = Color3.fromRGB(97, 130, 109)
    },
    ["Mithril"] = {
        Value = 2000,
        Color = Color3.fromRGB(83, 165, 134)
    },
    ["Rhodium"] = {
        Value = 15000,
        Color = Color3.fromRGB(90, 62, 55)
    },
    ["Unobtainium"] = {
        Value = 30000,
        Color = Color3.fromRGB(189, 80, 211)
    },
    ["Topaz"] = {
        Value = 75,
        Color = Color3.fromRGB(154, 143, 56)
    },
    ["Emerald"] = {
        Value = 200,
        Color = Color3.fromRGB(0, 143, 0)
    },
    ["Ruby"] = {
        Value = 300,
        Color = Color3.fromRGB(193, 11, 11)
    },
    ["Sapphire"] = {
        Value = 250,
        Color = Color3.fromRGB(11, 36, 179)
    },
    ["Diamond"] = {
        Value = 1500,
        Color = Color3.fromRGB(103, 182, 188)
    },
    ["Poudretteite"] = {
        Value = 1700,
        Color = Color3.fromRGB(202, 67, 200)
    },
    ["Zultanite"] = {
        Value = 2300,
        Color = Color3.fromRGB(202, 134, 117)
    },
    ["Grandidierite"] = {
        Value = 4500,
        Color = Color3.fromRGB(67, 202, 130)
    },
    ["Musgravite"] = {
        Value = 5800,
        Color = Color3.fromRGB(92, 97, 97)
    },
    ["Painite"] = {
        Value = 12000,
        Color = Color3.fromRGB(154, 68, 68)
    },
    ["Unknown"] = {
        Value = 0,
        Color = Color3.fromRGB(255, 255, 255)
    }
}

local function table_find(t, value, init)
    init = init or 1

    for i = init, #t do
        if t[i] == value then
            return i
        end
    end

    return nil
end

local REGISTERED_ORES = {}

local workspace = game.Workspace
local client = game.LocalPlayer

local placed_ore = workspace.PlacedOre
local plots = workspace.Plots

ui.newTab("MIKU", "Miku-chan")

ui.newContainer("MIKU", "ESP", "Ore ESP", { autosize = true, next = true })
ui.newCheckbox("MIKU", "ESP", "Enabled")
ui.newCheckbox("MIKU", "ESP", "Show value")
ui.newMultiselect("MIKU", "ESP", "Whitelists", ORES)

ui.newContainer("MIKU", "TELEPORTATION", "Teleportation", { autosize = true, next = true })
ui.newButton("MIKU", "TELEPORTATION", "Teleport to Plot", function()
    local plot

    for idx, instance in pairs(plots:get_children()) do
        local owner_id = instance:GetAttribute("OwnerId")

        if owner_id then
            if owner_id.Value == client.UserId then
                plot = instance
                
                break
            end
        end
    end

    if plot then
        client.Character.HumanoidRootPart.Position = plot.Centre.Position
    end
end)

ui.newDropdown("MIKU", "TELEPORTATION", "Ore", ORES)
ui.newButton("MIKU", "TELEPORTATION", "Teleport to Ore", function()
    local ore_to_teleport_to = ORES[ui.getValue("MIKU", "TELEPORTATION", "Ore") + 1]
    local ores = placed_ore:get_children()

    local ore

    for idx = 1, #ores do
        local ore_instance = ores[idx]

        if (ore_instance:is_a("MeshPart")) then
            local ore_name = ore_instance:GetAttribute("MineId")
            ore_name = ore_name and ore_name.Value or "Unknown"

            if ore_name == ore_to_teleport_to then
                ore = ore_instance

                break
            end
        end
    end

    if ore then
        ore.CanCollide = false
        client.Character.HumanoidRootPart.Position = ore.Position
    end
end)

ui.newContainer("MIKU", "SETTINGS", "Settings", { autosize = true })
local FONTS = { "ConsolasBold", "SmallestPixel", "Verdana", "Tahoma" }
ui.newDropdown("MIKU", "SETTINGS", "Font", FONTS, 1)

local function on_update()
    local ores = placed_ore:get_children()
    local active_addresses = {}

    for idx = 1, #ores do
        local ore_instance = ores[idx]

        if (ore_instance:is_a("MeshPart")) then
            local ore_address = ore_instance.Address
            local registered_ore = REGISTERED_ORES[ore_address]
            active_addresses[ore_address] = true

            if (not registered_ore) then
                local ore_name = ore_instance:GetAttribute("MineId")
                ore_name = ore_name and ore_name.Value

                local ore_data = ORE_DATA[ore_name] or { Value = 0, Color = Color3.fromRGB(255, 255, 255) }
                
                REGISTERED_ORES[ore_address] = {
                    instance = ore_instance,
                    instance_data = { x = 0, y = 0, on_screen = false },
                    name = ore_name,
                    color = ore_data.Color,
                    value = ore_data.Value
                }

                registered_ore = REGISTERED_ORES[ore_address]
            end

            local x, y, on_screen = utility.world_to_screen(ore_instance.Position)
            registered_ore.instance_data = { x = x, y = y, on_screen = on_screen }
        end
    end

    for ore_address in pairs(REGISTERED_ORES) do
        if (not active_addresses[ore_address]) then
            REGISTERED_ORES[ore_address] = nil
        end
    end
end

local function on_paint()
    local enabled = ui.getValue("MIKU", "ESP", "Enabled")
    if (not enabled) then
        return
    end

    local whitelists = ui.getValue("MIKU", "ESP", "Whitelists")
    local show_value = ui.getValue("MIKU", "ESP", "Show value")

    local font = FONTS[ui.getValue("MIKU", "SETTINGS", "Font") + 1]

    local none_selected = true
    for idx, value in pairs(whitelists) do
        if value == true then
            none_selected = false

            break
        end
    end

    for ore_address, registered_ore in pairs(REGISTERED_ORES) do
        local name = registered_ore.name
        local idx = table_find(ORES, name)

        if (none_selected or whitelists[idx]) then
            local instance_data = registered_ore.instance_data

            if (instance_data.on_screen) then
                local text = show_value and name .. " [" .. tostring(registered_ore.value) .. "]" or name
                draw.TextOutlined(text, instance_data.x, instance_data.y, registered_ore.color, font)
            end
        end
    end
end

cheat.register("onUpdate", on_update)
cheat.register("onPaint", on_paint)
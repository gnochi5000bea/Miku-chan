local MONSTER_FLAGS = { "Chasing", "Target" }

local function table_find(t, value)
    for i = 1, #t do
        if t[i] == value then
            return i
        end
    end

    return nil
end

local function magnitude(a, b)
    local dx = a.X - b.X
    local dy = a.Y - b.Y
    local dz = a.Z - b.Z
    
    return (dx * dx + dy * dy + dz * dz) ^ 0.5
end

local function floor(n)
    return n - (n % 1)
end

local REGISTERED_ITEMS = {}
local REGISTERED_STICKS = {}
local REGISTERED_CLOTH = {}
local REGISTERED_GLASS = {}
local REGISTERED_METAL = {}
local REGISTERED_GUNPOWDER = {}
local REGISTERED_MONSTER = {
    instance = nil,
    instance_data = { x = 0, y = 0, on_screen = false },
    distance = 0,
    alive = false,
    chasing = false,
    target = nil,
    name = "Monster"
}

local workspace = game.Workspace
local client = game.LocalPlayer

local droppeditems_folder = workspace.DroppedItems
local stick_folder = workspace.StickNodes
local cloth_folder = workspace.ClothNodes
local glass_folder = workspace.GlassNodes
local metal_folder = workspace.MetalNodes
local gunpowder_folder = workspace.GunpowderNodes

ui.newTab("MIKU", "Miku-chan")

ui.newContainer("MIKU", "Item ESP", "Item ESP", { autosize = true, next = true })
ui.newCheckbox("MIKU", "Item ESP", "Dropped Items")
ui.newColorpicker("MIKU", "Item ESP", "Dropped Item Color", Color3.fromRGB(255, 255, 255), true)
ui.newCheckbox("MIKU", "Item ESP", "Sticks")
ui.newColorpicker("MIKU", "Item ESP", "Stick Color", {r=139, g=90, b=43}, true)
ui.newCheckbox("MIKU", "Item ESP", "Cloth")
ui.newColorpicker("MIKU", "Item ESP", "Cloth Color", {r=200, g=200, b=255}, true)
ui.newCheckbox("MIKU", "Item ESP", "Glass")
ui.newColorpicker("MIKU", "Item ESP", "Glass Color", {r=150, g=220, b=255}, true)
ui.newCheckbox("MIKU", "Item ESP", "Metal")
ui.newColorpicker("MIKU", "Item ESP", "Metal Color", {r=180, g=180, b=180}, true)
ui.newCheckbox("MIKU", "Item ESP", "Gunpowder")
ui.newColorpicker("MIKU", "Item ESP", "Gunpowder Color", {r=50, g=50, b=50}, true)
ui.newCheckbox("MIKU", "Item ESP", "Show amount")
ui.newSliderInt("MIKU", "Item ESP", "Max distance", 0, 10000, 200)

ui.newContainer("MIKU", "Monster ESP", "Monster ESP", { autosize = true, next = true })
ui.newCheckbox("MIKU", "Monster ESP", "Enabled")
ui.newColorpicker("MIKU", "Monster ESP", "Monster Color", {r=255, g=0, b=0}, true)
ui.newCheckbox("MIKU", "Monster ESP", "Show distance")
ui.newMultiselect("MIKU", "Monster ESP", "Flags", MONSTER_FLAGS)

ui.newContainer("MIKU", "SETTINGS", "Settings", { autosize = true })
local FONTS = { "ConsolasBold", "SmallestPixel", "Verdana", "Tahoma" }
ui.newDropdown("MIKU", "SETTINGS", "Font", FONTS, 1)
ui.newCheckbox("MIKU", "SETTINGS", "Distance calculations")

local function get_client_hrp()
    return client.Character and client.Character:find_first_child("HumanoidRootPart")
end

local function register_nodes(folder, registry, label, distance_enabled)
    local nodes = folder:get_children()
    local active_addresses = {}

    for idx = 1, #nodes do
        local node_instance = nodes[idx]

        local node_address = node_instance.Address
        local registered_node = registry[node_address]
        active_addresses[node_address] = true

        if (node_instance.Name == "MaterialNode") then
            local amount = node_instance:GetAttribute("MaterialAmount")
            amount = amount and amount.Value or 0

            if (node_instance:is_a("Model")) then
                if (not registered_node) then
                    registry[node_address] = {
                        instance = node_instance,
                        instance_data = { x = 0, y = 0, on_screen = false },
                        name = label,
                        amount = amount,
                        distance = 0
                    }
                    registered_node = registry[node_address]
                end

                local node_root = node_instance:find_first_child("BillboardAnchor")
                local x, y, on_screen = utility.world_to_screen(node_root.Position)
                registered_node.instance_data = { x = x, y = y, on_screen = on_screen }

                local client_hrp = get_client_hrp()

                if (client_hrp and distance_enabled) then
                    registered_node.distance = magnitude(client_hrp.Position, node_root.Position)
                end
            else
                if (not registered_node) then
                    registry[node_address] = {
                        instance = node_instance,
                        instance_data = { x = 0, y = 0, on_screen = false },
                        name = label,
                        amount = amount,
                        distance = 0
                    }
                    registered_node = registry[node_address]
                end

                local x, y, on_screen = utility.world_to_screen(node_instance.Position)
                registered_node.instance_data = { x = x, y = y, on_screen = on_screen }

                local client_hrp = get_client_hrp()

                if (client_hrp and distance_enabled) then
                    registered_node.distance = magnitude(client_hrp.Position, node_instance.Position)
                end
            end
        end
    end

    for node_address in pairs(registry) do
        if (not active_addresses[node_address]) then
            registry[node_address] = nil
        end
    end
end

local function on_update()
    local dropped_items = droppeditems_folder:get_children()
    local active_addresses = {}
    local client_hrp = get_client_hrp()
    local distance_enabled = ui.getValue("MIKU", "SETTINGS", "Distance calculations")

    for idx = 1, #dropped_items do
        local item_instance = dropped_items[idx]

        local item_address = item_instance.Address
        local registered_item = REGISTERED_ITEMS[item_address]
        active_addresses[item_address] = true

        local item_name = item_instance:GetAttribute("ItemName")
        item_name = item_name and item_name.Value or item_instance.Name

        if (item_instance:is_a("MeshPart") or item_instance:is_a("UnionOperation")) then
            local amount = item_instance:GetAttribute("Amount")
            amount = amount and amount.Value or 0

            if (not registered_item) then
                REGISTERED_ITEMS[item_address] = {
                    instance = item_instance,
                    instance_data = { x = 0, y = 0, on_screen = false },
                    name = item_name,
                    amount = amount,
                    distance = 0
                }

                registered_item = REGISTERED_ITEMS[item_address]
            end

            local x, y, on_screen = utility.world_to_screen(item_instance.Position)
            registered_item.instance_data = { x = x, y = y, on_screen = on_screen }

            if (client_hrp and distance_enabled) then
                registered_item.distance = magnitude(client_hrp.Position, item_instance.Position)
            end
        elseif (item_instance:is_a("Model")) then
            local amount = item_instance:GetAttribute("Amount") or item_instance:GetAttribute("AmmoAmount")
            amount = amount and amount.Value or 0

            if (not registered_item) then
                REGISTERED_ITEMS[item_address] = {
                    instance = item_instance,
                    instance_data = { x = 0, y = 0, on_screen = false },
                    name = item_name,
                    amount = amount,
                    distance = 0
                }

                registered_item = REGISTERED_ITEMS[item_address]
            end

            local item_root = item_instance.Name == "ToolDrop" and item_instance:find_first_child("Visual") or item_instance:find_first_child("BillboardAnchor")
            local x, y, on_screen = utility.world_to_screen(item_root.Position)
            registered_item.instance_data = { x = x, y = y, on_screen = on_screen }

            if (client_hrp and distance_enabled) then
                registered_item.distance = magnitude(client_hrp.Position, item_root.Position)
            end
        end
    end

    for item_address in pairs(REGISTERED_ITEMS) do
        if (not active_addresses[item_address]) then
            REGISTERED_ITEMS[item_address] = nil
        end
    end

    register_nodes(stick_folder, REGISTERED_STICKS, "Stick", distance_enabled)
    register_nodes(cloth_folder, REGISTERED_CLOTH, "Cloth", distance_enabled)
    register_nodes(glass_folder, REGISTERED_GLASS, "Glass", distance_enabled)
    register_nodes(metal_folder, REGISTERED_METAL, "Metal", distance_enabled)
    register_nodes(gunpowder_folder, REGISTERED_GUNPOWDER, "Gunpowder", distance_enabled)

    if (REGISTERED_MONSTER.instance == nil) then
        REGISTERED_MONSTER.alive = false
        REGISTERED_MONSTER.instance = workspace:find_first_child("Pathfinding Monster")
    end

    if (REGISTERED_MONSTER.instance ~= nil) then
        REGISTERED_MONSTER.alive = true

        local show_distance = ui.getValue("MIKU", "Monster ESP", "Show distance")
        local flags = ui.getValue("MIKU", "Monster ESP", "Flags")

        local chasing_enabled = flags[table_find(MONSTER_FLAGS, "Chasing")]
        local target_enabled = flags[table_find(MONSTER_FLAGS, "Target")]

        local monster = REGISTERED_MONSTER.instance
        local monster_hrp = monster:find_first_child("HumanoidRootPart")

        if (client_hrp and show_distance and distance_enabled) then
            REGISTERED_MONSTER.distance = magnitude(client_hrp.Position, monster_hrp.Position)
        end

        if (chasing_enabled or target_enabled) then
            local is_chasing = monster:find_first_child("Chasing") and monster:find_first_child("Chasing").Value
            local has_target = monster:find_first_child("Target") and monster:find_first_child("Target").Value

            if (is_chasing == 1) then
                REGISTERED_MONSTER.chasing = true
            else
                REGISTERED_MONSTER.chasing = false
            end

            if (has_target) then
                REGISTERED_MONSTER.target = has_target.Name
            else
                REGISTERED_MONSTER.target = nil
            end
        end

        local x, y, on_screen = utility.world_to_screen(monster_hrp.Position)
        REGISTERED_MONSTER.instance_data = { x = x, y = y, on_screen = on_screen }
    end
end

local function draw_registry(registry, color, max_distance, distance_enabled)
    local font = FONTS[ui.getValue("MIKU", "SETTINGS", "Font") + 1]

    for registry_address, registry_data in pairs(registry) do
        local instance_data = registry_data.instance_data

        if (instance_data.on_screen and (not distance_enabled or registry_data.distance <= max_distance)) then
            local show_amount = ui.getValue("MIKU", "Item ESP", "Show amount")

            draw.TextOutlined(show_amount and registry_data.amount > 0 and tostring(registry_data.amount) .. "x " .. registry_data.name or registry_data.name, instance_data.x, instance_data.y, color, font)
        end
    end
end

local function on_paint()
    local droppeditems_enabled = ui.getValue("MIKU", "Item ESP", "Dropped Items")
    local sticks_enabled = ui.getValue("MIKU", "Item ESP", "Sticks")
    local cloth_enabled = ui.getValue("MIKU", "Item ESP", "Cloth")
    local glass_enabled = ui.getValue("MIKU", "Item ESP", "Glass")
    local metal_enabled = ui.getValue("MIKU", "Item ESP", "Metal")
    local gunpowder_enabled = ui.getValue("MIKU", "Item ESP", "Gunpowder")
    local max_distance = ui.getValue("MIKU", "Item ESP", "Max distance")

    local monster_enabled = ui.getValue("MIKU", "Monster ESP", "Enabled")
    local show_distance = ui.getValue("MIKU", "Monster ESP", "Show distance")
    local flags = ui.getValue("MIKU", "Monster ESP", "Flags")

    local distance_enabled = ui.getValue("MIKU", "SETTINGS", "Distance calculations")

    if (droppeditems_enabled) then
        local color = ui.getValue("MIKU", "Item ESP", "Dropped Item Color")

        draw_registry(REGISTERED_ITEMS, Color3.fromRGB(color.r, color.g, color.b), max_distance, distance_enabled)
    end

    if (sticks_enabled) then
        local color = ui.getValue("MIKU", "Item ESP", "Stick Color")

        draw_registry(REGISTERED_STICKS, Color3.fromRGB(color.r, color.g, color.b), max_distance, distance_enabled)
    end

    if (cloth_enabled) then
        local color = ui.getValue("MIKU", "Item ESP", "Cloth Color")

        draw_registry(REGISTERED_CLOTH, Color3.fromRGB(color.r, color.g, color.b), max_distance, distance_enabled)
    end

    if (glass_enabled) then
        local color = ui.getValue("MIKU", "Item ESP", "Glass Color")

        draw_registry(REGISTERED_GLASS, Color3.fromRGB(color.r, color.g, color.b), max_distance, distance_enabled)
    end

    if (metal_enabled) then
        local color = ui.getValue("MIKU", "Item ESP", "Metal Color")

        draw_registry(REGISTERED_METAL, Color3.fromRGB(color.r, color.g, color.b), max_distance, distance_enabled)
    end

    if (gunpowder_enabled) then
        local color = ui.getValue("MIKU", "Item ESP", "Gunpowder Color")

        draw_registry(REGISTERED_GUNPOWDER, Color3.fromRGB(color.r, color.g, color.b), max_distance, distance_enabled)
    end

    if (monster_enabled and REGISTERED_MONSTER.alive) then
        local font = FONTS[ui.getValue("MIKU", "SETTINGS", "Font") + 1]
        local instance_data = REGISTERED_MONSTER.instance_data

        if (instance_data.on_screen) then
            local chasing_enabled = flags[table_find(MONSTER_FLAGS, "Chasing")]
            local target_enabled = flags[table_find(MONSTER_FLAGS, "Target")]

            local monster_name = REGISTERED_MONSTER.name

            if (show_distance and distance_enabled) then
                monster_name = monster_name .. " [" .. tostring(floor(REGISTERED_MONSTER.distance)) .. "m]"
            end

            draw.TextOutlined(monster_name, instance_data.x, instance_data.y, ui.getValue("MIKU", "Monster ESP", "Monster Color"), font)

            local line = 1

            if (chasing_enabled and REGISTERED_MONSTER.chasing == true) then
                draw.TextOutlined("Chasing", instance_data.x, instance_data.y + (line * 15), Color3.fromRGB(255, 100, 100), font)
                line = line + 1
            end

            if (target_enabled and REGISTERED_MONSTER.chasing == true and REGISTERED_MONSTER.target ~= nil) then
                draw.TextOutlined("-> " .. REGISTERED_MONSTER.target, instance_data.x, instance_data.y + (line * 15), Color3.fromRGB(255, 100, 100), font)
                line = line + 1
            end
        end
    end
end

cheat.register("onUpdate", on_update)
cheat.register("onPaint", on_paint)
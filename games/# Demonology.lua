local GHOST_FLAGS = { "Hunting", "Ghost room" }
local FONTS = { "ConsolasBold", "SmallestPixel", "Verdana", "Tahoma" }

local function table_find(t, value)
    for i = 1, #t do
        if t[i] == value then
            return i
        end
    end

    return nil
end

local workspace = game.Workspace
local client = game.LocalPlayer

local ghost_instance = nil
local map_instance = nil
local rooms_folder = nil
local items_folder = nil
local emf_readers = {}

local GAME_STATUS = {
    ghost_orbs = false,
    freezing_temps = false,
    laser_projector = false,
    ghost_writing = false,
    handprints = false,
    wither = false,
    emf5 = false
}

local GHOST_STATUS = {
    hunting = false,
    ghost_room = nil,
}

local REGISTERED_GHOST = {
    instance = nil,
    instance_data = { x = 0, y = 0, on_screen = false },
    name = "Ghost"
}

local REGISTERED_ITEMS = {}

ui.newTab("MIKU", "Miku-chan")

ui.newContainer("MIKU", "Evidence", "Evidence", { autosize = true, next = true })
ui.newCheckbox("MIKU", "Evidence", "Ghost orbs")
ui.newCheckbox("MIKU", "Evidence", "Freezing temps")
ui.newCheckbox("MIKU", "Evidence", "Laser projector")
ui.newCheckbox("MIKU", "Evidence", "Ghost writing")
ui.newCheckbox("MIKU", "Evidence", "Handprints")
ui.newCheckbox("MIKU", "Evidence", "Wither")
ui.newCheckbox("MIKU", "Evidence", "EMF5")

ui.newContainer("MIKU", "Ghost ESP", "Ghost ESP", { autosize = true, next = true })
ui.newCheckbox("MIKU", "Ghost ESP", "Enabled")
ui.newColorpicker("MIKU", "Ghost ESP", "Ghost Color", { r = 255, g = 0, b = 0 }, true)
ui.newMultiselect("MIKU", "Ghost ESP", "Flags", GHOST_FLAGS)

ui.newContainer("MIKU", "Item ESP", "Item ESP", { autosize = true })
ui.newCheckbox("MIKU", "Item ESP", "Enabled")
ui.newColorpicker("MIKU", "Item ESP", "Item Color", { r = 255, g = 255, b = 255 }, true)

ui.newContainer("MIKU", "Settings", "Settings", { autosize = true })
ui.newDropdown("MIKU", "Settings", "Font", FONTS, 1)

local function get_items(item_name)
    local found_items = {}
    if (not items_folder) then return found_items end

    local items = items_folder:get_children()

    for idx = 1, #items do
        local item_instance = items[idx]
        local item_name = item_instance:GetAttribute("ItemName")

        if (item_name and item_name.Value == item_name) then
            table.insert(found_items, item_instance)
        end
    end

    return found_items
end

local function on_update()
    if (not ghost_instance) then
        ghost_instance = workspace:find_first_child("Ghost")
    end

    if (not map_instance) then
        map_instance = workspace:find_first_child("Map")
        rooms_folder = map_instance and map_instance:find_first_child("Rooms")
    end

    if (not items_folder) then
        items_folder = workspace:find_first_child("Items")
    end

    if (#emf_readers <= 0) then
        emf_readers = get_items("EMF Reader")
    end

    if (ghost_instance) then
        local is_hunting = ghost_instance:GetAttribute("Hunting")

        if (is_hunting and is_hunting.Value == 1) then
            GHOST_STATUS.hunting = true
        else
            GHOST_STATUS.hunting = false
        end

        local room = ghost_instance:GetAttribute("FavoriteRoom")
        GHOST_STATUS.ghost_room = room and room.Value or nil

        local ghost_hrp = ghost_instance:find_first_child("HumanoidRootPart")

        if (ghost_hrp) then
            REGISTERED_GHOST.instance = ghost_instance

            local x, y, on_screen = utility.world_to_screen(ghost_hrp.Position)
            REGISTERED_GHOST.instance_data = { x = x, y = y, on_screen = on_screen }
        end

        if (not GAME_STATUS.laser_projector) then
            local laser_visible = ghost_instance:GetAttribute("LaserVisible")

            if (laser_visible and laser_visible.Value == 1) then
                GAME_STATUS.laser_projector = true
            end
        end
    end

    if (not GAME_STATUS.ghost_orbs) then
        if workspace:find_first_child("GhostOrb") then
            GAME_STATUS.ghost_orbs = true
        end
    end

    if (not GAME_STATUS.freezing_temps and rooms_folder) then
        local rooms = rooms_folder:get_children()

        for idx = 1, #rooms do
            local temperature = rooms[idx]:GetAttribute("Temperature")

            if (temperature and temperature.Value <= 0) then
                GAME_STATUS.freezing_temps = true

                break
            end
        end
    end

    if (not GAME_STATUS.ghost_writing) then
        local spirit_books = get_items("Spirit Book")

        for idx = 1, #spirit_books do
            local disabled = spirit_books[idx]:GetAttribute("Disabled")

            if (disabled and disabled.Value == 1) then
                GAME_STATUS.ghost_writing = true

                break
            end
        end
    end

    if (not GAME_STATUS.handprints) then
        local handprints = workspace:find_first_child("Handprints")

        if (handprints) then
            GAME_STATUS.handprints = true
        end
    end

    if (not GAME_STATUS.wither) then
        local flower_pots = get_items("Flower Pot")

        for idx = 1, #flower_pots do
            local disabled = flower_pots[idx]:GetAttribute("Disabled")

            if (disabled and disabled.Value == 1) then
                GAME_STATUS.wither = true

                break
            end
        end
    end

    if (not GAME_STATUS.emf5) then
        for idx = 1, #emf_readers do
            local reading_level = emf_readers[idx]:GetAttribute("ReadingLevel")

            if (reading_level and reading_level.Value == 5) then
                GAME_STATUS.emf5 = true

                break
            end
        end
    end

    if items_folder then
        local items = items_folder:get_children()
        local active_addresses = {}

        for idx = 1, #items do
            local item_instance = items[idx]

            local item_address = item_instance.Address
            active_addresses[item_address] = true

            local item_name = item_instance:GetAttribute("ItemName")
            item_name = item_name and item_name.Value or item_instance.Name
            local registered_item = REGISTERED_ITEMS[item_address]

            local handle = item_instance:find_first_child("Handle")
            if (handle) then
                if (not registered_item) then
                    REGISTERED_ITEMS[item_address] = {
                        instance      = item_instance,
                        instance_data = { x = 0, y = 0, on_screen = false },
                        name          = item_name
                    }
                    registered_item = REGISTERED_ITEMS[item_address]
                end

                local x, y, on_screen = utility.world_to_screen(handle.Position)
                registered_item.instance_data = { x = x, y = y, on_screen = on_screen }
            end
        end

        for item_address in pairs(REGISTERED_ITEMS) do
            if not active_addresses[item_address] then
                REGISTERED_ITEMS[item_address] = nil
            end
        end
    end
end

local function on_paint()
    local font = FONTS[ui.getValue("MIKU", "Settings", "Font") + 1]
    local _, screen_height = cheat.getWindowSize()

    local evidence_list = {
        { key = "ghost_orbs", label = "Ghost Orbs", toggle = ui.getValue("MIKU", "Evidence", "Ghost orbs") },
        { key = "freezing_temps", label = "Freezing Temps", toggle = ui.getValue("MIKU", "Evidence", "Freezing temps") },
        { key = "laser_projector", label = "Laser Projector", toggle = ui.getValue("MIKU", "Evidence", "Laser projector") },
        { key = "ghost_writing", label = "Ghost Writing", toggle = ui.getValue("MIKU", "Evidence", "Ghost writing") },
        { key = "handprints", label = "Handprints", toggle = ui.getValue("MIKU", "Evidence", "Handprints") },
        { key = "wither", label = "Wither", toggle = ui.getValue("MIKU", "Evidence", "Wither") },
        { key = "emf5", label = "EMF5", toggle = ui.getValue("MIKU", "Evidence", "EMF5") }
    }

    local visible_count = 0
    for idx = 1, #evidence_list do
        if (evidence_list[idx].toggle) then visible_count = visible_count + 1 end
    end

    local y_start = screen_height / 2 - (visible_count * 20 / 2)
    local y_line  = 0

    for idx = 1, #evidence_list do
        local entry = evidence_list[idx]

        if (entry.toggle) then
            local found = GAME_STATUS[entry.key]
            local color = found and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)

            draw.TextOutlined(entry.label .. ": " .. tostring(found), 10, y_start + y_line * 20, color, font)
            y_line = y_line + 1
        end
    end

    local flags = ui.getValue("MIKU", "Ghost ESP", "Flags")

    if (flags[table_find(GHOST_FLAGS, "Hunting")]) then
        local hunt_color = GHOST_STATUS.hunting and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)

        draw.TextOutlined("Hunting: " .. tostring(GHOST_STATUS.hunting), 10, screen_height - 50, hunt_color, font)
    end

    if (flags[table_find(GHOST_FLAGS, "Ghost room")] and GHOST_STATUS.ghost_room) then
        draw.TextOutlined("Ghost Room: " .. tostring(GHOST_STATUS.ghost_room), 10, screen_height - 30, Color3.fromRGB(255, 255, 255), font)
    end

    if (ui.getValue("MIKU", "Ghost ESP", "Enabled") and REGISTERED_GHOST.instance ~= nil) then
        local instance_data = REGISTERED_GHOST.instance_data

        if (instance_data.on_screen) then
            local color = ui.getValue("MIKU", "Ghost ESP", "Ghost Color")

            draw.TextOutlined("Ghost", instance_data.x, instance_data.y, Color3.fromRGB(color.r, color.g, color.b), font)
        end
    end

    if (ui.getValue("MIKU", "Item ESP", "Enabled")) then
        local color = ui.getValue("MIKU", "Item ESP", "Item Color")
        color = Color3.fromRGB(color.r, color.g, color.b)

        for item_address, item_data in pairs(REGISTERED_ITEMS) do
            local instance_data = item_data.instance_data

            if (instance_data.on_screen) then
                draw.TextOutlined(item_data.name, instance_data.x, instance_data.y, color, font)
            end
        end
    end
end

cheat.register("onUpdate", on_update)
cheat.register("onPaint", on_paint)
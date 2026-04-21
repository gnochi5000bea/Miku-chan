local ANIMALS = { "Deer", "Doe", "Horse", "Moose", "Bear", "Rabbit", "Squirrel", "Flemish Giant Rabbit" }

local function table_find(t, value)
    for i = 1, #t do
        if t[i] == value then
            return i
        end
    end

    return nil
end

local REGISTERED_ANIMALS = {}
local REGISTERED_MONSTERS = {}

local workspace = game.Workspace
local client = game.LocalPlayer

local animals_folder = workspace.Animals
local monsters_folder = workspace.Monsters

ui.newTab("MIKU", "Miku-chan")

ui.newContainer("MIKU", "Animal ESP", "Animal ESP", { autosize = true, next = true })
ui.newCheckbox("MIKU", "Animal ESP", "Enabled")
ui.newMultiselect("MIKU", "Animal ESP", "Whitelists", ANIMALS)

ui.newContainer("MIKU", "Monster ESP", "Monster ESP", { autosize = true, next = true })
ui.newCheckbox("MIKU", "Monster ESP", "Enabled")

ui.newContainer("MIKU", "SETTINGS", "Settings", { autosize = true })
local FONTS = { "ConsolasBold", "SmallestPixel", "Verdana", "Tahoma" }
ui.newDropdown("MIKU", "SETTINGS", "Font", FONTS, 1)

local function on_update()
    local animals = animals_folder:get_children()
    local active_addresses = {}

    for idx = 1, #animals do
        local animal_instance = animals[idx]

        if (animal_instance:find_first_child("HumanoidRootPart")) then
            local animal_address = animal_instance.Address
            local registered_animal = REGISTERED_ANIMALS[animal_address]
            active_addresses[animal_address] = true

            if (not registered_animal) then
                REGISTERED_ANIMALS[animal_address] = {
                    instance = animal_instance,
                    instance_data = { x = 0, y = 0, on_screen = false },
                    name = animal_instance.Name
                }

                registered_animal = REGISTERED_ANIMALS[animal_address]
            end

            local x, y, on_screen = utility.world_to_screen(animal_instance:find_first_child("HumanoidRootPart").Position)
            registered_animal.instance_data = { x = x, y = y, on_screen = on_screen }
        end
    end

    for animal_address in pairs(REGISTERED_ANIMALS) do
        if (not active_addresses[animal_address]) then
            REGISTERED_ANIMALS[animal_address] = nil
        end
    end

    local monsters = monsters_folder:get_children()
    local active_addresses = {}

    for idx = 1, #monsters do
        local monster_instance = monsters[idx]

        if (monster_instance:find_first_child("HumanoidRootPart")) then
            local monster_address = monster_instance.Address
            local registered_monster = REGISTERED_MONSTERS[monster_address]
            active_addresses[monster_address] = true

            if (not registered_monster) then
                REGISTERED_MONSTERS[monster_address] = {
                    instance = monster_instance,
                    instance_data = { x = 0, y = 0, on_screen = false },
                    name = monster_instance.Name
                }

                registered_monster = REGISTERED_MONSTERS[monster_address]
            end

            local x, y, on_screen = utility.world_to_screen(monster_instance:find_first_child("HumanoidRootPart").Position)
            registered_monster.instance_data = { x = x, y = y, on_screen = on_screen }
        end
    end

    for monster_address in pairs(REGISTERED_MONSTERS) do
        if (not active_addresses[monster_address]) then
            REGISTERED_MONSTERS[monster_address] = nil
        end
    end
end

local function on_paint()
    local animal_enabled = ui.getValue("MIKU", "Animal ESP", "Enabled")
    local monster_enabled = ui.getValue("MIKU", "Monster ESP", "Enabled")

    local font = FONTS[ui.getValue("MIKU", "SETTINGS", "Font") + 1]

    if (animal_enabled) then
        local whitelists = ui.getValue("MIKU", "Animal ESP", "Whitelists")

        local none_selected = true
        for idx, value in pairs(whitelists) do
            if value == true then
                none_selected = false

                break
            end
        end

        for animal_address, registered_animal in pairs(REGISTERED_ANIMALS) do
            local name = registered_animal.name
            local idx = table_find(ANIMALS, name)

            if (none_selected or whitelists[idx]) then
                local instance_data = registered_animal.instance_data

                if (instance_data.on_screen) then
                    draw.TextOutlined(name, instance_data.x, instance_data.y, Color3.fromRGB(255, 255, 255), font)
                end
            end
        end
    end

    if (monster_enabled) then
        for monster_address, registered_monster in pairs(REGISTERED_MONSTERS) do
            local instance_data = registered_monster.instance_data

            if (instance_data.on_screen) then
                draw.TextOutlined(registered_monster.name, instance_data.x, instance_data.y, Color3.fromRGB(255, 0, 0), font)
            end
        end
    end
end

cheat.register("onUpdate", on_update)
cheat.register("onPaint", on_paint)
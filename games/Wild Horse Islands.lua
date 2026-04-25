local REGISTERED_ANIMALS = {}

local workspace = game.Workspace
local client = game.LocalPlayer

local islands_folder = workspace.Islands

ui.newTab("MIKU", "Miku-chan")

ui.newContainer("MIKU", "Animal ESP", "Animal ESP", { autosize = true, next = true })
ui.newCheckbox("MIKU", "Animal ESP", "Enabled")
ui.newColorpicker("MIKU", "Animal ESP", "Animal ESP Color", Color3.fromRGB(255, 255, 255), true)

ui.newContainer("MIKU", "SETTINGS", "Settings", { autosize = true })
local FONTS = { "ConsolasBold", "SmallestPixel", "Verdana", "Tahoma" }
ui.newDropdown("MIKU", "SETTINGS", "Font", FONTS, 1)

local function get_current_island()
    local island = client:GetAttribute("island")

    if (island) then
        return island.Value
    end

    return nil
end

local function on_update()
    local island = get_current_island()

    if (island) then
        local animals = islands_folder[island]:get_children()
        local active_addresses = {}

        for idx = 1, #animals do
            local animal_instance = animals[idx]
            local species = animal_instance:GetAttribute("species")
            local owner = animal_instance:GetAttribute("owner")

            if (species and not owner) then
                local animal_address = animal_instance.Address
                local registered_animal = REGISTERED_ANIMALS[animal_address]
                active_addresses[animal_address] = true

                if (not registered_animal) then
                    REGISTERED_ANIMALS[animal_address] = {
                        instance = animal_instance,
                        instance_data = { x = 0, y = 0, on_screen = false },
                        name = species.Value or "Animal"
                    }

                    registered_animal = REGISTERED_ANIMALS[animal_address]
                end

                local animal_root = animal_instance:find_first_child("HumanoidRootPart")

                if (animal_root) then
                    local x, y, on_screen = utility.world_to_screen(animal_root.Position)
                    registered_animal.instance_data = { x = x, y = y, on_screen = on_screen }
                end
            end
        end

        for animal_address in pairs(REGISTERED_ANIMALS) do
            if (not active_addresses[animal_address]) then
                REGISTERED_ANIMALS[animal_address] = nil
            end
        end
    end
end

local function on_paint()
    local font = FONTS[ui.getValue("MIKU", "SETTINGS", "Font") + 1]

    local animals_enabled = ui.getValue("MIKU", "Animal ESP", "Enabled")

    if (animals_enabled) then
        for animal_address, registered_animal in pairs(REGISTERED_ANIMALS) do
            local instance_data = registered_animal.instance_data

            if (instance_data.on_screen) then
                local color = ui.getValue("MIKU", "Animal ESP", "Animal ESP Color")

                draw.TextOutlined(registered_animal.name, instance_data.x, instance_data.y, Color3.fromRGB(color.r, color.g, color.b), font)
            end
        end
    end
end

cheat.register("onUpdate", on_update)
cheat.register("onPaint", on_paint)

local QBCore = exports['qb-core']:GetCoreObject()
local shopLocation = "shopLoc"
local shopExit = "shopExit"
local interactable = "interacting"

RegisterNetEvent("cw-prints:client:businessCard", function(Item)
    exports['ps-ui']:ShowImage(Item.info.url)
end)

RegisterNetEvent("cw-prints:client:createBusinessCard", function(data)
    TriggerServerEvent("cw-prints:server:createCard", data)
end)

local function isAllowed()
    if Config.JobIsRequired then
        local Player = QBCore.Functions.GetPlayerData()
        if Player.job.name == Config.AllowedJob then
            return true
        else
            return false
        end
    else
        return true
    end
end

CreateThread(function()
    local coords = Config.Locations.shopEntranceCoords
    local boxData = {}

    if boxData and boxData.created then
        return
    end
        exports['qb-target']:AddBoxZone(shopLocation, coords, 1.5, 1.5, {
            name = shopLocation,
            heading = 0,
            debugPoly = false,
            minZ = coords.z - 1.0,
            maxZ = coords.z + 1.0,
        }, {
            options = {
                {
                    type = "client",
                    event = "cw-prints:client:tpIn",
                    label = "Enter Building",
                    canInteract = function() return isAllowed() end
                },
            },
            distance = 2.0
        })
end)

CreateThread(function()
    local coords = Config.Locations.shopExitCoords
    local boxData = {}

    if boxData and boxData.created then
        return
    end
        exports['qb-target']:AddBoxZone(shopExit, coords, 1.5, 1.5, {
            name = shopExit,
            heading = 0,
            debugPoly = false,
            minZ = coords.z - 1.0,
            maxZ = coords.z + 1.0,
        }, {
            options = {
                {
                    type = "client",
                    event = "cw-prints:client:tpOut",
                    label = "Exit Building",
                    canInteract = function() return isAllowed() end
                },
            },
            distance = 2.0
        })
end)

CreateThread(function()
    local coords = Config.Locations.interactionPoint
    local boxData = {}

    if boxData and boxData.created then
        return
    end
        exports['qb-target']:AddBoxZone(interactable, coords, 1.5, 1.5, {
            name = interactable,
            heading = 0,
            debugPoly = false,
            minZ = coords.z - 1.0,
            maxZ = coords.z + 1.0,
        }, {
            options = {
                {
                    type = "client",
                    event = "cw-prints:client:openInteraction",
                    label = "Print some cards!",
                    canInteract = function() return isAllowed() end
                },
            },
            distance = 2.0
        })
end)

RegisterNetEvent("cw-prints:client:tpIn", function()
    TriggerServerEvent("cw-prints:server:TPInside")
end)

RegisterNetEvent("cw-prints:client:tpOut", function()
    TriggerServerEvent("cw-prints:server:TPOutside")
end)

RegisterNetEvent("cw-prints:client:openInteraction", function()
    local dialog = exports['qb-input']:ShowInput({
        header = Config.Texts.cardMakerHeader,
        submitText = Config.Texts.cardMakerSubmit,
        inputs = {
            {
                text = "Business name", -- text you want to be displayed as a place holder
                name = "business", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = "CID-1234", -- Default text option, this is optional
            },
            {
                text = "Card Design (URL)", -- text you want to be displayed as a place holder
                name = "url", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = "password123", -- Default text option, this is optional
            },
            {
                text = "Amount of cards", -- text you want to be displayed as a place holder
                name = "amount", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = 1, -- Default number option, this is optional
            }
        },
    })

    if dialog ~= nil then
        local data = { dialog["business"], dialog["url"], dialog["amount"] }

        TriggerServerEvent("cw-prints:server:createCard", data)
    else
        QBCore.Functions.Notify("Do your job better!", "error")
    end
end)
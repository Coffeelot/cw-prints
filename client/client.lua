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

local function hasValue(tbl, value)
    for k, v in ipairs(tbl) do -- iterate table (for sequential tables only)
        if v == value or (type(v) == "table" and hasValue(v, value)) then -- Compare value from the table directly with the value we are looking for, otherwise if the value is table, check its content for this value.
            return true -- Found in this or nested table
        end
    end
    return false -- Not found
end

local function isAllowed(type)
    if Config.JobIsRequired then
        local Player = QBCore.Functions.GetPlayerData()
        
        local playerHasJob = Config.AllowedJobs[Player.job.name]

        local jobGradeReq = nil
        if Config.AllowedJobs[Player.job.name] ~= nil then
            jobGradeReq = Config.AllowedJobs[Player.job.name][type]
        end        
        
        if playerHasJob then
            if jobGradeReq ~= nil then
                if Player.job.grade.level >= jobGradeReq then
                    return true
                else
                    return false
                end
            else
                return false
            end
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
                    canInteract = function() return isAllowed('doors') end
                },
            },
            distance = 2.0
        })
end)

CreateThread(function()
    if Config.UseShop then 
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
                    canInteract = function() return isAllowed('doors') end
                },
            },
            distance = 2.0
        })
    end
end)

CreateThread(function()
    if Config.UseInteractionPoint then
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
                    canInteract = function() return isAllowed('print') end
                },
            },
            distance = 2.0
        })
    end
end)

CreateThread(function()
    if Config.UseAllPrinters then
        for i,printer in pairs(Config.PrinterProps) do
        
        exports['qb-target']:AddTargetModel(printer, {
            options = {
                {
                    type = "client",
                    event = "cw-prints:client:openInteraction",
                    label = "Print some cards!",
                    canInteract = function() return isAllowed('print') end
                },
            },
            distance = 2.0
        })
        end
    end
end)

local printers = {}

CreateThread(function()
    if Config.UsePrinterSpawns then
        for i,printer in pairs(Config.PrinterSpawns) do
        
        local printerLocation = printer.coords
        local printer = CreateObject(printer.prop, printerLocation.x, printerLocation.y, printerLocation.z, true,  true, true)
        SetEntityHeading(printer, printerLocation.w)
        FreezeEntityPosition(printer, true)
        SetEntityAsMissionEntity(printer)

        exports['qb-target']:AddTargetModel(printer, {
            options = {
                {
                    type = "client",
                    event = "cw-prints:client:openInteraction",
                    label = "Print some cards!",
                    canInteract = function() return isAllowed('print') end
                },
            },
            distance = 2.0
        })
        end
    end
end)

RegisterNetEvent("cw-prints:client:tpIn", function()
    TriggerServerEvent("cw-prints:server:TPInside")
end)

RegisterNetEvent("cw-prints:client:tpOut", function()
    TriggerServerEvent("cw-prints:server:TPOutside")
end)

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

 RegisterNetEvent("cw-prints:client:GivePrint", function(data)
    local type = data.id
    local toPlayer, distance = QBCore.Functions.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    if toPlayer ~= -1 and distance < 3 then
        print(type)
        local itemInPockets = QBCore.Functions.HasItem(type)
        print('itemInPockets.slot', itemInPockets)
        if (itemInPockets) then
            local playerId = GetPlayerServerId(toPlayer)
            SetCurrentPedWeapon(PlayerPedId(),'WEAPON_UNARMED',true)
            TriggerServerEvent("cw-prints:server:GiveItem", playerId, toPlayer, type)
        else
            QBCore.Functions.Notify("You do not have a "..type.." on you.", "error")
        end
    else
        QBCore.Functions.Notify("No one nearby!", "error")
    end
 end)

RegisterNetEvent("cw-prints:client:openInteraction", function()

    local dialog = exports['qb-input']:ShowInput({
        header = Config.Texts.cardMakerHeader,
        submitText = Config.Texts.cardMakerSubmit,
        inputs = {
            {
                text = "Type", -- text you want to be displayed as a place holder
                name = "type", -- name of the input should be unique otherwise it might override
                type = "select", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                options = Config.Items,
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
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
        local data = { dialog["business"], dialog["url"], dialog["amount"], dialog["type"] }
        TriggerServerEvent("cw-prints:server:createCard", data)
    else
        QBCore.Functions.Notify("Do your job better!", "error")
    end
end)
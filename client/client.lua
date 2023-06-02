local QBCore = exports['qb-core']:GetCoreObject()
local shopLocation = "shopLoc"
local shopExit = "shopExit"
local interactable = "interacting"

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

if Config.Inv == 'ox' then 
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        exports.ox_inventory:displayMetadata('business', 'Business')
    end)
end

RegisterNetEvent("cw-prints:client:businessCard", function(Item)
        if Config.Inv == 'qb' then 
            exports['ps-ui']:ShowImage(Item.info.url)
        elseif Config.Inv == 'ox' then
            exports['ps-ui']:ShowImage(Item.metadata.url)
        end    
end)

RegisterNetEvent("cw-prints:client:createBusinessCard", function(data)
    TriggerServerEvent("cw-prints:server:createCard", data)
end)

local function setBookOpen(item, bool) 
    SetNuiFocus(bool, bool)
    if bool then
        TriggerEvent('animations:client:EmoteCommandStart', {"tablet2"})
    else
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end
    SendNUIMessage({
        action = "cwPrintBook",
        toggle = bool,
        item = item,
    })
end

RegisterNUICallback("closebook-callback", function(item, cb)
    setBookOpen(item, false)
    cb('ok')
end)


RegisterNetEvent("cw-prints:client:openBook", function(item)
    QBCore.Functions.Notify(Lang:t("info.openBook"))
    if Config.Inv == 'ox' then
        item.data = item.metadata
    end
    setBookOpen(item, true)
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
                    label = Lang:t("text.targetEnterBuilding"),
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
                    label = Lang:t("text.targetExitBuilding"),
                    canInteract = function() return isAllowed('doors') end
                },
            },
            distance = 2.0
        })
    end
end)

local printOptions = {
    {
        type = "client",
        event = "cw-prints:client:openInteraction",
        label = Lang:t("text.targetPrintCards"),
        canInteract = function() return isAllowed('print') end
    },
    {
        type = "client",
        event = "cw-prints:client:openBookInteraction",
        label = Lang:t("text.targetPrintBook"),
        canInteract = function() return isAllowed('print') end
    },
}

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
            options = printOptions,
            distance = 2.0
        })
    end
end)

CreateThread(function()
    if Config.UseAllPrinters then
        for i,printer in pairs(Config.PrinterProps) do
        
        exports['qb-target']:AddTargetModel(printer, {
            options = printOptions,
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
        local printer = CreateObject(printer.prop, printerLocation.x, printerLocation.y, printerLocation.z, false,  false, true)
        SetEntityHeading(printer, printerLocation.w)
        FreezeEntityPosition(printer, true)
        SetEntityAsMissionEntity(printer)

        exports['qb-target']:AddTargetEntity(printer, {
            options = printOptions,
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

RegisterNetEvent("cw-prints:client:GivePrint", function(data)
    local type = data.id
    local toPlayer, distance = QBCore.Functions.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    if toPlayer ~= -1 and distance < 3 then
        local itemInPockets = QBCore.Functions.HasItem(type)
        if (itemInPockets) then
            local playerId = GetPlayerServerId(toPlayer)
            SetCurrentPedWeapon(PlayerPedId(),'WEAPON_UNARMED',true)
            TriggerServerEvent("cw-prints:server:GiveItem", playerId, toPlayer, type)
        else
            QBCore.Functions.Notify(Lang:t("error.noItem", { value_type = type }), "error")
        end
    else
        QBCore.Functions.Notify(Lang:t("error.noOneNearby"), "error")
    end
 end)

RegisterNetEvent("cw-prints:client:openInteraction", function()

    local dialog = exports['qb-input']:ShowInput({
        header = Config.Texts.cardMakerHeader,
        submitText = Config.Texts.cardMakerSubmit,
        inputs = {
            {
                text = Lang:t("text.type"), -- text you want to be displayed as a place holder
                name = "type", -- name of the input should be unique otherwise it might override
                type = "select", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                options = Config.Items,
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
            {
                text = Lang:t("text.businessName"), -- text you want to be displayed as a place holder
                name = "business", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = "CID-1234", -- Default text option, this is optional
            },
            {
                text = Lang:t("text.cardURL"), -- text you want to be displayed as a place holder
                name = "url", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = "password123", -- Default text option, this is optional
            },
            {
                text = Lang:t("text.cardAmount"), -- text you want to be displayed as a place holder
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
        QBCore.Functions.Notify(Lang:t("error.betterJob"), "error")
    end
end)

local function openNextBookInteraction(data)
    local pages = tonumber(data.pages)
    
    local pageInputs = {}

    for i = 1, pages do
        pageInputs[#pageInputs+1] = {
            text = Lang:t("text.pageURL") .. i, -- text you want to be displayed as a place holder
            name = "page-"..i, -- name of the input should be unique otherwise it might override
            type = "text", -- type of the input
            isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            -- default = "CID-1234", -- Default text option, this is optional
        }
    end

    local dialog = exports['qb-input']:ShowInput({
        header = Config.Texts.bookMaker1Header,
        submitText = Config.Texts.bookMaker1Submit,
        inputs = pageInputs,
    })
    
    if dialog ~= nil then
        local pageUrls = {}
        for i = 1, pages do
            pageUrls[i] = dialog['page-'..i]
        end
        local data = { name = data.name , pages = pageUrls, type = data.type, amount = data.amount }
        TriggerServerEvent("cw-prints:server:createBook", data)
    else
        QBCore.Functions.Notify(Lang:t("error.betterJob"), "error")
    end
end

RegisterNetEvent("cw-prints:client:openBookInteraction", function()
    local dialog = exports['qb-input']:ShowInput({
        header = Config.Texts.bookMaker1Header,
        submitText = Config.Texts.bookMaker1Submit,
        inputs = {
            {
                text = Lang:t("text.bookName"), -- text you want to be displayed as a place holder
                name = "name", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = "CID-1234", -- Default text option, this is optional
            },
            {
                text = Lang:t("text.type"), -- text you want to be displayed as a place holder
                name = "type", -- name of the input should be unique otherwise it might override
                type = "select", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                options = Config.BookItems,
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
            {
                text = Lang:t("text.pagesAmount"), -- text you want to be displayed as a place holder
                name = "pages", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = 1, -- Default number option, this is optional
            },
            {
                text = Lang:t("text.printAmount"), -- text you want to be displayed as a place holder
                name = "amount", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = 1, -- Default number option, this is optional
            },
        },
    })
    
    if dialog ~= nil then
        local data = { name = dialog["name"],  pages = dialog["pages"], type = dialog["type"], amount = dialog['amount'] }
        openNextBookInteraction(data)
    else
        QBCore.Functions.Notify(Lang:t("error.betterJob"), "error")
    end
end)


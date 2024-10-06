local QBCore = exports['qb-core']:GetCoreObject()
local shopLocation = "shopLoc"
local shopExit = "shopExit"
local interactable = "interacting"


-- Global variables to track animation and prop status
local isReadingBook = false
local bookProp

-- Function to start reading book animation with prop in left hand
local function startReadingBook()
    local playerPed = PlayerPedId()

    -- Load the animation dictionary
    RequestAnimDict("amb@world_human_clipboard@male@base")
    while not HasAnimDictLoaded("amb@world_human_clipboard@male@base") do
        Citizen.Wait(100)
    end

    -- Play the animation (only upper body - allows walking)
    TaskPlayAnim(playerPed, "amb@world_human_clipboard@male@base", "base", 8.0, -8.0, -1, 49, 0, false, false, false)

    -- Spawn the book prop
    local bookModel = GetHashKey("prop_novel_01") -- Use an appropriate book model
    RequestModel(bookModel)
    while not HasModelLoaded(bookModel) do
        Citizen.Wait(100)
    end

    -- Spawn and attach the book prop to the left hand with adjusted rotation
    local playerCoords = GetEntityCoords(playerPed)
    bookProp = CreateObject(bookModel, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)

    -- Adjusted attachment to the left hand (bone index 18905) with proper rotation
    AttachEntityToEntity(bookProp, playerPed, GetPedBoneIndex(playerPed, 18905), 0.16, 0.09, 0.06, 50.0, 270.0, 150.0, true, true, false, true, 1, true)
end

-- Function to stop the reading book animation and remove the prop
local function stopReadingBook()
    local playerPed = PlayerPedId()

    -- Clear the animation
    ClearPedTasks(playerPed)

    -- If the book prop exists, delete it
    if bookProp and DoesEntityExist(bookProp) then
        DeleteObject(bookProp)
        bookProp = nil
    end
end

local function notify(text, type)
    if Config.UseOxLib then
        lib.notify({
            title = text,
            type = type,
        })
    else 
        QBCore.Functions.Notify(text, type)
    end
end

if Config.Inv == 'ox' then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        exports.ox_inventory:displayMetadata('business', 'Business Name')
        exports.ox_inventory:displayMetadata('pages', 'Pages')
    end)
end

local function setCardOpen(item, bool)
    local url = ''
    if Config.Inv == 'qb' then
        url = item.info.url
    elseif Config.Inv == 'ox' then
        url = item.metadata.url
    end
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "cwPrintCard",
        toggle = bool,
        url = url,
    })
end

RegisterNetEvent("cw-prints:client:businessCard", function(item)
    if Config.Inv == 'ox' then
        item.data = item.metadata
    end
    setCardOpen(item, true)
end)

RegisterNetEvent("cw-prints:client:createBusinessCard", function(data)
    TriggerServerEvent("cw-prints:server:createCard", data)
end)

local function setBookOpen(item, bool)
    SetNuiFocus(bool, bool)
    startReadingBook()
    SendNUIMessage({
        action = "cwPrintBook",
        toggle = bool,
        item = item,
    })
end

RegisterNUICallback("closebook-callback", function(item, cb)
    stopReadingBook()
    SetNuiFocus(false, false)
end)


RegisterNetEvent("cw-prints:client:openBook", function(item)
    notify(Lang:t("info.openBook"))
    if Config.Inv == 'ox' then
        item.data = item.metadata
    end
    setBookOpen(item, true)
end)

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
    local options = {
        {
            type = "client",
            event = "cw-prints:client:tpIn",
            label = Lang:t("text.targetEnterBuilding"),
            canInteract = function() return isAllowed('doors') end
        },
    }
    if Config.UseOxLib then
        print('coords', json.encode(coords, {indent=true}))

        exports.ox_target:addBoxZone({
            coords = coords,
            options = options
        })
    else
        exports['qb-target']:AddBoxZone(shopLocation, coords, 1.5, 1.5, {
            name = shopLocation,
            heading = 0,
            debugPoly = false,
            minZ = coords.z - 1.0,
            maxZ = coords.z + 1.0,
        }, {
            options = options,
            distance = 2.0
        })
    end
end)

CreateThread(function()
    if Config.UseShop then
        local coords = Config.Locations.shopExitCoords
        local boxData = {}

        if boxData and boxData.created then
            return
        end
        local options = {
            {
                type = "client",
                event = "cw-prints:client:tpOut",
                label = Lang:t("text.targetExitBuilding"),
                canInteract = function() return isAllowed('doors') end
            },
        }
        if Config.UseOxLib then
            exports.ox_target:addBoxZone({
                coords = coords,
                options = options
            })
        else
            exports['qb-target']:AddBoxZone(shopExit, coords, 1.5, 1.5, {
                name = shopExit,
                heading = 0,
                debugPoly = false,
                minZ = coords.z - 1.0,
                maxZ = coords.z + 1.0,
            }, {
                options = options,
                distance = 2.0
            })
        end
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
        if Config.UseOxLib then
            exports.ox_target:addBoxZone({
                coords = coords,
                options = printOptions
            })
        else
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
    end
end)

CreateThread(function()
    if Config.UseAllPrinters then
        for i,printer in pairs(Config.PrinterProps) do
            if Config.UseOxLib then
                exports.ox_target:addModel(printer, printOptions)
            else
                exports['qb-target']:AddTargetModel(printer, {
                    options = printOptions,
                    distance = 2.0
                })
            end
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

            if Config.UseOxLib then
                exports.ox_target:addLocalEntity(printer, printOptions)
            else
                exports['qb-target']:AddTargetEntity(printer, {
                    options = printOptions,
                    distance = 2.0
                })
            end
        end
    end
end)

RegisterNetEvent("cw-prints:client:tpIn", function()
    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, Config.Locations.shopExitCoords)
end)

RegisterNetEvent("cw-prints:client:tpOut", function()
    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, Config.Locations.shopEntranceCoords)
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
            notify(Lang:t("error.noItem", { value_type = type }), "error")
        end
    else
        notify(Lang:t("error.noOneNearby"), "error")
    end
 end)

 RegisterNetEvent('cw-prints:client:notify', function(message, type)
    print('notify')
    notify(message, type)
end)

RegisterNetEvent("cw-prints:client:openInteraction", function()
    if Config.UseOxLib then
        local dialog = lib.inputDialog(
            Config.Texts.cardMakerHeader,
            {
                {
                    label = Lang:t("text.type"),
                    name = "type", 
                    type = "select", 
                    options = Config.Items,
                    required = true,
                },
                {
                    label = Lang:t("text.businessName"),
                    name = "business", 
                    type = "input", 
                    required = true,
                },
                {
                    label = Lang:t("text.cardURL"),
                    name = "url", 
                    type = "input", 
                    required = true,
                },
                {
                    label = Lang:t("text.cardAmount"),
                    name = "amount", 
                    type = "number", 
                    required = true,
                    min = 0
                }
            }
        )
        if dialog ~= nil then
            local data = { business = dialog[2], url = dialog[3], amount = dialog[4], type = dialog[1] }
            TriggerServerEvent("cw-prints:server:createCard", data)
        else
            notify(Lang:t("error.betterJob"), "error")
        end
    else
        local dialog = exports['qb-input']:ShowInput({
            header = Config.Texts.cardMakerHeader,
            submitText = Config.Texts.cardMakerSubmit,
            inputs = {
                {
                    text = Lang:t("text.type"), 
                    name = "type", 
                    type = "select", 
                    options = Config.Items,
                    isRequired = true,
                },
                {
                    text = Lang:t("text.businessName"), 
                    name = "business", 
                    type = "text", 
                    isRequired = true,
                },
                {
                    text = Lang:t("text.cardURL"), 
                    name = "url", 
                    type = "text", 
                    isRequired = true,
                },
                {
                    text = Lang:t("text.cardAmount"), 
                    name = "amount", 
                    type = "text", 
                    isRequired = true,
                }
            },
        })
    
        if dialog ~= nil then
            local data = { business = dialog["business"], url = dialog["url"], amount = dialog["amount"], type = dialog["type"] }
            TriggerServerEvent("cw-prints:server:createCard", data)
        else
            notify(Lang:t("error.betterJob"), "error")
        end
    end
end)

local function openNextBookInteraction(data)
    local pages = tonumber(data.pages)
    
    local pageInputs = {}
    if Config.UseOxLib then
        for i = 1, pages do
            pageInputs[#pageInputs+1] = {
                label = Lang:t("text.pageURL") .. i, 
                type = "input", 
                required = true, 
            }
        end
    
        local dialog = lib.inputDialog(
            Config.Texts.bookMaker1Header,
            pageInputs
        )
    
        if dialog ~= nil then
            local pageUrls = {}
            for i = 1, pages do
                pageUrls[i] = dialog[i]
            end
            local data = { name = data.name , pages = dialog, type = data.type, amount = data.amount }
            TriggerServerEvent("cw-prints:server:createBook", data)
        else
            notify(Lang:t("error.betterJob"), "error")
        end
    else
        for i = 1, pages do
            pageInputs[#pageInputs+1] = {
                text = Lang:t("text.pageURL") .. i, 
                name = "page-"..i, 
                type = "text", 
                isRequired = true, 
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
            notify(Lang:t("error.betterJob"), "error")
        end
    end
end

RegisterNetEvent("cw-prints:client:openBookInteraction", function()
    if Config.UseOxLib then
        local dialog = lib.inputDialog(
            Config.Texts.bookMaker1Header,
            {
                {
                    label = Lang:t("text.bookName"), 
                    name = "name", 
                    type = "input", 
                    required = true, 
                },
                {
                    label = Lang:t("text.type"), 
                    name = "type", 
                    type = "select", 
                    options = Config.BookItems,
                    required = true, 
                },
                {
                    label = Lang:t("text.pagesAmount"), 
                    name = "pages", 
                    type = "number", 
                    required = true, 
                    min = 1

                },
                {
                    label = Lang:t("text.printAmount"), 
                    name = "amount", 
                    type = "number", 
                    required = true, 
                    min = 1
                },
            }
        )
        if dialog ~= nil then
            local data = { name = dialog[1],  pages = dialog[3], type = dialog[2], amount = dialog[4] }
            openNextBookInteraction(data)
        else
            notify(Lang:t("error.betterJob"), "error")
        end
    else
        local dialog = exports['qb-input']:ShowInput({
            header = Config.Texts.bookMaker1Header,
            submitText = Config.Texts.bookMaker1Submit,
            inputs = {
                {
                    text = Lang:t("text.bookName"), 
                    name = "name", 
                    type = "text", 
                    isRequired = true, 
                },
                {
                    text = Lang:t("text.type"), 
                    name = "type", 
                    type = "select", 
                    options = Config.BookItems,
                    isRequired = true, 
                },
                {
                    text = Lang:t("text.pagesAmount"), 
                    name = "pages", 
                    type = "text", 
                    isRequired = true, 
                },
                {
                    text = Lang:t("text.printAmount"), 
                    name = "amount", 
                    type = "text", 
                    isRequired = true, 
                },
            },
        })
    
        if dialog ~= nil then
            local data = { name = dialog["name"],  pages = dialog["pages"], type = dialog["type"], amount = dialog['amount'] }
            openNextBookInteraction(data)
        else
            notify(Lang:t("error.betterJob"), "error")
        end
    end
end)

local QBCore = exports['qb-core']:GetCoreObject()
local entryCoords = Config.Locations.shopEntranceCoords
local exitCoords = Config.Locations.shopExitCoords


local function createBusinessCard(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Config.Item

        local info = {}
        info.business = data[1]
        info.url = data[2]

        Player.Functions.RemoveMoney("cash", data[3]*Config.Cost)
        Player.Functions.AddItem(item, data[3], nil, info)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
end

QBCore.Functions.CreateUseableItem(Config.Item, function(source, Item)
    TriggerClientEvent("cw-prints:client:businessCard", source, Item)
end)

RegisterNetEvent("cw-prints:server:createCard", function(data)
    createBusinessCard(source, data)
end)


QBCore.Commands.Add('makecard', 'make a business card (admin only)',{ { name = 'business', help = 'What business is the card for' }, { name = 'link', help = 'link to the card'}, name = "amount", help = "amount of cards" }, true, function(source, args)
    TriggerClientEvent("cw-prints:client:createBusinessCard", source, args)
end, "admin")

RegisterNetEvent("cw-prints:server:TPInside", function()
    TriggerClientEvent('QBCore:Command:TeleportToCoords', source, exitCoords)
end)

RegisterNetEvent("cw-prints:server:TPOutside", function()
    TriggerClientEvent('QBCore:Command:TeleportToCoords', source, entryCoords)
end)
local QBCore = exports['qb-core']:GetCoreObject()
local entryCoords = Config.Locations.shopEntranceCoords
local exitCoords = Config.Locations.shopExitCoords

local function createBusinessCard(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = data[4]

        local info = {}
        info.business = data[1]
        info.url = data[2]
        info.type = data[4]
        
        Player.Functions.RemoveMoney("cash", data[3]*Config.Cost)
        Player.Functions.AddItem(item, data[3], nil, info)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
end

for i, type in pairs(Config.Items) do
    QBCore.Functions.CreateUseableItem(type.value, function(source, Item)
        TriggerClientEvent("cw-prints:client:businessCard", source, Item)
    end)
end

RegisterNetEvent("cw-prints:server:GiveItem", function(playerId, toPlayer, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(type)
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(playerId))

    if item ~= nil then
        if Player.Functions.RemoveItem(item.name, 1, item.slot) then
			if OtherPlayer.Functions.AddItem(item.name, 1, false, item.info) then
				TriggerClientEvent('inventory:client:ItemBox',playerId, QBCore.Shared.Items[item.name], "add")
				TriggerClientEvent('QBCore:Notify', playerId, "You Received ".. 1 ..' '..item.label.." From "..Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname)
				TriggerClientEvent("inventory:client:UpdatePlayerInventory", playerId, true)
				TriggerClientEvent('inventory:client:ItemBox',src, QBCore.Shared.Items[item.name], "remove")
				TriggerClientEvent('QBCore:Notify', src, "You gave " .. OtherPlayer.PlayerData.charinfo.firstname.." "..OtherPlayer.PlayerData.charinfo.lastname.. " " .. 1 .. " " .. item.label .."!")
				TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
				TriggerClientEvent('qb-inventory:client:giveAnim', src)
				TriggerClientEvent('qb-inventory:client:giveAnim', playerId)
			else
				Player.Functions.AddItem(item.name, 1, item.slot, item.info)
				TriggerClientEvent('QBCore:Notify', src,  "The other players inventory is full!", "error")
				TriggerClientEvent('QBCore:Notify', playerId,  "Your inventory is full!", "error")
				TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
				TriggerClientEvent("inventory:client:UpdatePlayerInventory", playerId, false)
			end
		else
			TriggerClientEvent('QBCore:Notify', src,  "You do not have enough of the item", "error")
		end    
    end

end)


RegisterNetEvent("cw-prints:server:createCard", function(data)
    createBusinessCard(source, data)
end)


QBCore.Commands.Add('makecard', 'make a business card (admin only)',{ { name = 'business', help = 'What business is the card for' }, { name = 'link', help = 'link to the card'}, {name = "amount", help = "amount of cards"}, { name = 'type', help = 'what type of card'} }, true, function(source, args)
    local data = { args[1], args[2], args[3], args[4] }
    createBusinessCard(source, data)
end, "admin")

RegisterNetEvent("cw-prints:server:TPInside", function()
    TriggerClientEvent('QBCore:Command:TeleportToCoords', source, exitCoords)
end)

RegisterNetEvent("cw-prints:server:TPOutside", function()
    TriggerClientEvent('QBCore:Command:TeleportToCoords', source, entryCoords)
end)
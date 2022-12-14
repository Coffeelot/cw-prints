local QBCore = exports['qb-core']:GetCoreObject()
local entryCoords = Config.Locations.shopEntranceCoords
local exitCoords = Config.Locations.shopExitCoords

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

local function createBusinessCard(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = data[4]

    local info = {}
    info.business = data[1]
    info.url = data[2]
    info.type = data[4]
        
	if Config.Inv == 'qb' then
		Player.Functions.RemoveMoney("cash", data[3]*Config.Cost)
		Player.Functions.AddItem(item, data[3], nil, info)
		TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
	elseif Config.Inv == 'ox' then
		Player.Functions.RemoveMoney("cash", data[3]*Config.Cost)
		exports.ox_inventory:AddItem(src, item, data[3], {business = data[1], url = data[2], type = data[4]})
	end
end

for i, type in pairs(Config.Items) do
    QBCore.Functions.CreateUseableItem(type.value, function(source, Item)
        TriggerClientEvent("cw-prints:client:businessCard", source, Item)
    end)
end

local function createBook(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = data.type

    local info = {}
    info.name = data.name
    info.pages = data.pages
    info.type = data.type
        
	if Config.Inv == 'qb' then
		Player.Functions.RemoveMoney("cash", data.amount*Config.Cost)
		Player.Functions.AddItem(item, data.amount, nil, info)
		TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
	elseif Config.Inv == 'ox' then
		Player.Functions.RemoveMoney("cash", data.amount*data.amount*Config.Cost)
		exports.ox_inventory:AddItem(src, item, data[3], {business = data[1], url = data[2], type = data[4]})
	end
end


for i, type in pairs(Config.BookItems) do
    QBCore.Functions.CreateUseableItem(type.value, function(source, Item)
        TriggerClientEvent("cw-prints:client:openBook", source, Item)
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

RegisterNetEvent("cw-prints:server:createBook", function(data)
    createBook(source, data)
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

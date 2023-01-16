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
		exports.ox_inventory:AddItem(src, item, data[3], {name = data[1], url = data[2], type = data[4]})
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
                TriggerClientEvent('inventory:client:ItemBox', playerId, QBCore.Shared.Items[item.name], "add")
                TriggerClientEvent('QBCore:Notify', playerId,
                    Lang:t("info.itemReceived",
                        {
                            value_amount = 1,
                            value_lable = item.label,
                            value_firstname = Player.PlayerData.charinfo.firstname,
                            value_lastname = Player.PlayerData.charinfo.lastname
                        }
                    )
                )
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", playerId, true)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove")
                TriggerClientEvent('QBCore:Notify', src,
                    Lang:t("info.gaveItem",
                        {
                            value_amount = 1,
                            value_lable = item.label,
                            value_firstname = OtherPlayer.PlayerData.charinfo.firstname,
                            value_lastname = OtherPlayer.PlayerData.charinfo.lastname
                        }
                    )
                )
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
                TriggerClientEvent('qb-inventory:client:giveAnim', src)
                TriggerClientEvent('qb-inventory:client:giveAnim', playerId)
            else
                Player.Functions.AddItem(item.name, 1, item.slot, item.info)
                TriggerClientEvent('QBCore:Notify', src,
                    Lang:t("error.otherInventoryFull"), "error")
                TriggerClientEvent('QBCore:Notify', playerId, Lang:t("error.inventoryFull"), "error")
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", playerId, false)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.notEnoughItems"), "error")
        end
    end

end)


RegisterNetEvent("cw-prints:server:createCard", function(data)
    createBusinessCard(source, data)
end)

RegisterNetEvent("cw-prints:server:createBook", function(data)
    createBook(source, data)
end)


QBCore.Commands.Add('makecard', Lang:t("command.makecardAdmin"),
    { { name = 'business', help = Lang:t("command.business") }, { name = 'link', help = Lang:t("command.link") },
        { name = "amount", help = Lang:t("command.amount") }, { name = 'type', help = Lang:t("command.type") } }, true,
    function(source, args)
        local data = { args[1], args[2], args[3], args[4] }
        createBusinessCard(source, data)
    end, "admin")

RegisterNetEvent("cw-prints:server:TPInside", function()
    TriggerClientEvent('QBCore:Command:TeleportToCoords', source, exitCoords)
end)

RegisterNetEvent("cw-prints:server:TPOutside", function()
    TriggerClientEvent('QBCore:Command:TeleportToCoords', source, entryCoords)
end)

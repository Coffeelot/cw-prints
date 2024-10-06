local QBCore = exports['qb-core']:GetCoreObject()

local function createBusinessCard(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = data.type
    local amount = tonumber(data.amount)

    local info = {}
    info.name = data.business
    info.business = data.business
    info.url = data.url
    info.cardType = data.type

    if Config.Debug then print(json.encode(
        {
            source = source,
            name = info.name,
            business = info.business,
            url = info.url,
            cardType = info.cardType,
            item = item,
        }, {indent=true})) end

	if Config.Inv == 'qb' then
		Player.Functions.RemoveMoney("cash", amount * Config.PrintCost[item])
		Player.Functions.AddItem(item, amount, nil, info)
		TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
	elseif Config.Inv == 'ox' then
        if amount < exports.ox_inventory:CanCarryAmount(source, item) then
            if exports.ox_inventory:RemoveItem(source, "cash", amount * Config.PrintCost[item]) then
                exports.ox_inventory:AddItem(source, item, amount, info)
            else
                QBCore.Functions.Notify(source, "Not Enough Money", "error")
            end
        else
            QBCore.Functions.Notify(source, "Cannot carry amount", "error")
        end
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
    info.bookType = data.type
    local amount = tonumber(data.amount)

	if Config.Inv == 'qb' then
		Player.Functions.RemoveMoney("cash",  amount * Config.PrintCost[item])
		Player.Functions.AddItem(item, amount, nil, info)
		TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
	elseif Config.Inv == 'ox' then
        if amount < exports.ox_inventory:CanCarryAmount(source, item) then
            if exports.ox_inventory:RemoveItem(source, "cash", amount * Config.PrintCost[item]) then
                exports.ox_inventory:AddItem(source, item, amount, info)
            else
                QBCore.Functions.Notify(source, "Not Enough Money", "error")
            end
        else
            QBCore.Functions.Notify(source, "Cannot carry amount", "error")
        end
	end
end


for i, type in pairs(Config.BookItems) do
    QBCore.Functions.CreateUseableItem(type.value, function(source, Item)
        if Config.Inv == 'qb' then
            if Item.info.useDynamicPages then
                Item.info.pages = Config.DynamicPages[Item.metadata.useDynamicPages]
            end
        end
        if Config.Inv == 'ox' then
            if Item.metadata.useDynamicPages then
                Item.metadata.pages = Config.DynamicPages[Item.metadata.useDynamicPages]
            end 
        end
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
                TriggerClientEvent('cw-prints:client:notify', playerId,
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
                TriggerClientEvent('cw-prints:client:notify', src,
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
                TriggerClientEvent('cw-prints:client:notify', src,
                    Lang:t("error.otherInventoryFull"), "error")
                TriggerClientEvent('cw-prints:client:notify', playerId, Lang:t("error.inventoryFull"), "error")
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", playerId, false)
            end
        else
            TriggerClientEvent('cw-prints:client:notify', src, Lang:t("error.notEnoughItems"), "error")
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
    end, "dev")

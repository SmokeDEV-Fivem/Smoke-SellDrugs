local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('smoke-selldrugs:sellDrug')
AddEventHandler('smoke-selldrugs:sellDrug', function(drugName, quantity, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local count = exports.ox_inventory:GetItemCount(source, drugName)
    
    if count < quantity then
        xPlayer.showNotification("~r~Vous n'avez pas assez de drogue")
        return
    end
    
    if exports.ox_inventory:RemoveItem(source, drugName, quantity) then
        if Config.PaymentType == "black_money" then
            exports.ox_inventory:AddItem(source, "black_money", price)
        else
            exports.ox_inventory:AddMoney(source, price)
        end
        
        if math.random(100) <= Config.ChancePolice then
            TriggerEvent('smoke-selldrugs:alertPolice', source)
        end
    end
end)

RegisterNetEvent('smoke-selldrugs:alertPolice')
AddEventHandler('smoke-selldrugs:alertPolice', function(sellerSource)
    local xPlayers = ESX.GetPlayers()
    local sellerCoords = GetEntityCoords(GetPlayerPed(sellerSource))
    
    for i=1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            xPlayer.showNotification("~r~Possible vente de drogue signalée")
            TriggerClientEvent('smoke-selldrugs:createAlertBlip', xPlayers[i], sellerCoords)
        end
    end
end) 
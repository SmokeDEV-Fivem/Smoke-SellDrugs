local ESX = exports["es_extended"]:getSharedObject()
local cooldown = false
local currentZone = nil
local usedPeds = {}
local isSellingInProgress = false

Citizen.CreateThread(function()
    RequestAnimDict("gestures@m@standing@casual")
    while not HasAnimDictLoaded("gestures@m@standing@casual") do
        Citizen.Wait(0)
    end
end)

local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

local function PlayDealAnimation(ped)
    local playerPed = PlayerPedId()
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)
    
    LoadAnimDict("mp_common")
    
    local prop = CreateObject(GetHashKey("prop_paper_bag_small"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0.0, 0.0, 0.0, 270.0, 0.0, true, true, false, true, 1, true)
    
    local pedCoords = GetEntityCoords(ped)
    local playerCoords = GetEntityCoords(playerPed)
    
    local midPoint = vector3(
        (pedCoords.x + playerCoords.x) / 2,
        (pedCoords.y + playerCoords.y) / 2,
        pedCoords.z
    )
    
    local dx = pedCoords.x - playerCoords.x
    local dy = pedCoords.y - playerCoords.y
    local heading = math.deg(math.atan2(dy, dx))
    local playerTargetCoords = vector3(
        midPoint.x - math.cos(math.rad(heading)) * 0.5,
        midPoint.y - math.sin(math.rad(heading)) * 0.5,
        midPoint.z
    )
    
    local pedTargetCoords = vector3(
        midPoint.x + math.cos(math.rad(heading)) * 0.5,
        midPoint.y + math.sin(math.rad(heading)) * 0.5,
        midPoint.z
    )
    
    TaskGoToCoordAnyMeans(playerPed, playerTargetCoords.x, playerTargetCoords.y, playerTargetCoords.z, 1.0, 0, 0, 786603, 0)
    TaskGoToCoordAnyMeans(ped, pedTargetCoords.x, pedTargetCoords.y, pedTargetCoords.z, 1.0, 0, 0, 786603, 0)
    Wait(1000)
    
    TaskTurnPedToFaceEntity(playerPed, ped, -1)
    TaskTurnPedToFaceEntity(ped, playerPed, -1)
    Wait(1000)
    
    TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, 2000, 0, 0, false, false, false)
    TaskPlayAnim(ped, "mp_common", "givetake1_a", 8.0, -8.0, 2000, 0, 0, false, false, false)
    Wait(1000)
    DetachEntity(prop, true, false)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.15, 0.0, 0.0, 0.0, 270.0, 0.0, true, true, false, true, 1, true)
    Wait(1000)
    DeleteObject(prop)
    ClearPedTasks(playerPed)
    ClearPedTasks(ped)
    
    SetBlockingOfNonTemporaryEvents(ped, false)
    
    TaskWanderStandard(ped, 10.0, 10)
    
    RemoveAnimDict("mp_common")
end

function GetHeadingFromCoords(dx, dy)
    return math.deg(math.atan2(dy, dx)) + 90.0
end

local function IsPlayerInSellZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(Config.Zones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            currentZone = zone
            return true
        end
    end
    currentZone = nil
    return false
end

local function GetRandomPrice(drogue)
    return math.random(drogue.minPrice, drogue.maxPrice)
end

local function HasDrugs()
    for _, drogue in ipairs(Config.Drogues) do
        local count = exports.ox_inventory:GetItemCount(drogue.item)
        if count > 0 then
            return drogue
        end
    end
    return nil
end

local function HasAlreadySoldToPed(ped)
    local pedNetId = NetworkGetNetworkIdFromEntity(ped)
    return usedPeds[pedNetId] ~= nil
end

local function MarkPedAsUsed(ped)
    local pedNetId = NetworkGetNetworkIdFromEntity(ped)
    usedPeds[pedNetId] = true
    
    exports.ox_target:removeLocalEntity(ped, {'vente_drogue'})
end

RegisterNetEvent('smoke-selldrugs:createAlertBlip')
AddEventHandler('smoke-selldrugs:createAlertBlip', function(coords)
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 128)
    
    local centerBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(centerBlip, 161)
    SetBlipColour(centerBlip, 1)
    SetBlipScale(centerBlip, 1.0)
    SetBlipAsShortRange(centerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Vente de drogue suspectée")
    EndTextCommandSetBlipName(centerBlip)
    
    Citizen.SetTimeout(120000, function()
        RemoveBlip(blip)
        RemoveBlip(centerBlip)
    end)
end)

local function GetRandomQuantity()
    local chances = {
        [1] = 15,
        [2] = 30,
        [3] = 30,
        [4] = 15,
        [5] = 10
    }
    
    local total = 0
    for _, chance in pairs(chances) do
        total = total + chance
    end
    
    local roll = math.random(1, total)
    local current = 0
    
    for quantity, chance in pairs(chances) do
        current = current + chance
        if roll <= current then
            return quantity
        end
    end
    
    return 2
end

local function VendreDrogue(ped)
    if cooldown then
        ESX.ShowNotification("~r~Vous devez attendre avant de vendre à nouveau")
        return
    end

    if HasAlreadySoldToPed(ped) then
        ESX.ShowNotification("~r~Cette personne ne veut plus vous acheter de drogue")
        return
    end

    if not IsPlayerInSellZone() then
        ESX.ShowNotification("~r~Vous devez être dans une zone de vente")
        return
    end

    local drogue = HasDrugs()
    if not drogue then
        ESX.ShowNotification("~r~Vous n'avez pas de drogue à vendre")
        return
    end

    -- Vérifier d'abord s'il y a assez de policiers
    TriggerServerEvent('smoke-selldrugs:checkCops', ped, NetworkGetNetworkIdFromEntity(ped))
end

RegisterNetEvent('smoke-selldrugs:continueVente')
AddEventHandler('smoke-selldrugs:continueVente', function(pedNetId)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    
    if math.random(100) > Config.ChanceReussite then
        MarkPedAsUsed(ped)
        
        ClearPedTasks(ped)
        PlayPedAmbientSpeechNative(ped, "GENERIC_NO", "SPEECH_PARAMS_FORCE")
        TaskPlayAnim(ped, "gestures@m@standing@casual", "gesture_no_way", 8.0, -8.0, -1, 48, 0, false, false, false)
        
        Citizen.Wait(1500)
        TaskWanderStandard(ped, 10.0, 10)
        return
    end

    MarkPedAsUsed(ped)

    local drogue = HasDrugs()
    local price = GetRandomPrice(drogue)
    local quantity = GetRandomQuantity()
    price = price * quantity

    PlayDealAnimation(ped)
    
    TriggerServerEvent('smoke-selldrugs:sellDrug', drogue.item, quantity, price)
    
    cooldown = true
    SetTimeout(Config.CooldownVente * 1000, function()
        cooldown = false
    end)
end)

exports.ox_target:addGlobalPed({
    {
        name = 'vente_drogue',
        icon = 'fas fa-cannabis',
        label = 'Vendre de la drogue',
        distance = 2.0,
        canInteract = function(entity)
            if not IsPlayerInSellZone() then 
                return false 
            end
            if cooldown then 
                return false 
            end
            if IsPedAPlayer(entity) then 
                return false 
            end
            if IsPedInAnyVehicle(entity) then 
                return false 
            end
            if IsEntityDead(entity) then 
                return false 
            end
            if HasAlreadySoldToPed(entity) then
                return false
            end
            return HasDrugs() ~= nil
        end,
        onSelect = function(data)
            VendreDrogue(data.entity)
        end
    }
}) 

-- apx-money/client/main.lua

local function isNearLocation(locations)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    for _, loc in ipairs(locations) do
        local distance = GetDistanceBetweenCoords(playerCoords, loc.x, loc.y, loc.z, true)
        if distance < 2.0 then
            return true
        end
    end
    return false
end

local function createBlips()
    for _, loc in ipairs(Config.BankLocations) do
        local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
        SetBlipSprite(blip, 108) -- 108 is the bank blip sprite
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 2) -- Green color
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bank")
        EndTextCommandSetBlipName(blip)
    end

    for _, loc in ipairs(Config.ATMLocations) do
        local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
        SetBlipSprite(blip, 277) -- 277 is the ATM blip sprite
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3) -- Light blue color
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("ATM")
        EndTextCommandSetBlipName(blip)
    end
end

-- Create blips on resource start
Citizen.CreateThread(function()
    createBlips()
end)

-- Keybind to open the bank/ATM UI
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 38) then -- E key
            if isNearLocation(Config.BankLocations) or isNearLocation(Config.ATMLocations) then
                print("Opening NUI...")
                SetNuiFocus(true, true)
                SendNUIMessage({
                    type = isNearLocation(Config.BankLocations) and 'openBank' or 'openATM'
                })
            end
        end
    end
end)

-- NUI callback for closing the UI
RegisterNUICallback('close', function(data, cb)
    print("Closing NUI...")
    SetNuiFocus(false, false)
    cb('ok')
end)

-- NUI callback for depositing money
RegisterNUICallback('deposit', function(data, cb)
    local amount = tonumber(data.amount)
    if amount and amount > 0 then
        TriggerServerEvent('apx-money:deposit', amount)
    else
        TriggerEvent('apx-money:error', "Invalid amount entered.")
    end
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    local amount = tonumber(data.amount)
    if amount and amount > 0 then
        TriggerServerEvent('apx-money:withdraw', amount)
    else
        TriggerEvent('apx-money:error', "Invalid amount entered.")
    end
    cb('ok')
end)

RegisterNetEvent('apx-money:error')
AddEventHandler('apx-money:error', function(message)
    SendNUIMessage({
        type = 'error',
        message = message
    })
end)

RegisterNetEvent('apx-money:success')
AddEventHandler('apx-money:success', function(message)
    SendNUIMessage({
        type = 'success',
        message = message
    })
end)

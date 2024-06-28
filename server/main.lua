local oxmysql = exports['oxmysql']

-- Ensure that Apex.Functions is available
if not Apex or not Apex.Functions then
    Apex = {}
    Apex.Functions = {}

    function Apex.Functions.addMoney(identifier, amount, type)
        local column = type == 'bank' and 'bank' or 'cash'
        oxmysql:execute('UPDATE users SET ' .. column .. ' = ' .. column .. ' + ? WHERE identifier = ?', {amount, identifier})
    end

    function Apex.Functions.removeMoney(identifier, amount, type)
        local column = type == 'bank' and 'bank' or 'cash'
        oxmysql:execute('UPDATE users SET ' .. column .. ' = ' .. column .. ' - ? WHERE identifier = ?', {amount, identifier})
    end

    function Apex.Functions.getMoney(identifier, type, callback)
        local column = type == 'bank' and 'bank' or 'cash'
        oxmysql:execute('SELECT ' .. column .. ' FROM users WHERE identifier = ?', {identifier}, function(result)
            if result and result[1] then
                callback(result[1][column])
            else
                callback(0)
            end
        end)
    end
end

-- Function to set initial money for new players
function setInitialMoney(identifier)
    oxmysql:execute('SELECT * FROM users WHERE identifier = ?', {identifier}, function(result)
        if #result == 0 then
            -- User is new, set initial cash and bank values
            oxmysql:execute('INSERT INTO users (identifier, cash, bank) VALUES (?, ?, ?)', {identifier, Config.StartingCash, Config.StartingBank})
            print("Set initial cash and bank for new player:", identifier)
        end
    end)
end

-- Function to deposit money into the bank
function depositMoney(identifier, amount, playerId)
    if amount <= 0 then
        TriggerClientEvent('apx-money:notify', playerId, "You cannot deposit $0 or less.")
        TriggerClientEvent('apx-money:error', playerId, "You cannot deposit $0 or less.")
        return
    end
    Apex.Functions.getMoney(identifier, 'cash', function(cash)
        if cash >= amount then
            Apex.Functions.removeMoney(identifier, amount, 'cash')
            Apex.Functions.addMoney(identifier, amount, 'bank')
            print("Deposited $" .. tostring(amount) .. " to bank for player:", identifier)
            TriggerClientEvent('apx-money:notify', playerId, "Successfully deposited $" .. amount .. ".")
            TriggerClientEvent('apx-money:success', playerId, "Successfully deposited $" .. amount .. ".")
        else
            TriggerClientEvent('apx-money:notify', playerId, "You do not have enough cash.")
            TriggerClientEvent('apx-money:error', playerId, "You do not have enough cash.")
        end
    end)
end

-- Function to withdraw money from the bank
function withdrawMoney(identifier, amount, playerId)
    if amount <= 0 then
        TriggerClientEvent('apx-money:notify', playerId, "You cannot withdraw $0 or less.")
        TriggerClientEvent('apx-money:error', playerId, "You cannot withdraw $0 or less.")
        return
    end
    Apex.Functions.getMoney(identifier, 'bank', function(bank)
        if bank >= amount then
            Apex.Functions.removeMoney(identifier, amount, 'bank')
            Apex.Functions.addMoney(identifier, amount, 'cash')
            print("Withdrew $" .. tostring(amount) .. " from bank for player:", identifier)
            TriggerClientEvent('apx-money:notify', playerId, "Successfully withdrew $" .. amount .. ".")
            TriggerClientEvent('apx-money:success', playerId, "Successfully withdrew $" .. amount .. ".")
        else
            TriggerClientEvent('apx-money:notify', playerId, "You do not have enough money in your bank.")
            TriggerClientEvent('apx-money:error', playerId, "You do not have enough money in your bank.")
        end
    end)
end

-- Server events for deposits and withdrawals
RegisterNetEvent('apx-money:deposit')
AddEventHandler('apx-money:deposit', function(amount)
    local playerId = source
    local identifier = GetPlayerIdentifiers(playerId)[1]
    amount = tonumber(amount)
    if amount and amount > 0 then
        depositMoney(identifier, amount, playerId)
    else
        TriggerClientEvent('apx-money:notify', playerId, "Invalid deposit amount.")
        TriggerClientEvent('apx-money:error', playerId, "Invalid deposit amount.")
    end
end)

RegisterNetEvent('apx-money:withdraw')
AddEventHandler('apx-money:withdraw', function(amount)
    local playerId = source
    local identifier = GetPlayerIdentifiers(playerId)[1]
    amount = tonumber(amount)
    if amount and amount > 0 then
        withdrawMoney(identifier, amount, playerId)
    else
        TriggerClientEvent('apx-money:notify', playerId, "Invalid withdrawal amount.")
        TriggerClientEvent('apx-money:error', playerId, "Invalid withdrawal amount.")
    end
end)

-- Event for player connecting to set initial money
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local playerId = source
    local identifier = GetPlayerIdentifiers(playerId)[1]
    deferrals.defer()
    Citizen.Wait(0)
    deferrals.update(string.format("Hello %s. Your data is being checked...", playerName))
    Citizen.Wait(1000)
    setInitialMoney(identifier)
    deferrals.done()
end)

-- Event to handle client notifications
RegisterNetEvent('apx-money:notify')
AddEventHandler('apx-money:notify', function(message)
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 0, 0},
        multiline = true,
        args = {"Apex Money", message}
    })
end)

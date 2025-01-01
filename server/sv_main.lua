ESX = exports["es_extended"]:getSharedObject()

SvConfig = {
    Inv = "ox", -- qb(=lj) or ox [Inventory system]
    webhook = "", -- Add Discord webhook
    FivemerrApiToken = '',
}
local function ConfigInvInvalid()
    print('^1[Error] Your SvConfig.Inv isnt set.. you probably had a typo\nYou have it set as= SvConfig.Inv = "'.. SvConfig.Inv .. '"')
end

RegisterNetEvent("ps-camera:cheatDetect", function()
    DropPlayer(source, "Cheater Detected")
end)

RegisterNetEvent("ps-camera:requestWebhook", function(Key)
    local source = source
    local event = ("ps-camera:grabbed%s"):format(Key)

    if SvConfig.webhook == '' then
        print("^1[Error] A webhook is missing in: SvConfig.webhook")
    else
        TriggerClientEvent(event, source, SvConfig.webhook)
    end
end)

RegisterNetEvent('ps-camera:requestFivemerrToken', function(Key)
    local source = source
    local event = ("ps-camera:grabbed%s"):format(Key)

    if Config.UseFivemerr == false then
        return print("^1[Error] Requesting Fivemerr token but Config.UseFivemerr set to false.")
    end

    if SvConfig.FivemerrApiToken == '' then
        return print("^1[Error] Your Fivemerr API Token is missing in: Config.FivemerrApiToken")
    end

    TriggerClientEvent(event, source, SvConfig.FivemerrApiToken)
end)

RegisterNetEvent("ps-camera:CreatePhoto", function(url)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local coords = GetEntityCoords(GetPlayerPed(source))

    TriggerClientEvent("ps-camera:getStreetName", source, url, coords)
end)

RegisterNetEvent("ps-camera:savePhoto", function(url, streetName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local location = streetName

    local metadata = {
        ps_image = url,
        location = location
    }

    if not (SvConfig.Inv == "ox") then
        ConfigInvInvalid()
        return
    end

    local ox_inventory = exports.ox_inventory

    -- Check if the player can carry the item
    if not ox_inventory:CanCarryItem(source, "photo", 1) then
        return TriggerClientEvent('esx:showNotification', source, "Du kan ikke bære flere billeder!")
    end

    -- Add the item to the player's inventory
    local success, response = ox_inventory:AddItem(source, "photo", 1, metadata)

    print("metadata", json.encode(metadata))
    
    if success then
        TriggerClientEvent('esx:showNotification', source, "Du har modtaget et foto!")
    else
        -- Handle possible failure reasons based on the response
        if response == "inventory_full" then
            TriggerClientEvent('esx:showNotification', source, "Din inventar er fuld!")
        elseif response == "invalid_item" then
            print("^1[Error] The item 'photo' is not valid. Check your item configuration.")
        elseif response == "invalid_inventory" then
            print("^1[Error] The target inventory is not valid or not loaded.")
        else
            print("^1[Error] Failed to add photo: " .. (response or "unknown error"))
        end
    end
end)

ESX.RegisterUsableItem("camera", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if not (SvConfig.Inv == "ox") then
        ConfigInvInvalid()
        return
    end

    if Config.UseFivemerr == false then
        if not SvConfig.webhook or SvConfig.webhook == nil or SvConfig.webhook == "" then
            print("^1[Error] A webhook is missing in: SvConfig.webhook")
            return
        end
    else
        if not SvConfig.FivemerrApiToken or SvConfig.FivemerrApiToken == '' then
            return print("^1[Error] A webhook is missing in: SvConfig.FivemerrApiToken")
        end
    end

    if SvConfig.Inv == "ox" then
        local ox_inventory = exports.ox_inventory
        if ox_inventory:GetItem(source, "camera", nil, true) > 0 then
            TriggerClientEvent("ps-camera:useCamera", source)
        end
    else
        if xPlayer.getInventoryItem("camera").count > 0 then
            TriggerClientEvent("ps-camera:useCamera", source)
        end
    end
end)

function UseCam(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if not (SvConfig.Inv == "ox") then
        ConfigInvInvalid()
        return
    end

    if not SvConfig.webhook or SvConfig.webhook == nil or SvConfig.webhook == "" then
        print("^1[Error] A webhook is missing in: SvConfig.webhook")
        return
    end

    if SvConfig.Inv == "ox" then
        local ox_inventory = exports.ox_inventory
        if ox_inventory:GetItem(source, 'dslrcamera', nil, true) > 0 then
            TriggerClientEvent("ps-camera:useCamera", source)
        else
            TriggerClientEvent('esx:showNotification', source, "Du har ikke et kamera", "error")
        end
    else
        local cameraItem = xPlayer.getInventoryItem("dslrcamera")
        if cameraItem.count > 0 then
            TriggerClientEvent("ps-camera:useCamera", source)
        else
            TriggerClientEvent('esx:showNotification', source, "Du har ikke et kamera", "error")
        end
    end
end

exports("UseCam", UseCam)

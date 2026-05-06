local QBCore = exports['qb-core']:GetCoreObject()

local allowedJobs = {
    police = true,
    fire = true,
    ambulance = true,
    staff = true,
    highways = true,
}

local blipSettings = {
    ["ACFS"] = { label = "Fire Vehicle", color = 1, sprite = 56 },
    ["ACPS"] = { label = "Police Vehicle", color = 3, sprite = 60 },
    ["ACHS"] = { label = "Health Vehicle", color = 2, sprite = 60 },
    ["ACHA"] = { label = "Highways Vehicle", color = 28, sprite = 60 },
    ["GOV"] = { label = "Government Vehicle", color = 38, sprite = 60 },
    ["ACG6"] = { label = "Gruppe6 Vehicle", color = 33, sprite = 60 },

} 
 
local plateBlips = {}
local shouldTrack = false

local function clearOldBlips()
    for veh, blip in pairs(plateBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    plateBlips = {}
end

local function scanVehicles()
    if not shouldTrack then
        clearOldBlips()
        return
    end

    clearOldBlips()

    local vehicles = GetGamePool("CVehicle")
    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) and not IsEntityDead(veh) then
            local plate = string.upper(GetVehicleNumberPlateText(veh))

            for key, data in pairs(blipSettings) do
                if string.find(plate, key) then
                    local blip = AddBlipForEntity(veh)
                    SetBlipSprite(blip, data.sprite)
                    SetBlipColour(blip, data.color)
                    SetBlipScale(blip, 0.75)
                    SetBlipDisplay(blip, 4)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(data.label)
                    EndTextCommandSetBlipName(blip)

                    if IsVehicleSirenOn(veh) then
                        SetBlipFlashes(blip, true)
                    end

                    plateBlips[veh] = blip
                    break
                end
            end
        end
    end
end

-- Thread that runs the scan when allowed
CreateThread(function()
    while true do
        if shouldTrack then
            scanVehicles()
        end
        Wait(2000)
    end
end)

-- Update tracking status based on job
local function updateTrackingState()
    local job = QBCore.Functions.GetPlayerData().job.name
    shouldTrack = allowedJobs[job] or false
    if not shouldTrack then
        clearOldBlips()
    end
end

-- On player load
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    updateTrackingState()
end)

-- On job update
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
    updateTrackingState()
end)

-- Initial load if already in server
CreateThread(function()
    while not QBCore.Functions.GetPlayerData().job do Wait(100) end
    updateTrackingState()
end)

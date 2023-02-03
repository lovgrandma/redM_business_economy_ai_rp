AiSpawn = {}

Citizen.CreateThread(function()
    Citizen.Wait(5)
    print("Add Event Handlers")
    RegisterNetEvent("entityDamaged", function()
    
    end)
    AddEventHandler("gameEventTriggered", function(eventName, args)
        print("yes1")
    end)
    
    AddEventHandler("entityDamaged", function(eventName, args)
        print("yes2")
    end)
end)

-- This ensures that AI that are driving carriages are not frightened by close users. This means that users can ride on the side of carriages by jumping onto them
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        local vehiclePool = GetGamePool('CVehicle') -- Get the list of vehicles (entities) from the pool
        for i = 1, #vehiclePool do -- loop through each vehicle (entity)
            Citizen.Wait(50)
            local pedVehicleSeat = GetPedInVehicleSeat(vehiclePool[i], -1)
            if pedVehicleSeat then
                local coords = GetEntityCoords(PlayerPedId())
                local pedUpdatedCoords = GetEntityCoords(pedVehicleSeat)
                if coords and pedUpdatedCoords then
                    local dist = Vdist(pedUpdatedCoords, coords)
                    if dist < 7.5 then
                        TaskSetBlockingOfNonTemporaryEvents(pedVehicleSeat, true)
                    else 
                        TaskSetBlockingOfNonTemporaryEvents(pedVehicleSeat, false)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("allowSpawnPed:Animal", function(eventParam1, eventParam2)
    -- Code here will be executed once the event is triggered.
    local randomWait = math.floor(math.random(2500, 15000))
    print('Received allowSpawnPed:Animal', randomWait)
    Citizen.Wait(randomWait)
    if math.random() > .75 then
        AiSpawn.RandomAttackFromLocalAi()
    end
    if math.random() > .5 then
        if math.random() > .5 then
            AiSpawn.SpawnRandomAnimalNearPlayer()
        end
    else 
        if math.random() > .5 then
            AiSpawn.SpawnRandomPedNearPlayerWithModel()
        end
    end
end)

-- Retrieves random animal type from table defined in Animal file
function AiSpawn.GetRandomAnimal(coords)
    if #Animals > 0 then
        local value = math.random(#Animals)
        return Animals[value]
    end
end

function AiSpawn.GetRandomDistanceCoords(coords)
    local x = 0
    local y = 0
    local z = coords.z
    local xDistance = 65 -- Default 55
    local yDistance = 65 -- Default 55
    local distanceMax = 135 -- Default 145
    local proximityModifier = 35
    if math.random() > .85 and distanceMax > xDistance + proximityModifier and distanceMax > yDistance + proximityModifier then
        distanceMax = distanceMax - proximityModifier
        if math.random() > .85 and distanceMax > xDistance + proximityModifier and distanceMax > yDistance + proximityModifier then
            distanceMax = distanceMax - proximityModifier
        end
    end
    -- print(distanceMax, 'Max Distance')
    if math.random() > .85 then
        x = coords.x + math.random(xDistance, distanceMax)
    else
        x = coords.x - math.random(xDistance, distanceMax)
    end
    if math.random() > .5 then
        y = coords.y + math.random(yDistance, distanceMax)
    else
        y = coords.y - math.random(yDistance, distanceMax)
    end
    local v = vector3(x, y, z + 1)
    return v
end

function CreateTempBlip(coords, animal)
    print('Create Blip', coords, animal)
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 564457427, 1)
    SetBlipScale(blip, 1.5)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, animal)
    Citizen.Wait(10000)
    RemoveBlip(blip)
end

function AiSpawn.RandomAttackFromLocalAi()
    local playerPed = PlayerPedId()
    local existingEntity = DoesEntityExist(playerPed)
    if playerPed and existingEntity then
        local pCoord = GetEntityCoords(playerPed)
        -- local localPed = GetClosestPed(pCoord.x, pCoord.y, pCoord.z, 65, 1, 0, 1, 1, -1)
        local allPeds = GetGamePool('CPed')
        local attack = false
        for i = 1, math.random(1, 10), 1 do
            Citizen.Wait(250) -- slowdown
            local randomPed = allPeds[math.random(1, #allPeds)]
            local existingEntity2 = DoesEntityExist(randomPed)
            if existingEntity2 then
                local pedPlayer = IsPedAPlayer(randomPed)
                if pedPlayer == false then
                    local pedCoords = GetEntityCoords(randomPed)
                    local dist = #(pCoord - pedCoords)
                    if math.random() > .5 then
                        if Entity(randomPed).state.safeAi or Entity(randomPed).state.safeCompanion then
                            print('Friendly, dont attack')
                            break
                        end
                        if dist < 65 and Entity(randomPed).state.safeAi == nil then
                            print('Do Attack')
                            TaskCombatPed(randomPed, playerPed)
                            break
                        end
                    end
                end
            end
        end
        
    end
    -- GetClosestPed
end

function AiSpawn.SpawnRandomAnimalNearPlayer()
    local playerPed = PlayerPedId()
    if playerPed then
        local pCoord = GetEntityCoords(playerPed)
        if pCoord then
            local randomAnimal = AiSpawn.GetRandomAnimal(pCoord) -- Get Animal based on player coords, change likelihood of animal spawning based on user location
            if randomAnimal then
                local pedHash = GetHashKey(randomAnimal.name)
                RequestModel(pedHash)
                Citizen.Wait(250)
                local waitAttemptLoad = 0
                local randomLoopMax = math.floor(math.random(1, 6))
                local safeDistanceCoords = AiSpawn.GetRandomDistanceCoords(pCoord)
                for a = 1, randomLoopMax, 1 do
                    while not HasModelLoaded(pedHash) and waitAttemptLoad < 4 do
                        waitAttemptLoad = waitAttemptLoad + 1
                        RequestModel(pedHash)
                        Citizen.Wait(150) -- slowdown
                    end
                    if HasModelLoaded(pedHash) then
                        CreateTempBlip(safeDistanceCoords, randomAnimal.name)
                        print("Spawning AI", randomAnimal.name, a, safeDistanceCoords)
                        local goodZ = safeDistanceCoords.z
                        local found, groundZ = GetGroundZAndNormalFor_3dCoord(safeDistanceCoords.x + (a * 3), safeDistanceCoords.y + (a * 3), safeDistanceCoords.z)
                        if found then
                            goodZ = groundZ + 1
                        end
                        local createdPed = CreatePed(pedHash, safeDistanceCoords.x + (a * 3), safeDistanceCoords.y + (a * 3), goodZ, math.random(1, 359), false, false)
                        Citizen.Wait(250) -- Spawn Wait
                        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, createdPed, 0, 0) -- Load Default Ped Outfit
                        Citizen.Wait(250)
                        TaskWanderStandard(createdPed, 10.0, 10) -- Task Wander
                        -- Conditional Attack thread
                        Citizen.CreateThread(function()
                            local attempts = 0
                            Citizen.Wait(1500) -- slowdown
                            local setAttack = false
                            local animalAlive = true
                            while animalAlive do
                                local animalClose = false
                                for i = 1, 255, 1 do
                                    Citizen.Wait(250)
                                    if NetworkIsPlayerActive(i) then
                                        Citizen.Wait(500) -- slowdown
                                        local coords = GetEntityCoords(GetPlayerPed(i))
                                        local pedUpdatedCoords = GetEntityCoords(createdPed)
                                        local dist = #(pedUpdatedCoords - coords)
                                        if dist > 75 and IsPedDeadOrDying(createdPed) then
                                            animalClose = true -- If ped is dying then remove ped from game memory
                                            break
                                        end
                                        if dist <= 135 then
                                            print('Animal is close to user', randomAnimal.name, pedUpdatedCoords, coords)
                                            if dist < math.random(35, 95) then
                                                if math.random() > .85 then
                                                    local loopPlayerPed = GetPlayerPed(i)
                                                    if loopPlayerPed and setAttack == false then
                                                        print('Attempt attack player', loopPlayerPed)
                                                        TaskCombatPed(createdPed, loopPlayerPed)
                                                    end
                                                end
                                                setAttack = true
                                            end
                                            animalClose = true
                                            break
                                        end
                                    end
                                end
                                if animalClose == false then
                                    animalAlive = false
                                end
                                attempts = attempts + 1
                            end
                            Citizen.InvokeNative(0xB736A491E64A32CF, createdPed) -- Set entity as no longer needed
                            DeleteEntity(createdPed)
                            print("Deleting Entity!", createdPed, randomAnimal.name)
                        end)
                    end
                end
            end
        end
    end
end

function AiSpawn.SpawnRandomPedNearPlayerWithModel()

end
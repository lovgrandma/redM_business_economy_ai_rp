-- This is used to spawn EXTRA ai based on SQL data onto map around areas users are around. 
-- This is not for all spawned AI's that naturally spawn that are manipulated on client. See client folder for that functionality

local tick = 0 -- Can be useful to signify a sufficient amount of time has passed to perform X action with: if tick % 1000 == 0 then -> get AI to do something else
local random1 = 0

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(1000)
--         tick = tick + 1000
--         for _, playerId in ipairs(GetPlayers()) do
--             local player = GetPlayerPed(playerId)
--             print(('Player %s with id %i is in the server, %i'):format(player, playerId, tick))
--             local pos = GetEntityCoords(player, true) -- get the coords of the ped
--             print(pos, random1)
--             if random1 < 1 then
--                 random1 = random1 + 1
--                 print('Attempt spawn AI')
--                 CreatePed(GetHashKey('a_c_bear_01'), pos.x, pos.y + 10, pos.z, 1.0, true, true) -- Create random ped
--             end
--             -- ('%s'):format('text') is same as string.format('%s', 'text)
--         end
--     end
-- end)

-- Random Ped Attack Other Ped or Player
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        local allPeds = GetAllPeds()
        local maxAttack = 5
        local currentAttack = 0
        local maxIteration = 50 -- Max iteration through random NPC's to check for possible attack combinations
        for i = 1, math.random(1, maxIteration), 1 do
            local aPed = allPeds[math.random(1, #allPeds)]
            Citizen.Wait(350) -- slowdown
            if math.random() > .75 and currentAttack < maxAttack then
                local randomNum = math.random(1, #allPeds)
                if randomNum == i then
                    if randomNum < #allPeds / 2 then
                        randomNum = randomNum + 1
                    elseif randomNum > #allPeds / 2 then
                        randomNum = randomNum - 1
                    end
                    local randomPed = allPeds[randomNum]
                    -- print(#allPeds, allPeds[i], randomPed, IsPedAPlayer(allPeds[i]), DoesEntityExist(allPeds[i]), DoesEntityExist(randomPed))
                    local existingEntity = DoesEntityExist(aPed)
                    local existingOtherEntity = DoesEntityExist(randomPed)
                    if existingEntity == 1 and existingOtherEntity == 1 then
                        local ent = IsPedAPlayer(aPed)
                        local ent2 = IsPedAPlayer(randomPed)
                        if ent == false and ent2 == false then -- Dont allow attacking of real players through this function, for that use client AiSpawn.RandomAttackFromLocalAi
                            local pedCoords = GetEntityCoords(aPed)
                            local otherPedCoords = GetEntityCoords(randomPed)
                            local dist = #(pedCoords - otherPedCoords)
                            if dist < 65 then -- If close, schedule ped attack
                                print('Server task attack random ped', aPed, randomPed, 'Distance', dist)
                                currentAttack = currentAttack + 1
                                TaskCombatPed(aPed, randomPed)
                                if math.random() > .25 then -- Schedule ped attacks back
                                    if ent2 == false then -- Dont take control from real player
                                        TaskCombatPed(randomPed, aPed)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Allow Animal Ped Spawn all
RegisterServerEvent("allowSpawnPed:Animal")
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(math.random(2000, 50000))
        TriggerClientEvent("allowSpawnPed:Animal", -1, -1, -1)
    end
end)

RegisterNetEvent('gameEventTriggered', function(eventName, args)
    print(eventName, args)
    if eventName == 'CEventNetworkEntityDamage' then
        print("Network damage")
    end
end)
local maxai = Config.maxai


-- DoSpawnInFront
-- DoSpawnRandom
-- DoSpawnRandomFromPoint

-- TaskCombatPed

-- Check db for loaded AI, attach db call to all AI on death or despawn to ensure that AI pool is reduced

-- Load random Antogonistic animal
-- Load random friendly animal
-- Load random thief
-- Load random serial killer (kill 1 person)
-- Load random terrorist (kill everyone)
-- Load random gang (group of antogonistic friendlies)
-- Load random 2 gangs (group of antagonistic friendlies fighting eachother)
-- Load kidnapper (kill user with non lethal, take back to home base)
-- Load group kidnapper (group of kidnappers, non lethal, take user when passed out to home)
-- Load friendly caravan (group of friendlies that only attack if attacked, traveling in large caravan) this will likely be very difficult to do
-- Load gang caravan (traveling gang, antogonistic)
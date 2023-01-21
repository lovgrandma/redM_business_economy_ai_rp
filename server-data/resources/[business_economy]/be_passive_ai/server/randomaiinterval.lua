local tick = 0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        tick = tick + 1
        if tick < 5 then
            print(tick)
        end
        if tick % 100 == 0 then
            print(tick)
        end
    end
end)

local maxai = Config.maxai

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
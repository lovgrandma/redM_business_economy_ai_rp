local blips_table = {}

Citizen.CreateThread(function()
    Citizen.Wait(5 * 1000)
    for k, v in pairs(Config.blips) do
        local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip, v.hash, 1)
        SetBlipScale(blip, v.scale)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.name)
        table.insert(blips_table, blip)
    end
    -- for k,v in pairs(blips_table) do 
    --     print(v)
    -- end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for k, v in pairs(blips_table) do
            RemoveBlip(v)
        end
    end
end)
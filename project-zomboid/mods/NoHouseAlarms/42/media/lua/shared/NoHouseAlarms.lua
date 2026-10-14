-- Forces House Alarms Frequency = Never and stops zombies from triggering alarms.
-- Also slows zombie migration into cleared areas and stops population growth.
local function setOption(opts, name, value)
    local opt = opts:getOptionByName(name)
    if opt then opt:setValue(value) end
end

local function applySettings()
    local opts = getSandboxOptions()
    if not opts then return end
    pcall(function()
        setOption(opts, "Alarm", 1)
        setOption(opts, "ZombieLore.TriggerHouseAlarm", false)
        setOption(opts, "ZombieRespawn", 4)
        setOption(opts, "ZombieConfig.RespawnHours", 0.0)
        setOption(opts, "ZombieConfig.RedistributeHours", 168.0)
        setOption(opts, "ZombieConfig.PopulationPeakMultiplier", 1.0)
        opts:toLua()
    end)
    print("[NoHouseAlarms] alarms Never, respawn None, redistribute 168h, peak 1.0x")
end

Events.OnInitGlobalModData.Add(applySettings)
Events.OnGameStart.Add(applySettings)

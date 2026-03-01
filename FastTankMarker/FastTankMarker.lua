-- Initialize the addon
local FastTankMarker = CreateFrame("Frame")

-- Define symbols for marking
local MARKS = {
    [1] = 6,  -- Blue Square (6)
    [2] = 7,  -- Red Cross (7)
    [3] = 4,  -- Green Triangle (4)
}


local pendingMark = false  -- defer marking until out of combat

-- Check if the player is a tank
local function IsTank(unit)
    return UnitGroupRolesAssigned(unit) == "TANK"
end

-- Function to mark tanks in 5-man groups only
local function MarkTanks()
    -- SetRaidTarget is protected during combat lockdown
    if InCombatLockdown and InCombatLockdown() then
        pendingMark = true
        return
    end
    pendingMark = false

    -- Check if we are in a raid group
    if IsInRaid and IsInRaid() then
        return  -- Do nothing if the player is in a raid
    end

    local tankCount = 1  -- Counter for the tanks

    -- party1..party4 are the other members in a 5-man group
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) and IsTank(unit) and not GetRaidTargetIndex(unit) then
            -- Mark up to three tanks
            if tankCount <= 3 then
                SetRaidTarget(unit, MARKS[tankCount])
                tankCount = tankCount + 1
            end
        end
    end
end

-- Event handler for when group members change
FastTankMarker:RegisterEvent("GROUP_ROSTER_UPDATE")
FastTankMarker:RegisterEvent("PLAYER_ENTERING_WORLD")
FastTankMarker:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Execute the marking when events are triggered
FastTankMarker:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        if pendingMark then
            MarkTanks()
        end
        return
    end
    MarkTanks()
end)

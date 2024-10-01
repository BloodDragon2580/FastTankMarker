-- Initialize the addon
local FastTankMarker = CreateFrame("Frame")

-- Define symbols for marking
local MARKS = {
    [1] = 6,  -- Blue Square (6)
    [2] = 7,  -- Red Cross (7)
    [3] = 4,  -- Green Triangle (4)
}

-- Check if the player is a tank
local function IsTank(unit)
    return UnitGroupRolesAssigned(unit) == "TANK"
end

-- Function to mark tanks
local function MarkTanks()
    local numGroupMembers = GetNumGroupMembers()
    local unitPrefix = IsInRaid() and "raid" or "party"
    local tankCount = 1  -- Counter for the tanks

    -- Loop through all group members
    for i = 1, numGroupMembers do
        local unit = unitPrefix .. i
        if IsTank(unit) and not GetRaidTargetIndex(unit) then
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

-- Execute the marking when events are triggered
FastTankMarker:SetScript("OnEvent", function(self, event, ...)
    MarkTanks()
end)

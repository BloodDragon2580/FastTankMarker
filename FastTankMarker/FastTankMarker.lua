-- Initialize the addon
local FastTankMarker = CreateFrame("Frame")

-- Define symbols for marking
local MARKS = {
    [1] = 6,  -- Blue Square (6)
    [2] = 7,  -- Red Cross (7)
    [3] = 4,  -- Green Triangle (4)
}

-- Symbol names for the chat announcement
local MARK_NAMES = {
    [6] = "Blue Square",
    [7] = "Red Cross",
    [4] = "Green Triangle"
}

-- Check if the player is a tank
local function IsTank(unit)
    if UnitGroupRolesAssigned(unit) == "TANK" then
        return true
    end
    return false
end

-- Function to announce in chat when a tank is marked
local function AnnounceMark(unit, mark)
    local name = UnitName(unit)
    local markName = MARK_NAMES[mark]
    local message = "Tank " .. name .. " was marked with " .. markName .. " by FastTankMarker."

    -- Send the message in raid or party chat
    if IsInRaid() then
        SendChatMessage(message, "RAID")
    elseif IsInGroup() then
        SendChatMessage(message, "PARTY")
    else
        print(message)  -- Send message only to the player if not in a group
    end
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
                AnnounceMark(unit, MARKS[tankCount])  -- Announce in chat
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

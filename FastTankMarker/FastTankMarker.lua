local FastTankMarker = CreateFrame("Frame")

local MARKS = {
    [1] = 6,
    [2] = 7,
    [3] = 4,
}

local function IsTank(unit)
    return UnitGroupRolesAssigned(unit) == "TANK"
end

local function CanMark()
    if not IsInGroup() then return false end
    if IsInRaid() then return false end
    if not UnitIsGroupLeader("player") then return false end
    if InCombatLockdown() then return false end

    local instanceType = select(2, IsInInstance())
    if instanceType == "scenario" then
        return false -- Delves / Szenarien ignorieren
    end

    return true
end

local function MarkTanks()
    if not CanMark() then return end

    local tankCount = 1

    for i = 1, 4 do
        local unit = "party"..i

        -- Follower/Companion dungeons ("Anhänger") can populate party slots with NPC followers.
        -- Trying to mark those units can trigger a "blocked" (protected) action warning.
        -- Only mark real player units.
        if UnitExists(unit) and UnitIsPlayer(unit) and IsTank(unit) and not GetRaidTargetIndex(unit) then
            if tankCount <= 3 then
                -- Be extra defensive: if the API is protected in the current context,
                -- don't throw a blocked-action popup.
                pcall(SetRaidTarget, unit, MARKS[tankCount])
                tankCount = tankCount + 1
            end
        end
    end
end

FastTankMarker:RegisterEvent("GROUP_ROSTER_UPDATE")
FastTankMarker:RegisterEvent("PLAYER_REGEN_ENABLED")
FastTankMarker:RegisterEvent("PLAYER_ENTERING_WORLD")

FastTankMarker:SetScript("OnEvent", function(self, event)
    C_Timer.After(1.5, MarkTanks)
end)
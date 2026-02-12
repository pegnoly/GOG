---@alias UpgradeableArtifactType
---|`UPG_ARTIFACT_SOULBINDER`
UPG_ARTIFACT_SOULBINDER = 1

upgadeable_arts_common = {
    ---@type table<UpgradeableArtifactType, table<number, number>>
    presets = {}
}

---@param hero string
---@param preset UpgradeableArtifactType
---@return 1|nil has
function HasUpgradeableArtifact(hero, preset)
    for art, _ in upgadeable_arts_common.presets[preset] do
        if HasArtefact(hero, art, 1) then
            return 1
        end
    end
    return nil
end

---@param hero string
---@param preset UpgradeableArtifactType
---@return number level
function GetUpgradeableArtifactLevel(hero, preset)
    for art, level in upgadeable_arts_common.presets[preset] do
        if HasArtefact(hero, art, 1) then
            return level
        end
    end
    return 0
end
local PROFILE_TEMPLATE = {
    Coins = 0,
    Level = 1,
    Experience = 0,
    BackPack = {
        --[[
            {
                ["Strength"] = 7,
                ["techName"] = "Rusty_Nail",
                ["value"] = 2
            }
        ]] 
    },
    EquippedMagnet = "Magnet1",
    OwnedMagnets = {
        -- "Magnet1"
        "Magnet1",
    },

}

local SESSION_DATA_TEMPLATE = {
    -- You can add any session-specific data here, for example: IsHolding
    IsHolding = false,
}

export type profileTemplateType = typeof(PROFILE_TEMPLATE)
export type sessionDataTemplateType = typeof(SESSION_DATA_TEMPLATE)

local DataTemplates = {}

DataTemplates.PROFILE_TEMPLATE = PROFILE_TEMPLATE
DataTemplates.SESSION_DATA_TEMPLATE = SESSION_DATA_TEMPLATE

return DataTemplates

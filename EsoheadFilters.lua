local oldGetString = GetString
local oldVars = WORLD_MAP_FILTERS.SetSavedVars
local oldPVEPinSet
local oldPVPPinSet
local EsoheadMarkersFilters = { ["mining"] = "Ore", ["clothing"] = "Clothing Material", ["rune"] = "Runestone", ["alchemy"] = "Alchemy Ingredient", ["wood"] = "Wood", ["chest"] = "Chest", ["found_skyshard"] = "Collected Skyshards" }

-- the filter checkboxes display the localization string, retrieved by this function
-- since there is no API to the filters, I had to hack a bit, to display my own strings :)
function GetString( stringVariablePrefix, contextId )
    if stringVariablePrefix == "SI_MAPFILTER" and EsoheadMarkersFilters[contextId] then
        return EsoheadMarkersFilters[contextId]
    else
        return oldGetString( stringVariablePrefix, contextId )
    end
end

-- setsavedVars initializes the filter controlls for pve and pvp map type
-- after this function is called WORLD_MAP_FILTERS.pvePanel are initialized and can be manipulated
WORLD_MAP_FILTERS.SetSavedVars = function( self, savedVars )
    oldVars( self, savedVars)
    
    oldPVEPinSet = self.pvePanel.SetPinFilter
    oldPVPPinSet = self.pvpPanel.SetPinFilter
    
    for pinType, _ in pairs(EsoheadMarkersFilters) do
        local pin = pinType
        self.pvePanel.AddPinFilterCheckBox( self.pvePanel, pin, function() MapPins:RefreshPins( pin ) end)
	self.pvpPanel.AddPinFilterCheckBox( self.pvpPanel, pin, function() MapPins:RefreshPins( pin ) end)
    end
    
    self.pvePanel.SetPinFilter = function( self, mapPinGroup, checked )
        oldPVEPinSet( self, mapPinGroup, checked )
        MapPins:enablePins( mapPinGroup, checked )
    end
    
    self.pvpPanel.SetPinFilter = function( self, mapPinGroup, checked )
        oldPVPPinSet( self, mapPinGroup, checked )
        MapPins:enablePins( mapPinGroup, checked )
    end
    
end
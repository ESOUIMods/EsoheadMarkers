local oldGetString = GetString
local oldVars = WORLD_MAP_FILTERS.SetSavedVars
local oldPVEPinSet
local oldPVPPinSet
local EsoheadMarkersFilters = { 
    ["mining"] = "Ore",
    ["clothing"] = "Clothing Material", 
    ["rune"] = "Runestone", 
    ["alchemy"] = "Alchemy Ingredient", 
    ["wood"] = "Wood", 
    ["chest"] = "Chest", 
    ["skyshard"] = "Undiscovered Skyshard",
    ["found_skyshard"] = "Discovered Skyshards" 
    ["fish"] = "Fish",
    ["r"] = "Red",
    ["g"] = "Grün",
    ["b"] = "Blau",
    ["w"] = "Weiß"
}
local order = {"skyshard","found_skyshard","chest","mining","clothing","rune","alchemy","wood","fish"}

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
    a = true
    for _, pinType in ipairs(order) do
	local pin = pinType
	if #pin > 2 then
		self.pvePanel.AddPinFilterCheckBox( self.pvePanel, pin, function() EHM.MapPins:RefreshPins( pin ) end)
		
		if pin ~= "skyshard" and pin ~= "found_skyshard" then
			self.pvePanel.AddPinFilterComboBox( self.pvePanel, pin.."color", function() EHM.MapPins:RefreshPins( pin ) end, "SI_MAPFILTER", "r", "g", "b", "w" )
		end
		
		self.pvpPanel.AddPinFilterCheckBox( self.pvpPanel, pin, function() EHM.MapPins:RefreshPins( pin ) end)
	end
    end
    
--[[
    self.pvePanel.SetPinFilter = function( self, mapPinGroup, checked )
		oldPVEPinSet( self, mapPinGroup, checked )
	MapPins:enablePins( mapPinGroup, checked )
    end
    
    self.pvpPanel.SetPinFilter = function( self, mapPinGroup, checked )
	oldPVPPinSet( self, mapPinGroup, checked )
	MapPins:enablePins( mapPinGroup, checked )
    end
]]--

end

function EHMInitializeFilters()
	--pvepanel has no mode if the character starts his session on a pvp map
	WORLD_MAP_FILTERS.pvePanel:SetMapMode(2) -- prevents crashing on GetPinFilter in above case
	for pinType, _ in pairs(EsoheadMarkersFilters) do
		local pin = pinType
		if #pin > 2 then
			if not WORLD_MAP_FILTERS.pvePanel:GetPinFilter(pin.."color") then
				WORLD_MAP_FILTERS.pvePanel:SetPinFilter(pin.."color", "w")
			end
		end
	end
end

local oldData = ZO_MapPin.SetData
ZO_MapPin.SetData = function( self, pinTypeId, pinTag)
	local back = GetControl(self.m_Control, "Background")
	local value
	for pinType, _ in pairs(EsoheadMarkersFilters) do
		if pinTypeId == _G[pinType] then
			value = ZO_WorldMap_GetFilterValue(pinType.."color")
			if value == "r" then
				back:SetColor(1,0.1,0.1,1)
			elseif value == "g" then
				back:SetColor(0.1,1,0.1,1)
			elseif value == "b" then
				back:SetColor(0.2,0.2,1,1)
			else
				back:SetColor(1,1,1,1)
			end
			break
		end
	end
	
	if not value then
		back:SetColor(1,1,1,1)
	end
		
	oldData(self, pinTypeId, pinTag)
end
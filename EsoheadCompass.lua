local function EHMHarvestCallback( materialId, g_mapPinManager )
	if not (ZO_WorldMap_IsPinGroupShown(EHM.material[materialId].pinType) and EHM.compass.activated == 1) then
		return
	end
	local zone = GetMapName()
	local harvestNodes = EH.savedVars["harvest"].data[zone]
	if not harvestNodes then
		return
	end
	harvestNodes = harvestNodes[materialId]
	if harvestNodes then
		for _, node in pairs(harvestNodes) do
			g_mapPinManager:CreatePin( EHM.material[materialId].pinType, node[1], node[2] )
		end
	end
end

local function EHMSkyshard( pinManager )
	if not (ZO_WorldMap_IsPinGroupShown("skyshard") and EHM.compass.activated == 1) then
		return
	end
	local zone = GetMapName()
	local skyshards = EHMShards[ zone ]
	if not skyshards then
		zone = EHMMaps[GetCurrentMapIndex()]
		skyshards = EHMShards[ zone ]
		if not skyshards then
			return
		end
	end
	
	for _,shard in pairs(skyshards) do
		_, numCompleted = GetAchievementCriterion( shard[3], shard[4] )
		if numCompleted < 1 then
			pinManager:CreatePin( "skyshard", shard[1], shard[2] )
		end
	end
end

local function EHMChestCallback( g_mapPinManager )
	if not (ZO_WorldMap_IsPinGroupShown("chest") and EHM.compass.activated == 1) then
		return
	end
	local zone = GetMapName()
	local chests = EH.savedVars["chest"].data[zone]
	if not chests then
		return
	end
	for _,chest in pairs(chests) do
		g_mapPinManager:CreatePin( "chest", chest[1], chest[2] )
	end
	
end

local function EHMCompass(str)
	input = tonumber(str)
	if input == 1 then
		d("Compass activated!")
	elseif input == 0 then
		d("Compass deactivated!")
	else
		d("/compass [state]")
		d("state should be 1 for on and 0 for off")
	end
	EHM.compass.activated = input
	COMPASS_PINS:RefreshPins()
end

function EHMInitializeCompass()
	
	for id, material in pairs( EHM.material ) do
		if id ~= 5 then --not sure how to handle provision
			local i = id
			COMPASS_PINS:AddCustomPin( material.pinType,
				function(g_mapPinManager)
				EHMHarvestCallback( i, g_mapPinManager )
				end,
				EHM.layouts[material.pinType]
			)
		end
	end
	
	COMPASS_PINS:AddCustomPin("skyshard", EHMSkyshard, EHM.layouts["skyshard"])
	COMPASS_PINS:AddCustomPin("chest", EHMChestCallback, EHM.layouts["chest"])
	COMPASS_PINS:RefreshPins()
	SLASH_COMMANDS["/compass"] = EHMCompass
end
local EHM = {
	["skyshard"]    = "EsoUI/Art/Inventory/inventory_tabicon_quest_up.dds",
	["chest"] = "EsoUI/Art/Inventory/inventory_tabicon_misc_up.dds"
	}
EHM.material = {
	{pinType = "mining", texture = "EsoUI/Art/MapPins/AvA_mine_Neutral.dds", tooltip = "Ore", size = 20 },
	{pinType = "clothing", texture = "EsoUI/Art/Characterwindow/gearslot_tabard.dds", tooltip = "Clothing Material", size = 20 },
	{pinType = "rune", texture = "EsoUI/Art/Crafting/enchantment_tabicon_essence_down.dds", tooltip = "Runestone", size = 20 },
	{pinType = "alchemy", texture = "EsoUI/Art/Crafting/alchemy_tabicon_reagent_down.dds", tooltip = "Alchemy Ingredient", size = 20 },
	{pinType = "provisioning", texture = "EsoheadMarkers/Textures/clothing.dds", tooltip = "Provision Material", size = 20 },
	{pinType = "wood", texture = "EsoUI/Art/MapPins/AvA_lumbermill_Neutral.dds", tooltip = "Wood", size = 20 }
}

EHM.layouts = {}

local function EHMChestCallback( g_mapPinManager )
	local zone = GetMapName()
	local chests = EH.savedVars["chest"].data[zone]
	if not chests then
		return
	end
	for _,chest in pairs(chests) do
		g_mapPinManager:CreatePin( _G["chest"], { chest[1], chest[2] }, chest[1], chest[2] )
	end
	
end

local function EHMNotFound( zone, x, y)
	local foundShards = EHM.foundShards.zones[ zone ]
	local minFound, minShard
	local minDist = math.huge
	
	if not foundShards then
		return true
	end
	
	--get closest already collected shard
	for _, shard in pairs( foundShards ) do
		if zo_abs(shard[1] - x) + zo_abs(shard[2] - y) < minDist then
			minFound = shard
			minDist = zo_abs(shard[1] - x) + zo_abs(shard[2] - y)
		end
	end
	
	if not minFound then
		return true
	end
	
	--get closest shard
	minDist = math.huge
	
	for _, shard in pairs( EHMShards[ zone ] ) do
		if zo_abs(shard[1] - minFound[1]) + zo_abs(shard[2] - minFound[2]) < minDist then
			minShard = shard
			minDist = zo_abs(shard[1] - minFound[1]) + zo_abs(shard[2] - minFound[2])
		end
	end
	
	if not minShard then
		return true
	end
	-- if current shard and closest shard are the same, it is already collected
	return not (minShard[1] == x and minShard[2] == y)
end

local function EHMFoundSkyshardCallback( g_mapPinManager )
	local zone = GetMapName()
	local skyshards = EHMShards[ zone ]
	if not skyshards then
		return
	end
	
	for _,shard in pairs(skyshards) do
		if not EHMNotFound(zone, shard[1], shard[2]) then
			g_mapPinManager:CreatePin( _G["found_skyshard"], { shard[1], shard[2] }, shard[1], shard[2] )
		end
	end
end

local function EHMSkyshardCallback( g_mapPinManager )
	local zone = GetMapName()
	local skyshards = EHMShards[ zone ]
	if not skyshards then
		return
	end
	
	for _,shard in pairs(skyshards) do
		if EHMNotFound(zone, shard[1], shard[2]) then
			g_mapPinManager:CreatePin( _G["skyshard"], { shard[1], shard[2] }, shard[1], shard[2] )
		end
	end
end

local function Old_EHMSkyshardCallback( g_mapPinManager )
	local zone = GetMapName()
	local skyshards = EH.savedVars["skyshard"].data[zone]
	if not skyshards then
		return
	end
	for _,shard in pairs(skyshards) do
		g_mapPinManager:CreatePin( _G["skyshard"], { shard[1], shard[2] }, shard[1], shard[2] )
	end
	
end

local function EHMHarvestCallback( materialId, g_mapPinManager )
	local zone = GetMapName()
	local harvestNodes = EH.savedVars["harvest"].data[zone]
	if not harvestNodes then
		return
	end
	harvestNodes = harvestNodes[materialId]
	if harvestNodes then
		for _, node in pairs(harvestNodes) do
			g_mapPinManager:CreatePin( _G[EHM.material[materialId].pinType], { node[1], node[2] }, node[1], node[2] )
		end
	end
end

local function EHMFindShard(mapName, x, y)
	if not EHM.foundShards.zones[ mapName ] then
		EHM.foundShards.zones[ mapName ] = {}
	end
	local list = EHM.foundShards.zones[ mapName ]
	--if  not (list[ #list ][1] == x and list[ #list ][2] == y) then
		list[ #list + 1 ] = { x, y }
	--end
end

EHM.Log = EH.Log
EHM.LogCheck = EH.LogCheck

function EH.Log( type, nodes, ... )
	EHM.Log( type, nodes, ... )
	if type == "harvest" then
		MapPins:RefreshPins( EHM.material[nodes[2]].pinType )
	elseif type == "skyshard" then
		MapPins:RefreshPins( "skyshard" )
		MapPins:RefreshPins( "found_skyshard" )
	end
end

function EH.LogCheck( type, nodes, x, y, ... )
	local result = EHM.LogCheck( type, nodes, x, y )
	if type == "skyshard" then
		SetMapToPlayerLocation()
		local mapName = GetMapName()
		local mapType = GetMapType()
		local playerX, playerY = GetMapPlayerPosition( "player" )
		EHMFindShard(mapName, playerX, playerY)
		while mapType == MAPTYPE_SUBZONE do --if inside a dungeon
			if MapZoomOut() ~= SET_MAP_RESULT_MAP_CHANGED then --go back
				break
			end
			mapType = GetMapType()
		end
		if mapType == MAPTYPE_ZONE then
			mapName = GetMapName()
			playerX, playerY = GetMapPlayerPosition( "player" )
			EHMFindShard(mapName, playerX, playerY)
		end
	end
	return result
end
--[[
local function EHMPinSize(category, size)
	size = tonumber(size)
	if category == nil or size == nil or size < 16 or size > 64 or not (category == "skyshard" or category == "chest" or category == "harvest")  then
		d("/pinsize [category] [size]")
		d("[category]: skyshard, chest, harvest")
		d("[size]: between 16 and 64")
		d("example: /pinsize harvest 32")
		return
	end
	if  category == "harvest" then
		for _, pinType in pairs( EHM.material ) do
			EHM.layouts[ pinType.pinType ].size = size
		end
	else
		EHM.layouts[category].size = size
	end
	MapPins:RefreshPins()
end
--]]
local function EHMOnLoad(eventCode, addOnName )
	if addOnName ~= "EsoheadMarkers" then
		return
	end
	
	--SLASH_COMMANDS["/pinsize"] = EHMPinSize
	
	EHM.foundShards = ZO_SavedVars:New("EsoheadMarkers_SavedVariables", 1, "skyshard", { zones = {} })
	EHMInitSkyshards()
	MapPins = CustomMapPins:New()
	--
	EHM.layouts["skyshard"] = { level = 20, texture = EHM["skyshard"], size = 40 }
	MapPins:CreatePinType( "skyshard",
		EHM.layouts["skyshard"],
		"skyshard",
		EHMSkyshardCallback
	)
	
	EHM.layouts["found_skyshard"] = { level = 20, texture = EHM["skyshard"], size = 32 }
	MapPins:CreatePinType( "found_skyshard",
		EHM.layouts["found_skyshard"],
		"collected skyshard",
		EHMFoundSkyshardCallback
	)
	
	EHM.layouts["chest"] = { level = 20, texture = EHM["chest"], size = 32 }
	MapPins:CreatePinType( "chest",
		EHM.layouts["chest"],
		"Chest",
		EHMChestCallback
	)
	
	for id, material in pairs( EHM.material ) do
		if id ~= 5 then --not sure how to handle provision
			local i = id
			local t = material.texture
			local s = material.size
			EHM.layouts[material.pinType] = { level = 20, texture = t, size = s }
			MapPins:CreatePinType( material.pinType,
				EHM.layouts[material.pinType],
				material.tooltip,
				function(g_mapPinManager)
				EHMHarvestCallback( i, g_mapPinManager )
				end
			)
		end
	end
	
	MapPins:RefreshPins()
end

EVENT_MANAGER:RegisterForEvent("EsoheadMarkers", EVENT_ADD_ON_LOADED, EHMOnLoad)
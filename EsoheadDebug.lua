local function EHMDebug(str)
	input = tonumber(str)
	if input == 1 then
		d("Debug mode is enabled!")
		d("Click to mark a Shyshard you have found!")
	elseif input == 0 then
		d("Debug mode is disabled!")
	else
		d("/debugskyshard [state]")
		d("state should be 1 for on and 0 for off.")
	end
	EHM.debug = (input == 1)
end

local function EHMUncollect( zone, x, y)
	local foundShards = EHM.foundShards.zones[ zone ]
	local minFound
	local minDist = math.huge
	
	if not foundShards then
		return true
	end
	
	--get closest already collected shard
	for id, shard in pairs( foundShards ) do
		if zo_abs(shard[1] - x) + zo_abs(shard[2] - y) < minDist then
			minFound = id
			minDist = zo_abs(shard[1] - x) + zo_abs(shard[2] - y)
		end
	end
	
	if not minFound then
		return
	end
	foundShards[minFound] = nil
end

function EHMInitializeDebug()
	ZO_MapPin.PIN_CLICK_HANDLERS[1][_G["skyshard"]] = {
		{			
			callback = function(pin)
				if not EHM.debug then
					return
				end
				d("Mark SkyShard:")
				d(GetMapName() .. " x:" .. tostring(pin.normalizedX) .. " y:" .. tostring(pin.normalizedY))
				d("as discovered")
				EHMFindShard(GetMapName(), pin.normalizedX, pin.normalizedY)
				EHM.MapPins:RefreshPins()
			end
		}
	}
	
	ZO_MapPin.PIN_CLICK_HANDLERS[1][_G["found_skyshard"]] = {
		{			
			callback = function(pin)
				if not EHM.debug then
					return
				end
				local zone = GetMapName()
				d("Mark SkyShard:")
				d(zone .. " x:" .. tostring(pin.normalizedX) .. " y:" .. tostring(pin.normalizedY))
				d("as undiscovered")
				
				while (not EHMNotFound( zone, pin.normalizedX, pin.normalizedY) ) do
					EHMUncollect(zone, pin.normalizedX, pin.normalizedY)
				end
				EHM.MapPins:RefreshPins()
			end
		}
	}
	EHM.debug = false
	SLASH_COMMANDS["/debugskyshard"] = EHMDebug
end
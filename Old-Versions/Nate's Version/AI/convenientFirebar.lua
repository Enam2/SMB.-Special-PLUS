--convenientFirebar.lua -- By IAmPlayer - Moved from npc-760.lua

local npcManager = require("npcManager")
local orbits = require("orbits")

local firebar = {}

--***************************************************************************************************
--                                                                                                  *
--              DEFAULTS AND NPC CONFIGURATION                                                      *
--                                                                                                  *
--***************************************************************************************************

function firebar.register(id)
    npcManager.registerEvent(id, firebar, "onTickNPC")
	
	--define
	if NPC.config[id].length == nil then
		NPC.config[id].length = 6
	end
	
	if NPC.config[id].angle == nil then
		NPC.config[id].angle = 0
	end
	
	if NPC.config[id].number == nil then
		NPC.config[id].number = 1
	end
	
	if NPC.config[id].speed == nil then
		NPC.config[id].speed = 5
	end
end

--*********************************************
--                                            *
--                     AI                     *
--                                            *
--*********************************************

-- CONVENIENT FIREBARS BOI
function firebar.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	data.lifetime = data.lifetime or 0
	data.orbit = data.orbit or {}
	data.isMade = data.isMade or false
	
	if data.notLimited == nil then
		data.notLimited = true
	end
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
	end

	if not data.initialized then
		data.initialized = true
		
		data._settings.length = data._settings.length or NPC.config[v.id].length
		data._settings.angle = data._settings.angle or NPC.config[v.id].angle
		data._settings.number = data._settings.number or NPC.config[v.id].number
		data._settings.speed = data._settings.speed or NPC.config[v.id].speed
	end
	
	if data.lifetime == 1 then
		if not data.isMade then
			data.center = NPC.spawn(260, v.x + (v.width * 0.5), v.y + (v.height * 0.5), player.section, data.notLimited, true)
			if NPC.config[v.id].playerblock and NPC.config[v.id].npcblock then
				data.center.friendly = true
			end
			
			data.center.x = v.x + (v.width / 4)
			data.center.y = v.y + (v.height / 4)
			
			for i = 1, data._settings.length do
				data.orbit[i] = orbits.new{
					attachToNPC = v,
					id = 260,
					section = v.section,
					rotationSpeed = (0.1 * data._settings.speed) * v.direction,
					number = 1,
					angleDegs = 270 + data._settings.angle,
					number = data._settings.number,
					radius = 16 * i,
					friendly = v.friendly,
				}
			end
			
			data.isMade = true
		
			if lunatime.tick() > 2 then
				SFX.play(16)
			end
		end
	elseif data.lifetime > 1 then
		v.friendly = false
		
		--this too
		if data.center ~= nil then
			data.center.x = v.x + (v.width / 4)
			data.center.y = v.y + (v.height / 4)
		end
	end
	
	--make this thing movable, shall we?
	if player.forcedState ~= 2 then
		v.x = v.x + v.layerObj.speedX
		v.y = v.y + v.layerObj.speedY
	end
	
	--firebar's capability to melt ice blocks other than Beta 4 Ice Blocks
	for _,orbit in ipairs(data.orbit) do
		for _,f in ipairs(orbit.orbitingNPCs) do
			local blocks = Colliders.getColliding{a = f,b = {620,621,633},btype = Colliders.BLOCK}
			
			for _,block in ipairs(blocks) do
				block:remove()
				Effect.spawn(10, block.x, block.y)
				SFX.play(3)
				
				if block.id == 620 then
					NPC.spawn(10, block.x, block.y, f.section)
				elseif block.id == 621 then
					Block.spawn(109, block.x, block.y)
				elseif block.id == 633 then
					if block.contentID > 1000 then --not coin contained but not empty
						NPC.spawn(block.contentID - 1000, block.x, block.y, f.section)
					end
				end
			end
		end
	end
	
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		data.lifetime = 0
		data.notLimited = false
	else
		data.lifetime = data.lifetime + 1
	end
end

return firebar;
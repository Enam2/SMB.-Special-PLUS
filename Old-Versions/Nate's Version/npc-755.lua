--------------------------------------------------------------------
--     Hammer from Super Mario Bros. Special by Hudson Soft       --
--                    Recreated by IAmPlayer                      --
--------------------------------------------------------------------

local npcManager = require("npcManager")
local timer = require("timer")

local hammer = {}
local npcID = NPC_ID

local hammerSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 1,
	framestyle = 0,
	framespeed = 8,
	score = 6,
	speed = 1,
	
	npcblock = false,
	npcblocktop = false, 
	playerblock = false,
	playerblocktop = false,

	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	isinteractable = true,
	
	duration = 10,
	usesfx = true
}

local configFile = npcManager.setNpcSettings(hammerSettings)

npcManager.registerDefines(npcID, {NPC.COLLECTIBLE})

--Settings
local hammerImg = Graphics.loadImageResolved("npc-"..npcID..".png")
local imgPriority = -45
local player_sy = 0

local hammer_isActive = false
local hammerTimer = 0
local hammerTimer_set = 0
local hammer_debugMode = false

local hammerSoundObject
local hammerSFX = Misc.resolveFile("hammerFanfare.mp3")
local audioeffect = Audio.SfxOpen(hammerSFX)

local upHammer_collision
local sideHammer_collision

local BLOCK_BRICKS = {4, 60, 90, 188, 226, 293}

--Register events
function hammer.onInitAPI()
	npcManager.registerEvent(npcID, hammer, "onTickNPC")
	registerEvent(hammer, "onDraw")
	registerEvent(hammer, "onStart")
	registerEvent(hammer, "onTick")
end

local function doHammerAbility(v)
	local pos = vector(v.x, v.y)
	
	hammerTimer = lunatime.toTicks(configFile.duration)
	Misc.givePoints(configFile.score, pos, true)
		
	if configFile.score < 10 then
		SFX.play(6)
	elseif configFile.score >= 10 then
		SFX.play(15)
	end
end

function hammer.onStart()
	upHammer_collision = Colliders.Box(player.x, player.y - configFile.height, 32, 32)
	sideHammer_collision = Colliders.Box(player.x, player.y, 32, 32)
end

function hammer.onTick()
	if hammer_debugMode then
		Text.print("isActive: "..tostring(hammer_isActive), 100, 100)
		Text.print("hammerTimer: "..tostring(hammerTimer), 100, 116)
		
		if hammerTimer_set == 0 and hammerTimer > 0 then
			upHammer_collision:Debug(true)
			sideHammer_collision:Debug(false)
		elseif hammerTimer_set > 0 and hammerTimer > 0 then
			sideHammer_collision:Debug(true)
			upHammer_collision:Debug(false)
		end
	end
	
	if upHammer_collision ~= nil then
		upHammer_collision.x = player.x
		upHammer_collision.y = player.y - configFile.height
	end
	
	if player.direction == DIR_LEFT then
		sideHammer_collision.x = player.x - configFile.width
		player_sy = 1
	else
		sideHammer_collision.x = player.x + configFile.width
		player_sy = 2
	end
	
	if player.height > 32 then
		sideHammer_collision.y = player.y + (player.height * 0.25)
	else
		sideHammer_collision.y = player.y
	end
	
	if hammer_isActive then
		hammerTimer = hammerTimer - 1
		
		if hammerTimer_set == 0 then
			for _, e in ipairs(NPC.get(NPC.HITTABLE)) do
				if Colliders.collide(e, upHammer_collision) then
					e:harm(HARM_TYPE_EXT_HAMMER)
				end
			end
			
			for _, b in ipairs(Block.get(BLOCK_BRICKS)) do
				if Colliders.collide(b, upHammer_collision) then
					b:remove(true)
				end
			end
			
			for _, b2 in ipairs(Block.get()) do
				if Colliders.collide(b2, upHammer_collision) then
					b2:hit()
				end
			end
		else
			for _, e in ipairs(NPC.get(NPC.HITTABLE)) do
				if Colliders.collide(e, sideHammer_collision) then
					e:harm(HARM_TYPE_EXT_HAMMER)
				end
			end
			
			for _, b in ipairs(Block.get(BLOCK_BRICKS)) do
				if Colliders.collide(b, sideHammer_collision) then
					b:remove(true)
				end
			end
			
			for _, b2 in ipairs(Block.get()) do
				if Colliders.collide(b2, sideHammer_collision) then
					b2:hit()
				end
			end
		end
	end
	
	if hammerTimer % configFile.framespeed == 0 then
		hammerTimer_set = hammerTimer_set + 1
	end
	
	if hammerTimer_set > 1 then
		hammerTimer_set = 0
	end
	
	if hammerTimer > 0 then
		hammer_isActive = true
		
		if configFile.usesfx then
			if hammerSoundObject == nil then
				hammerSoundObject = Audio.SfxPlayObj(audioeffect, -1)
			end
		end
	else
		hammer_isActive = false
		
		if configFile.usesfx then
			if hammerSoundObject ~= nil then
				hammerSoundObject:Stop()
				hammerSoundObject = nil
			end
		end
	end
	
	if configFile.foreground then
		imgPriority = -15
	end
end

function hammer.onDraw()
	if hammerTimer > 0 and hammerTimer_set == 0 then
		Graphics.draw{
			x = upHammer_collision.x,
			y = upHammer_collision.y,
			type = RTYPE_IMAGE,
			isSceneCoordinates = true,
			image = hammerImg,
			sourceWidth = configFile.width,
			sourceHeight = configFile.height,
			priority = imgPriority
		}
	elseif hammerTimer > 0 and hammerTimer_set > 0 then
		Graphics.draw{
			x = sideHammer_collision.x,
			y = sideHammer_collision.y,
			type = RTYPE_IMAGE,
			isSceneCoordinates = true,
			image = hammerImg,
			sourceY = player_sy * configFile.height,
			sourceWidth = configFile.width,
			sourceHeight = configFile.height,
			priority = imgPriority
		}
	end
end

function hammer.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	v:mem(0x12A, FIELD_WORD, 180)
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end
	
	if Colliders.collide(player, v) then
		doHammerAbility(v)
	end
end

--Gotta return the library table!
return hammer
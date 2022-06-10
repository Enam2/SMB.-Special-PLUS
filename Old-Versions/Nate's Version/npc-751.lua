------------------------------------------------------------
-- Wing NPC from Super Mario Bros. Special by Hudson Soft --
--                 Recreated by IAmPlayer                 --
------------------------------------------------------------

local npcManager = require("npcManager")

local wing = {}
local npcID = NPC_ID

local wingSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 2,
	framestyle = 0,
	framespeed = 8,
	score = 6,
	speed = 1,
	
	npcblock = false,
	npcblocktop = false, 
	playerblock = false,
	playerblocktop = false,

	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	iswalker = true,
	isinteractable = true,
	
	duration = 10
}

local configFile = npcManager.setNpcSettings(wingSettings)

npcManager.registerDefines(npcID, {NPC.COLLECTIBLE})

local isFlying = false
local flyTimer = 0
local fly_debugMode = false

--Register events
function wing.onInitAPI()
	npcManager.registerEvent(npcID, wing, "onTickNPC")
	registerEvent(wing, "onTick")
end

local function doWingAbility(v)
	local pos = vector(v.x, v.y)
	
	flyTimer = lunatime.toTicks(configFile.duration)
	Misc.givePoints(configFile.score, pos, true)
		
	if configFile.score < 10 then
		SFX.play(6)
	elseif configFile.score >= 10 then
		SFX.play(15)
	end
end

function wing.onTick()
	if fly_debugMode then
		Text.print("isFlying: "..tostring(isFlying), 100, 100)
		Text.print("flyTimer: "..tostring(flyTimer), 100, 116)
	end
	
	if isFlying then
		player:mem(0x34, FIELD_WORD, 2)
		flyTimer = flyTimer - 1
	end
	
	if flyTimer > 0 then
		isFlying = true
	else
		isFlying = false
	end
end

function wing.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	data.timer = data.timer or 0
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end
	
	if v.direction == DIR_LEFT then
		v.y = v.y - math.sin(data.timer * 0.0625) * 3
	else
		v.y = v.y - math.sin(data.timer * 0.0625) * 3
	end
	
	if v:mem(0x12C, FIELD_WORD) == 0    --Not Grabbed
	and not v:mem(0x136, FIELD_BOOL)     --Not Thrown
	and v:mem(0x138, FIELD_WORD) == 0    -- Not Contained within
	then
		data.timer = data.timer + 1
	end
	
	if Colliders.collide(player, v) then
		doWingAbility(v)
	end
end

--Gotta return the library table!
return wing
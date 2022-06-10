--------------------------------------------------------------------
-- Hachisuke/Hu-Bee from Super Mario Bros. Special by Hudson Soft --
--                    Recreated by IAmPlayer                      --
--------------------------------------------------------------------

local npcManager = require("npcManager")

local huBee = {}
local npcID = NPC_ID

local huBeeSettings = {
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
	score = 9,
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
	newability = true
}

local configFile = npcManager.setNpcSettings(huBeeSettings)

npcManager.registerDefines(npcID, {NPC.COLLECTIBLE})

local huBee_perkTimer = 0
local huBee_isInactive = true
local huBee_isActivated = false
local huBee_justEnded = false
local perk_debug = false

--Register events
function huBee.onInitAPI()
	npcManager.registerEvent(npcID, huBee, "onTickNPC")
	registerEvent(huBee, "onTick")
end

local function doBeePerk(v)
	if configFile.newability then
		huBee_perkTimer = lunatime.toTicks(configFile.duration)
		huBee_isInactive = false
	end
	
	local pos = vector(v.x, v.y)
	
	Misc.givePoints(configFile.score, pos, true)
		
	if configFile.score < 10 then
		SFX.play(6)
	elseif configFile.score >= 10 then
		SFX.play(15)
	end
end

function huBee.onTick()
	if perk_debug then
		Text.print("isActivated: "..tostring(huBee_isActivated), 100, 100)
		Text.print("perkTimer: "..tostring(huBee_perkTimer), 100, 116)
		Text.print("isInactive: "..tostring(huBee_isInactive), 100, 132)
		Text.print(Defines.jumpheight, 100, 148)
		Text.print(Defines.jumpheight_bounce, 100, 164)
	end
	
	if huBee_isActivated then
		huBee_perkTimer = huBee_perkTimer - 1
	end
	
	if huBee_isActivated and huBee_perkTimer == lunatime.toTicks(configFile.duration) - 1 then --prevent from getting the jumpheight to insane numbers that leads to an error
		Defines.jumpheight = Defines.jumpheight * 1.5
		Defines.jumpheight_bounce = Defines.jumpheight_bounce * 1.5
	end
	
	if huBee_perkTimer == -1 then
		huBee_justEnded = true
	end
	
	if huBee_justEnded then --failsafe to avoid jump height be reduced to a very small number
		huBee_justEnded = false
		Defines.jumpheight = Defines.jumpheight / 1.5
		Defines.jumpheight_bounce = Defines.jumpheight_bounce / 1.5
		huBee_perkTimer = 0
		huBee_isInactive = true
	end
	
	if huBee_perkTimer > 0 and not huBee_isInactive then
		huBee_isActivated = true
	elseif huBee_perkTimer == 0 and not huBee_isInactive then
		huBee_perkTimer = -1
		huBee_isActivated = false
	end
end

function huBee.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end
	
	if Colliders.collide(player, v) then
		doBeePerk(v)
	end
end

--Gotta return the library table!
return huBee
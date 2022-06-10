--------------------------------------------------------------------
--      Clock from Super Mario Bros. Special by Hudson Soft       --
--                    Recreated by IAmPlayer                      --
--------------------------------------------------------------------

local npcManager = require("npcManager")
local timer = require("timer")

local clockItem = {}
local npcID = NPC_ID

local clockItemSettings = {
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
	
	timeboost = 100
}

local configFile = npcManager.setNpcSettings(clockItemSettings)

npcManager.registerDefines(npcID, {NPC.COLLECTIBLE})

--Register events
function clockItem.onInitAPI()
	npcManager.registerEvent(npcID, clockItem, "onTickNPC")
end

local function addTime(v)
	local pos = vector(v.x, v.y)
	
	Misc.givePoints(configFile.score, pos, true)
		
	if configFile.score < 10 then
		SFX.play(6)
	elseif configFile.score >= 10 then
		SFX.play(15)
	end
	
	if timer.isActive() then
		timer.add(configFile.timeboost)
	end
end

function clockItem.onTickNPC(v)
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
		addTime(v)
	end
end

--Gotta return the library table!
return clockItem
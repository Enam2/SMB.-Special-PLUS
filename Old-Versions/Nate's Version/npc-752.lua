--------------------------------------------------------------
-- Lucky Star from Super Mario Bros. Special by Hudson Soft --
--                  Recreated by IAmPlayer                  --
--------------------------------------------------------------

local npcManager = require("npcManager")
local cam = Camera.get()[1]

local luckyStar = {}
local npcID = NPC_ID

local luckyStarSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 4,
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
	isinteractable = true
}

local configFile = npcManager.setNpcSettings(luckyStarSettings)

npcManager.registerDefines(npcID, {NPC.COLLECTIBLE})

--Register events
function luckyStar.onInitAPI()
	npcManager.registerEvent(npcID, luckyStar, "onTickNPC")
end

local function doLuckyStar(v)
	local pos = vector(v.x, v.y)
	for _, e in ipairs(NPC.get(NPC.HITTABLE)) do
		if e.x + e.width > cam.x and e.x - e.width < cam.x + 800 and e.y + e.height > cam.y and e.y - e.height < cam.x + 800 then --if onscreen
			e:kill()
		end
	end
	Misc.givePoints(configFile.score, pos, true)
		
	if configFile.score < 10 then
		SFX.play(6)
	elseif configFile.score >= 10 then
		SFX.play(15)
	end
end

function luckyStar.onTickNPC(v)
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
		doLuckyStar(v)
	end
end

--Gotta return the library table!
return luckyStar
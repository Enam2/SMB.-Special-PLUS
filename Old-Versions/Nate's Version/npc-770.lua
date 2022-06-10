local npcManager = require("npcManager")
local firebar = require("AI/convenientFirebar")

local newFirebar = {}
local npcID = NPC_ID

local newFirebarSettings = {
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
	speed = 1,
	
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = true,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	notcointransformable = true,
	
	--default values
	length = 6,
	angle = 0,
	number = 1,
	speed = 5,
}

local configFile = npcManager.setNpcSettings(newFirebarSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

firebar.register(npcID)

--Gotta return the library table!
return newFirebar
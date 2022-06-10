local npcManager = require("npcManager")
local starman = require("npcs/ai/starman")

local star = {}

local npcID = NPC_ID;

local settings = npcManager.setNpcSettings({
	id = npcID, 
	gfxwidth = 32, 
	gfxheight = 32, 
	width = 32, 
	height = 32, 
	frames = 2,
	framestyle = 0,
	framespeed = 8,
	score = 2,
	playerblock=false,
	nogravity = false,
	nofireball=true,
	noiceball=true,
	grabside = false,
	nohurt=true,
	isinteractable=true,
	lightradius = 64,
	lightbrightness = 1,
	lightcolor = Color.white,
	duration = 28,
	powerup = true,
	luahandlesspeed = true
})

function star.onInitAPI()
	starman.register(npcID)
	
	npcManager.registerEvent(npcID, star, "onTickNPC")
end

function star:onTickNPC()
	if not self.isHidden and self:mem(0x124, FIELD_WORD) ~= 0 --[[new spawn]] then
		if math.abs(self.speedX) < 1.5 * NPC.config[npcID].speed then
			self.speedX = self.direction * 1.5 * NPC.config[npcID].speed
		else
			self.speedX = self.speedX * 0.99
		end
	end
	
	if self.collidesBlockBottom then
		self.speedY = -8
	elseif self.collidesBlockUp then
		self.speedY = 2
	end
end

return star;
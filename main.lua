-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0,0)

-- Seed the random number generator
math.randomseed( os.time() )

-- Image sheets = gather multiple images/frames from a single picture file

local sheetOptions = 
{
	frames = 
	{ -- Asteroid 1
		x = 0,
		y = 0,
		width = 102,
		height = 83
	},

	frames = 
	{ -- Asteriod 2
		x = 0,
        y = 85,
        width = 90,
    	height = 83
	},

	frames = 
	{ -- Asteriod 3
		x = 0,
        y = 168,
        width = 100,
        height = 97
	},

	frames = 
	{ -- Ship
		x = 0,
        y = 265,
        width = 98,
        height = 79
	},

	frames = 
	{ -- Laser
		x = 98,
        y = 265,
        width = 14,
        height = 40
	},

}

local objectSheet = graphics.newImageSheet("gameObjects.png", sheetOptions)

-- Initialize Variables

local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local Shiplocal gameLoopTimer
local livesText
local scoreText

--testing
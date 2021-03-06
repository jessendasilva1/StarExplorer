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
-- organize multiple static images

local sheetOptions = 
{
	frames = 
	{
		{ -- Asteroid 1
			x = 0,
			y = 0,
			width = 102,
			height = 83
		},

	 
		{ -- Asteriod 2
			x = 0,
    	    y = 85,
    	    width = 90,
	    	height = 83
		},

		{ -- Asteriod 3
			x = 0,
	        y = 168,
	        width = 100,
	        height = 97
		},

		{ -- Ship
			x = 0,
	        y = 265,
	        width = 98,
	        height = 79
		},
		{ -- Laser
			x = 98,
	        y = 265,
	        width = 14,
	        height = 40
		},
	}	
}

local objectSheet = graphics.newImageSheet("gameObjects.png", sheetOptions)

-- Initialize Variables

local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

local backgroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()
--display groups are stacked from back to front

local background = display.newImageRect(backgroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect (mainGroup, objectSheet, 4, 98, 79) 
-- 4 = ships position in imageSheet
--98 and 76 is height and width of ship image
-- objectSheet = use images located in that specific sheet
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody (ship, { radius=30, isSensor=true } )
ship.myName = "ship"

livesText = display.newText (uiGroup, "Lives: ".. lives, 200, 80, native.systemFont, 36)
scoreText = display.newText (uiGroup, "Score: ".. score, 400, 80, native.systemFont, 36)

display.setStatusBar (display.HiddenStatusBar)

local function updateText()
	livesText.text = "Lives: ".. lives
	scoreText.text = "Score: ".. score

	end

local function createAsteroid()
	
	local newAsteroid = display.newImageRect (mainGroup, objectSheet, 1, 102, 83)
	table.insert (asteroidsTable, newAsteroid)
	physics.addBody (newAsteroid, "dynamic", {radius=40, bounce=0.8} )
	newAsteroid.myName = "asteroid"
	local whereFrom = math.random (3)

	if (whereFrom == 1) then
		-- from left
		newAsteroid.x = -60
		newAsteroid.y = math.random (500) -- spawn asteroid anywhere between top and
		--midway on the Y axis
		newAsteroid:setLinearVelocity ( math.random(40,120), math.random(20,60) )

		elseif ( whereFrom == 2 ) then
	        -- From the top
	        newAsteroid.x = math.random( display.contentWidth )
	        newAsteroid.y = -60
	        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )

	    elseif ( whereFrom == 3 ) then
	        -- From the right
	        newAsteroid.x = display.contentWidth + 60
	        newAsteroid.y = math.random( 500 )
	        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	newAsteroid:applyTorque (math.random(-6,6))

end

local function fireLaser()

	local newLaser = display.newImageRect(mainGroup, objectSheet, 5, 14, 40)
	physics.addBody(newLaser, "dynamic", { isSensor=true} )
	newLaser.isBullet = true
	newLaser.myName = "laser"

	newLaser.x = ship.x
	newLaser.y = ship.y
	newLaser:toBack()
	--sends it to the back of the display group and not 
	-- to the back of the entire screen
	transition.to(newLaser, {y=-40, time=500, onComplete = function() display.remove(newLaser) end} ) -- time in miliseconds
end

ship:addEventListener("tap", fireLaser)

local function dragShip( event )

	local ship = event.target
	local phase = event.phase

	if ("began" == phase) then
		-- set touch focus on the ship
		display.currentStage:setFocus( ship )
		ship.touchOffsetX = event.x - ship.x
		ship.touchOffsetY = event.y - ship.y

	elseif ("moved" == phase) then
		--move the shp to the new touch position
		ship.x = event.x - ship.touchOffsetX
		ship.y = event.y - ship.touchOffsetY
	
	elseif ("ended" == phase or "cancelled" == phase) then
		-- release touch focus on the ship
		display.currentStage:setFocus( nil )	
	end

	return true
end

ship:addEventListener("touch", dragShip)

local function gameLoop()
	--create new Asteroids
	createAsteroid()

	for i = #asteroidsTable, 1, -1 do
		local thisAsteroid = asteroidsTable[i]

		if (thisAsteroid.x < -100 or
			thisAsteroid.x > display.contentWidth + 100 or
			thisAsteroid.y < -100 or
			thisAsteroid.y > display.contentHeight + 100 )
		then
			display.remove(thisAsteroid)
			table.remove(asteroidsTable, i)
		end --if
	end --for

end --function

gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
-- timer.performWithDelay = perform some action after specified time
-- 500 = how often to run the function (miliseconds)
-- gameloop == funtion to run
-- 0 (or -1) = iterations; run gameloop infinitley every 500 miliseconds 

local function restoreShip()

	ship.isBodyActive = false
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100

	-- Fade in the ship
	transition.to( ship, { alpha=1, time=4000,
		onComplete = function()
			ship.isBodyActive = true
			died = false
		end
	} )
end

local function onCollision (event)

	if (event.phase == "began") then
		local obj1 = event.object1
		local obj2 = event.object2

		if ( (obj1.myName == "laser" and obj2.myName == "asteroid") ) or
			 (obj2.myName == "asteroid" and obj2.myName == "laser")	

		then
			--remove both the laser and asteroid
			display.remove( obj1 )
			display.remove( obj2 )

			for i = #asteroidsTable, 1, -1 do
				if (asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
					table.remove (asteroidsTable, i)				
					break
				end
			end

			-- increase score
			score = score + 30
			scoreText.text = "Score: ".. score


        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
                 ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
        then

        	if (died == false) then
        		died = true

        		--Update lives
        		lives = lives - 1
        		livesText.text = "Lives: ".. lives

        		if ( lives == 0 ) then
                    display.remove( ship )
                else
                    ship.alpha = 0
                    timer.performWithDelay( 1000, restoreShip )
                end

        	end
		end
	end
end

Runtime:addEventListener( "collision", onCollision )

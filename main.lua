--Libraries
Class = require("/libraries/class")
anim8 = require ("/libraries/anim8")
require("/libraries/randomlua")
--Local Source
require("entity")
require("ai")
require("graphics")
require("balls")
require("level")
require("collisions")
require("players")
require("debugger")
require("objects")
require("timers")
require("decals")

build = "0.60"

function love.load()
	--Create a debugger instance
	debugger = Debugger()
	--Create a timer instance (to queue events)
	timer = Timer()	
	--Set gamespeed
	gameSpeed = 1
	roundOver = false	

	--Make the mouse go buh bye
	love.mouse.setVisible(false)
	love.mouse.setGrab(true)
	load_fonts()
	load_colors()
	load_graphics()

	ranNum = mwc(0)

	--This table will hold references to all active tables/things in the game space
	active_entities = {}

	--Set the physics distance calculation
	love.physics.setMeter(64)
	--create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
	world = love.physics.newWorld(0,9.84*64, true)
	--create the callback handler ford collision
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	--Set point style (for cursor)
	love.graphics.setPointStyle("smooth")
	love.graphics.setPointSize(2)

	--Load level
	load_level("Four Walls All Balls")		
end



function love.update(dt)	
	--Update the physics world
	world:update(dt*gameSpeed)	

	--Updated each active object on screen
	for __, entity in ipairs(active_entities) do		
		entity:update(dt*gameSpeed)
	end
	
	--Update the debugger instance
	debugger:update()

	--Update any timers
	timer:update()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit") -- Quit the game
	end
end

--Handler for when keys are released
function love.keyreleased(key)
	
	if key == " " then
		for __, player in ipairs(active_players) do
			if player.playerNumber == "One" and not level.gameType then								
				player.canThrow = true				
			end
		end
	end

	if key == "w" then
		for __, player in ipairs(active_players) do
			if player.playerNumber == "One" then
				if not player.canDoubleJump and player.isJumping and not
					player.isDoubleJumping then

					player.canDoubleJump = true
				end

				if not player.canJump then
					player.canJump = true
				end
			end
		end
	end

	if key == "a" or key == "d" then
		for __, player in ipairs(active_players) do
			if player.playerNumber == "One" then
				if player.isRunning then
					player.isRunning = false
				end
			end
		end
	end


end

--Handler for when mouse keys are released
function love.mousereleased(x, y, button)
	if button == "l" then
		for __, player in ipairs(active_players) do
			if player.playerNumber == "One" and not level.gameType then
				player.canThrow = true
			end
		end
	end
end

--Handler for when joystick keys are released
function love.joystickreleased(joystick, button)	
	if joystick == 1 and (button == 5 or button == 1) then
		for __, player in ipairs(active_players) do
			if player.playerNumber == "Two" then
				if not player.canDoubleJump and player.isJumping and not
					player.isDoubleJumping then

					player.canDoubleJump = true
				end

				if not player.canJump then
					player.canJump = true
				end
			end
		end
	end
end

function love.draw()
	--love.graphics.scale(.9, .9)
	drawBackground()
	drawLevel()
	drawDecals()
	drawPlayers()	
	drawObjects()
	drawDebugInfo()	
end



--Misc Functions
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function math.distOnePlane(x1, x2) return ( (x2-x1)^2)^0.5 end

function checkForJoystick()
	
	if love.joystick.isOpen(1) and not love.joystick.isOpen(2) then
		return "One Joystick"
	elseif love.joystick.isOpen(1) and love.joystick.isOpen(2) then
		return "Two Joystick"
	else
		return "No Joystick"
	end	
end

function math.angle(x1,y1, x2,y2) return math.atan2(x2-x1, y2-y1) end
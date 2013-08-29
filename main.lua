Class = require("/libraries/class")
require("entity")
require("graphics")
require("balls")
require("level")
require("collisions")
require("players")
require("debugger")
require("objects")

build = "0.45"

function love.load()	
	--Create a debugger instance
	debugger = Debugger()
	gameSpeed = 1
	roundOver = false	
	love.mouse.setVisible(false)
	love.mouse.setGrab(true)
	load_colors()
	load_graphics()	
	active_entities = {}

	--Set the physics distance calculation
	love.physics.setMeter(64)
	--create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
	world = love.physics.newWorld(0,9.84*64, true)
	--create the callback handler for collision
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	--Set point style (for cursor)
	love.graphics.setPointStyle("smooth")
	love.graphics.setPointSize(4)

	--Load level
	load_level("single")		
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

end

function love.keypressed(key)
	if key == "q" then
		love.event.push("quit") -- Quit the game
	end

	if key == "r" then
		--Ball({400,100})
	end

end

--Handler for when keys are released
function love.keyreleased(key)
	
	if key == " " then
		for __, player in ipairs(active_players) do
			if player.playerNumber == "One" then
				player.canThrow = true
			end
		end
	end

	if key == "w" then
		for __, player in ipairs(active_players) do
			if player.playerNumber == "One" then
				player.canDoubleJump = true
			end
		end

	end


end

--Handler for when mouse keys are released
function love.mousereleased(x, y, button)
	if button == "l" then
		for __, player in ipairs(active_players) do
			if player.playerNumber == "One" then
				player.canThrow = true
			end
		end
	end
end

--Handler for when joystick keys are released
function love.joystickreleased(joystick, button)	
end




function love.draw()	
	drawBackground()
	drawLevel()
	drawPlayers()
	drawBalls()
	drawDebugInfo()
	drawBuild()
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
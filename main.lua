Class = require("/libraries/class")
require("entity")
require("graphics")
require("balls")
require("level")
require("collisions")
require("players")
require("debugger")


function love.load()

	debugger = Debugger()
	load_colors()
	load_graphics()
	active_entities = {}

	--Set the physics distance calculation
	love.physics.setMeter(64)
	--create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
	world = love.physics.newWorld(0,9.84*64, true)
	--create the callback handler for collision
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	load_level("basic")

	
	--Create Player 1
	Player({80, 200}, "One")

	--If a joystick is enabled, two characters will spawn
	if checkForJoystick() == "One Joystick" then
		Player({380, 200}, "Two")
		debugger:insert("One Joystick Detected")
		print(love.joystick.getNumAxes(1))	
	elseif checkForJoystick() == "Two Joystick" then
		debugger:insert("Two Joysticks Detected")
	else
		debugger:insert("No Joysticks Detected")
	end
	
	--Ball({400,100})
	--Ball({400,70})
	--Ball({500,150})
	--Ball({550,200})
	--Ball({250,200})
end



function love.update(dt)	

	--Update the physics world
	world:update(dt)

	for __, entity in ipairs(active_entities) do
		entity:update(dt)
	end

	--Update the debugger instance
	debugger:update()

end

function love.keypressed(key)
	if key == "q" then
		love.event.push("quit") -- Quit the game
	end

	if key == "r" then
		Ball({400,100})
	end
end

function love.draw()
	drawDebugInfo()
	drawBackground()
	drawLevel()
	drawPlayers()
	drawBalls()
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
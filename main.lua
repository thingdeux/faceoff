Class = require("/libraries/class")
require("entity")
require("graphics")
require("balls")
require("level")
require("collisions")
require("players")
require("debugger")


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
	love.graphics.setPointStyle("smooth")
	love.graphics.setPointSize(4)

	load_level("basic")
	spawn_players()

	
	

end



function love.update(dt)	

	--Update the physics world
	world:update(dt*gameSpeed)

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
		Ball({400,100})
	end
end

function love.draw()
	drawDebugInfo()
	drawBackground()
	drawLevel()
	drawPlayers()
	drawBalls()
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

function spawn_players(respawn)

	if not respawn then
		--Create Player 1	
		Player({getSpawnPoint("Top Left")}, "One")

		--If a joystick is enabled, two characters will spawn
		if checkForJoystick() == "One Joystick" then
			--Create Player 2
			Player({getSpawnPoint("Top Right")}, "Two")
			--debugger:insert("One Joystick Detected")		
		elseif checkForJoystick() == "Two Joystick" then
			--debugger:insert("Two Joysticks Detected")
		else
			debugger:insert("No Joysticks Detected")
		end
	else		
		--Delete all active balls
		for __, ball in ipairs(active_balls) do			
			ball.isBeingHeld = true
			ball.isOwned = false
			ball.owner = false
			ball.body:setActive(false)
			--ball:destroyObject()			
			--ball.fixture:destroy()		
			
		end


		for __, player in pairs(active_players) do
			player.ballCount = 5
			if player.isDead then
				player.isDead = false
				player.body:setFixedRotation(true)
				player.body:setAngle(0)
				player.body:setInertia(0)
				player.body:setLinearDamping(0)
				player.fixture:setRestitution(0)														
			end

			if player.playerNumber == "One" then
				player.body:setPosition(getSpawnPoint("Top Left"))
			else
				player.body:setPosition(getSpawnPoint("Top Right"))
			end
		end

		

		gameSpeed = 1
		roundOver = false
	end

end
Class = require("/libraries/class")
require("entity")
require("balls")
require("level")
require("collisions")
require("players")
require("debugger")

function love.load()

	debugger = Debugger()
	load_graphics()
	active_entities = {}

	--Set the physics distance calculation
	love.physics.setMeter(64)
	--create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
	world = love.physics.newWorld(0,9.84*64, true)
	--create the callback handler for collision
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	load_level("basic")

	Player({80, 200}, "One")

	--If a joystick is enabled, two characters will spawn
	if checkForJoystick() == "One Joystick" then
		Player({380, 200}, "Two")
		debugger:insert("One Joystick Detected")		
	elseif checkForJoystick() == "Two Joystick" then
		debugger:insert("Two Joysticks Detected")
	else
		debugger:insert("No Joysticks Detected")
	end
	
	Ball({400,100})
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

function drawBalls()
	love.graphics.setColor(255,255,255,255)

	local function chooseAnimation(ball)
		if ball.animation == "no_squish" then
			--Offset of 10 on either side to match up with the physics engine ball radius
			love.graphics.drawq(ball_sheet, no_squish, ball.body:getX(), ball.body:getY(), 0, ball.size.x, ball.size.y, 10, 10)
		elseif ball.animation == "top_squish" then
			love.graphics.drawq(ball_sheet, top_squish, ball.x, ball.y, 0, 1, 1)
		elseif ball.animation == "bottom_squish" then
			love.graphics.drawq(ball_sheet, bottom_squish, ball.x, ball.y, 0, 1, 1)
		elseif ball.animation == "left_squish" then
			love.graphics.drawq(ball_sheet, left_squish, ball.x, ball.y, 0, 1, 1)
		elseif ball.animation == "right_squish" then
			love.graphics.drawq(ball_sheet, right_squish, ball.x, ball.y, 0, 1, 1)
		elseif ball.animation == "fast_horizontal" then
			love.graphics.drawq(ball_sheet, fast_horizontal, ball.x, ball.y, 0, 1, 1)
		elseif ball.animation == "fast_vertical" then
			love.graphics.drawq(ball_sheet, fast_vertical, ball.x, ball.y, 0, 1, 1)
		end
	end



	if active_balls then
		
		for __, ball in ipairs(active_balls) do
			--local x,y = ball.body:getLinearVelocity()
			if not ball.isBeingHeld then --If the ball isn't held by a player draw it to the screen
				--Find the current animation frame for the ball				
				--love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
				chooseAnimation(ball)
				--love.graphics.print(tostring(ball.isDangerous), ball.body:getX(), ball.body:getY() - 20 )				
				--love.graphics.print("X: " .. tostring(x) .. " Y: " .. tostring(y), ball.body:getX(), ball.body:getY() - 30 )											
			end
		end
	end
end

function drawPlayers()
	for __, player in ipairs(active_players) do
		--For testing the physics bounding box (or shape/fixture)		
		--love.graphics.setColor(100,255,255,255)
		--love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
		--love.graphics.print(tostring(player.isOnGround), 20, 40)

		love.graphics.setColor(255,255,255,255)
		love.graphics.drawq(player_sheet, stationary, player.body:getX() - 40, player.body:getY() - 45, 0, .8, .8)
		love.graphics.print(tostring(player.ballCount), player.body:getX(), player.body:getY() - 55)

	end
end

function drawLevel()
	love.graphics.setColor(255,255,255,255)

	for __, levelPiece in ipairs(current_level) do
		if levelPiece.type_of_object == "rectangle" then
			love.graphics.polygon("fill", levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))
		elseif levelPiece.type_of_object == "edge" then
			love.graphics.line(levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))
		end
	end
end

function drawBackground()
end

function drawDebugInfo()
	local position = 10
	for __, info in pairs(active_debugging_text) do
		love.graphics.print(tostring(info), 20, position)
		position = position + 10
	end
end

function load_graphics()
	ball_sheet = love.graphics.newImage("/assets/ball.png")
	bottom_squish = love.graphics.newQuad(0, 0, 20, 20, 64, 64)
	top_squish = love.graphics.newQuad(20, 40, 20, 20, 64, 64)
	fast_horizontal = love.graphics.newQuad(20, 0, 20, 20, 64, 64)
	fast_vertical = love.graphics.newQuad(40, 0, 20, 20, 64, 64)
	left_squish = love.graphics.newQuad(0, 20, 20, 20, 64, 64)
	right_squish = love.graphics.newQuad(20, 20, 20, 20, 64, 64)
	no_squish = love.graphics.newQuad(0, 40, 20, 20, 64, 64)

	player_sheet = love.graphics.newImage("/assets/player_sheet.png")
	stationary = love.graphics.newQuad(0,0, 99, 110, 1024, 512)
end



--Misc Functions
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function math.distOnePlane(x1, x2) return ( (x2-x1)^2)^0.5 end


function load_level(name)
	if name == "basic" then
		--Ground
		level({0, 758}, "rectangle", 1024, 10)
		--Roof
		level({0, 0}, "rectangle", 1024, 10)
		--Left Wall
		level({0, 0}, "rectangle", 10, 768)
		--Right Wall
		level({1014, 0}, "rectangle", 10, 768)

		--Sloped Platform bottom left
		level({0, 650, 150, 768}, "edge")

		--Sloped Platform bottom left
		level({520, 650, 350, 768}, "edge")


	end
end


function checkForJoystick()
	
	if love.joystick.isOpen(1) and not love.joystick.isOpen(2) then
		return "One Joystick"
	elseif love.joystick.isOpen(1) and love.joystick.isOpen(2) then
		return "Two Joystick"
	else
		return "No Joystick"
	end
	
end
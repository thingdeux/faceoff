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
				if ball.isOwned then
					if ball.owner.playerNumber == "One" then						
						love.graphics.setColor(color.blue)
					elseif ball.owner.playerNumber == "Two" then
						love.graphics.setColor(color.brightyellow)											
					end
				else
					love.graphics.setColor(color.white)
				end
				chooseAnimation(ball)
				love.graphics.print( tostring( ball.body:getAngle() ), ball.body:getX(), ball.body:getY() )
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

		if player.playerNumber == "One" then
			love.graphics.setColor(color.white)
		elseif player.playerNumber == "Two" then
			love.graphics.setColor(color.brightyellow)			
		end

		
		love.graphics.drawq(player_sheet, stationary, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 52, 55)

			
		--love.graphics.point(player.cursor.x + player.thumbStickTracker.x, player.cursor.y + player.thumbStickTracker.y)


		love.graphics.print(tostring(player.ballCount), player.body:getX(), player.body:getY() - 55)
		love.graphics.setColor(color.red)
		love.graphics.point(player.cursor.x, player.cursor.y)	
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
	love.graphics.setColor(color.white)
	local position = 10
	for __, info in pairs(active_debugging_text) do
		love.graphics.print(tostring(info), 20, position)
		position = position + 10
	end

	local updated_position = 10
	for varName, text in pairs(updated_debugging_text) do
		love.graphics.print(tostring(varName) .. ": " .. tostring(text), 200, updated_position)
		updated_position = updated_position + 10
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

	cursor_image = love.graphics.newImage("/assets/cursor.png")
end


function load_colors()
	color = {}
	color.red = {255,0,0,255}
	color.lightred = {255, 41, 91,255}
	color.green = {0,255,0,255}
	color.blue = {0,0,255,255}
	color.cyan = {39, 181, 252, 255}
	color.brightyellow = {255, 255, 158, 255}
	color.white = {255,255,255,255}
end

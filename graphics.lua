function drawBalls()
	love.graphics.setColor(255,255,255,255)

	local function chooseAnimation(ball)
		if ball.animation == "no_squish" then
			--Offset of 10 on either side to match up with the physics engine ball radius
			love.graphics.drawq(ball_sheet, no_squish, ball.body:getX(), ball.body:getY(), ball.body:getAngle(), ball.size.x, ball.size.y, 10, 10)
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
						
				--love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
				
				if ball.isOwned then
					if ball.owner.playerNumber == "One" then
						--Blue ball for P1					
						love.graphics.setColor(color.blue)
					elseif ball.owner.playerNumber == "Two" then
						--Pee Yellow ball for P2
						love.graphics.setColor(color.brightyellow)											
					end
				else
					--White ball for non-owned ball
					love.graphics.setColor(color.white)
				end
				
				--Find the current animation frame for the ball
				chooseAnimation(ball)
			end
		end
	end
end

function drawPlayers()
	for __, player in ipairs(active_players) do		
		--For testing the physics bounding box (or shape/fixture)		
		--love.graphics.setColor(100,255,255,255)
		--love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))			
		--For testing the cursor		
		--local translatex, translatey = player.body:getWorldPoints( player.shape:getPoints() )
		--love.graphics.line(player.body:getX(), player.body:getY(), player.cursor.x, player.cursor.y)
		--love.graphics.point(player.cursor.x + player.thumbStickTracker.x, player.cursor.y + player.thumbStickTracker.y)
		--love.graphics.point(player.cursor.x, player.cursor.y)
		--debugger:keepUpdated("Player " .. tostring(player.playerNumber) .. " Knockouts", player.killCount)

		if player.playerNumber == "One" then
			love.graphics.setColor(color.white)
		elseif player.playerNumber == "Two" then
			love.graphics.setColor(color.brightyellow)	
		end
		
		--Draw player body
		love.graphics.drawq(player_sheet, stationary, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 52, 55)					
				
		--Draw the cursor
		love.graphics.draw(cursor_image, player.cursor.x, player.cursor.y, -player.cursorAngle, .7, .7, 10, 5)	

		--Draw text that shows how many balls the player has
		love.graphics.print("Balls: " .. tostring(player.ballCount), player.body:getX() - 20, player.body:getY() - 55)
								
		--Draw cursor
		love.graphics.setColor(color.red)	
		local playerx, playery = player.body:getWorldPoints( player.shape:getPoints() )
		love.graphics.point(playerx, playery + 75)

	end
end

function drawLevel()
	love.graphics.setColor(255,255,255,255)
	if current_level then
		for __, levelPiece in ipairs(current_level) do
			local levelx, levely = levelPiece.body:getWorldPoints( levelPiece.shape:getPoints() )

			love.graphics.setColor(color.white)
			if levelPiece.type_of_object == "rectangle" then
				love.graphics.polygon("fill", levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))
				love.graphics.point(levelPiece.body:getX() + 20, levelPiece.body:getY() - levelPiece.body:getY())
			elseif levelPiece.type_of_object == "edge" then
				love.graphics.line(levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))				
			elseif levelPiece.type_of_object == "movingRectangle" and not levelPiece.isInvisible then
				love.graphics.polygon("fill", levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))
			end			
			love.graphics.setColor(color.red)
			love.graphics.point(levelx, levely)
		end
	end
end

function drawBackground()
	

end

function drawDebugInfo()
	love.graphics.setColor(color.red)
	local position = 10
	for __, info in pairs(active_debugging_text) do
		love.graphics.print(tostring(info), 100, position)
		position = position + 10
	end

	local updated_position = 140 -- Should be 10
	love.graphics.setColor(color.white)
	for varName, text in pairs(updated_debugging_text) do
		love.graphics.print(tostring(varName) .. ": " .. tostring(text), 720, updated_position) --Should be 400
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


function drawBuild()
	local xLocation = screenWidth - 300

	love.graphics.setColor(color.red)	
	love.graphics.print("Enable a 360 controller for 2 player.", xLocation, 10 )
	love.graphics.print("Move with Left Stick, Aim with Right Stick", xLocation, 20 )
	love.graphics.print("LB to Jump, RB to throw", xLocation, 30 )

	love.graphics.print("Player 1 moves with WASD", xLocation, 60 )
	love.graphics.print("Aim with Mouse", xLocation, 70)
	love.graphics.print("Throw with left-click", xLocation, 80 )

	love.graphics.print("The longer you hold throw, the harder you do", xLocation, 100 )

	love.graphics.print("Prototype Build: " .. tostring(build), 0, screenHeight - 12 )
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 20, 0)
end
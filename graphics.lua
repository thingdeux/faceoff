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
					love.graphics.setColor(ball.owner.color)
				else
					--White ball for non-owned ball
					love.graphics.setColor(color.lightred)
				end
				
				
				--Find the current animation frame for the ball
				chooseAnimation(ball)
				
			end
		end
	end
end

function drawPlayers()
	local function getPlayerAnimation(player)
		if player.currentAnimation == "idle" then
			if player.isFacingRight then
				player.animations.idle:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.idle:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		elseif player.currentAnimation == "walk" then
			if player.isFacingRight then
				player.animations.walk:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.walk:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		elseif player.currentAnimation == "run" then
			if player.isFacingRight then
				player.animations.run:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.run:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		elseif player.currentAnimation == "throw" then
			if player.isFacingRight then
				player.animations.throw:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.throw:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		elseif player.currentAnimation == "catch" then
			if player.isFacingRight then
				player.animations.catch:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.catch:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		elseif player.currentAnimation == "reflect" then
			if player.isFacingRight then
				player.animations.reflect:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.reflect:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		elseif player.currentAnimation == "hit" then
			if player.isFacingRight then
				player.animations.hit:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.hit:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		elseif player.currentAnimation == "jump" then
			if player.isFacingRight then
				player.animations.jump:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.jump:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		elseif player.currentAnimation == "dead" then
			if player.isFacingRight then
				player.animations.hit:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 43.5, 54)
			else
				player.animations.hit:draw(playersheet, player.body:getX(), player.body:getY(), player.body:getAngle(), .8, .8, 56, 54)
			end
		end
	end

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

		--Draw player Particles	
		love.graphics.draw(player.particleSystem, 0, 0)

		love.graphics.setColor(player.color)
		
		--Draw player body
		getPlayerAnimation(player)

		if player.canSeeTarget then
			--Draw the cursor
			love.graphics.draw(cursor_image, player.cursor.x, player.cursor.y, -player.cursorAngle, .7, .7, 10, 5)
		end	

		love.graphics.setFont(avengers_font)
		--Draw text that shows how many balls the player has
		love.graphics.print("Balls: " .. tostring(player.ballCount), player.body:getX() - 20, player.body:getY() - 65)											
	end
end

function drawLevel()
	love.graphics.setColor(255,255,255,255)
	if current_level then
		for __, levelPiece in ipairs(current_level) do
			
			love.graphics.setColor(levelPiece.color)
			if levelPiece.type_of_object == "rectangle" then
				love.graphics.polygon("fill", levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))
				love.graphics.point(levelPiece.body:getX() + 20, levelPiece.body:getY() - levelPiece.body:getY())
			elseif levelPiece.type_of_object == "edge" then
				love.graphics.line(levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))				
			elseif levelPiece.type_of_object == "movingRectangle" then
				love.graphics.polygon("fill", levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))
			elseif levelPiece.type_of_object == "bouncyBox" then
				love.graphics.polygon("fill", levelPiece.body:getWorldPoints(levelPiece.shape:getPoints()))
			end

			--[[ --Draw world top left most coords
			local levelx, levely = levelPiece.body:getWorldPoints( levelPiece.shape:getPoints() )
			love.graphics.setColor(color.red)
			love.graphics.point(levelx, levely)
			--]]		

		end
	end


end

function drawBackground()	
	--Draw score
	love.graphics.setColor(color.orange)
	love.graphics.setFont(scoreboard_font)
	love.graphics.print("Player 1", 200, 40)
	local p1 = returnPlayerIndexByNumber("One")
	love.graphics.print(p1.killCount, 270, 80)

	local p2 = returnPlayerIndexByNumber("Two")
	love.graphics.print(p2.killCount, 970, 80)
	love.graphics.print("Player 2", 900, 40)

end

function drawDebugInfo()
	love.graphics.setFont(avengers_font_smaller)
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

	
	--Draw FPS
	love.graphics.setColor(color.red)	
	love.graphics.setFont(avengers_font)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), screenWidth - 75, screenHeight - 30)


	local xLocation = screenWidth - 300
	--Build Info
	love.graphics.setColor(color.black)	
	--love.graphics.print("Enable a 360 controller for 2 player Mode.", xLocation, 10 )	
	--love.graphics.print("LB to Jump, RB to throw", xLocation, 20 )
	love.graphics.setFont(avengers_font_smaller)
	love.graphics.print("Prototype Build: " .. tostring(build), 0, screenHeight - 10 )	
end

function load_graphics()
	ball_sheet = love.graphics.newImage("/assets/ball.png")
	string_particle = love.graphics.newImage("/assets/stringParticle.png")
	bottom_squish = love.graphics.newQuad(0, 0, 20, 20, 64, 64)
	top_squish = love.graphics.newQuad(20, 40, 20, 20, 64, 64)
	fast_horizontal = love.graphics.newQuad(20, 0, 20, 20, 64, 64)
	fast_vertical = love.graphics.newQuad(40, 0, 20, 20, 64, 64)
	left_squish = love.graphics.newQuad(0, 20, 20, 20, 64, 64)
	right_squish = love.graphics.newQuad(20, 20, 20, 20, 64, 64)
	no_squish = love.graphics.newQuad(0, 40, 20, 20, 64, 64)

	cursor_image = love.graphics.newImage("/assets/cursor.png")


	--stationary = love.graphics.newQuad(0,0, 99, 110, 1024, 512)
	playersheet = love.graphics.newImage("/assets/player_sheet.png")
	playergrid = anim8.newGrid(99, 110, playersheet:getWidth(), playersheet:getHeight(), 8, 0)		
	
	playerJump = anim8.newAnimation(playergrid(4,4), .5)
	playerStandStill = anim8.newAnimation(playergrid(1,1, 2,1, 1,2), 0.3)
	playerWalk = anim8.newAnimation(playergrid(10, 1, 9, 2, 8, 3, 7, 4, 10, 2, 9, 3), 0.12)
	playerJab = anim8.newAnimation(playergrid(3,1, 4,1, 4,1), {0.03, 8.09,0.03} )
	playerFrontKick = anim8.newAnimation(playergrid(4,4, 5,4, 4,4), {0.06,0.2, 0.2})
	playerRunAnimation = anim8.newAnimation(playergrid(6, 1, 7, 1, 6, 2, 8, 1, 7, 2, 6, 3, 9, 1, 8, 2, 7, 3, 6, 4), 0.08)
	playerHitReaction = anim8.newAnimation(playergrid(3,2), 0.09)
	playerCross = anim8.newAnimation(playergrid(5, 2), 0.4, 'pause')

	--mainPlayer_kick = anim8.newAnimation(playergrid(3,4, 5,3), {0.15,0.65} )		
	
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
	color.orange = {255,97,3,255}
	color.black = {0,0,0,255}
end


function drawBuild()
	
end

function load_fonts()
	scoreboard_font = love.graphics.newFont("/assets/fonts/scoreboard.ttf", 40)
	avengers_font = love.graphics.newFont("/assets/fonts/avengers.ttf", 25)
	avengers_font_smaller = love.graphics.newFont("/assets/fonts/avengers.ttf", 15)
end
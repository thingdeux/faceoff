--beginContact gets called when two fixtures start overlapping (two objects collide). 
--endContact gets called when two fixtures stop overlapping (two objects disconnect). 
--preSolve is called just before a frame is resolved for a current collision 
--postSolve is called just after a frame is resolved for a current collision 


function beginContact(a, b, coll)	
	local ball, ball2, level, level2, movingRectangle,movingRectangle2, player, player2 = false

	--The collision function does not easily determine what two things are colliding
	--This function will make it nice and easy to work with the colliders by giving them
	--Local variable names by type
	local function determineCollision(collider)
		local colliderName = collider:getUserData()		
		if colliderName.type == "ball" then			
			if not ball then
				ball = collider
			else
				ball2 = collider
			end		
		elseif colliderName.type == "level" then			
			if not level then				
				level = collider
			else				
				level2 = collider
			end
		elseif colliderName.type == "movingRectangle" then
			if not movingRectangle then
				movingRectangle = collider
			else
				movingRectangle2 = collider
			end
		elseif colliderName.type == "player" then
			if not player then
				player = collider
			else
				player2 = collider
			end
		end

	end


	determineCollision(a)
	determineCollision(b)

	--Handler for when a player has collided with a ball
	if ball and player then
		--This passes the balls class variables to ballObject since this is working with
		--the Box2D Objects
		local ballObject = ball:getUserData()
		local playerObject = player:getUserData()
		
		if ballObject.isOwned and ballObject.owner == playerObject and not
		   playerObject.isPullingBackToThrow and not playerObject.isThrowing then
			playerObject:pickupBall(ballObject)

		--If the ball is dangerous (ie: thrown by an opponent) and hits an opposing player
		elseif ballObject.isDangerous and not (ballObject.owner == playerObject) and not playerObject.isDead then			
			local playerBody = player:getBody() --Pass the player.body physics object to playerBody
			
			--Turn off the fixed rotation so the player will spin after they're hit
			--WEEEEEEEEEEEEEEEEEEEEE
			playerBody:setFixedRotation(false)
			player:setRestitution(.3)		

			--Cut the gamespeed down and go into slow mo 
			gameSpeed = .3

			--Kill the player hit by a ball and set a 3 second timer until respawn
			playerObject.isDead = true		
			playerObject.timer.deathTimer = love.timer.getTime() + 3

			--Using this to prevent throwing after "slowmo" kicks in
			roundOver = true

			--Add to the score of the person who threw the ball
			ballObject.owner.killCount = ballObject.owner.killCount + 1

		else
			--Player picks up the ball if no one owns it
			if not ballObject.isOwned then
				playerObject:pickupBall(ballObject)
			end
		end

	end

	--Handler for when a moving rectangle hits the wall
	if level and movingRectangle then
		local rectangleObject = movingRectangle:getUserData()		
		rectangleObject:flipMovingDirection()
	end

	--Handler for when a moving rectangle hits another moving rectangle
	if movingRectangle and movingRectangle2 then
		local rectangleObject = movingRectangle:getUserData()
		local rectangleObject2 = movingRectangle2:getUserData()
		--Flip both moving Rectangles having them *bounce* off of each other
		rectangleObject:flipMovingDirection()
		rectangleObject2:flipMovingDirection()
	end

	
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)	
end

function postSolve(a, b, coll)
end
--beginContact gets called when two fixtures start overlapping (two objects collide). 
--endContact gets called when two fixtures stop overlapping (two objects disconnect). 
--preSolve is called just before a frame is resolved for a current collision 
--postSolve is called just after a frame is resolved for a current collision 


function beginContact(a, b, coll)		
	--The collision function does not easily determine what two things are colliding
	--This function will make it nice and easy to work with the colliders by giving them
	--Local variable names by type
	
	local colliders = determineCollision(a,b)
		
-----------Player Collision Handlers START--------------------

	--Handler for when a player has collided with a ball
	if colliders.ball and colliders.player then
		--This passes the balls class variables to ballObject since this is working with
		--the Box2D Objects
		local ballObject = colliders.ball:getUserData()
		local playerObject = colliders.player:getUserData()
		
		if ballObject.isOwned and ballObject.owner == playerObject and not
		   playerObject.isPullingBackToThrow and not playerObject.isThrowing then
			playerObject:pickupBall(ballObject)

		--If the ball is dangerous (ie: thrown by an opponent) and hits an opposing player
		elseif ballObject.isDangerous and not (ballObject.owner == playerObject) and not playerObject.isDead then			
			local playerBody = colliders.player:getBody() --Pass the player.body physics object to playerBody
			
			--Turn off the fixed rotation so the player will spin after they're hit
			--WEEEEEEEEEEEEEEEEEEEEE
			playerBody:setFixedRotation(false)
			colliders.player:setRestitution(.3)		

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

	if colliders.player and colliders.movingRectangle then
		local playerObject = colliders.player:getUserData()
		playerObject.isTouching.movingRectangle = true		
	end

	if colliders.player and colliders.level then

	end

-----------Player Collision Handlers END--------------------



	--Handler for when a moving rectangle hits the wall
	if colliders.level and colliders.movingRectangle then
		local rectangleObject = colliders.movingRectangle:getUserData()		
		rectangleObject:flipMovingDirection()
	end

	--Handler for when a moving rectangle hits another moving rectangle
	if colliders.movingRectangle and colliders.movingRectangle2 then
		local rectangleObject = colliders.movingRectangle:getUserData()
		local rectangleObject2 = colliders.movingRectangle2:getUserData()
		--Flip both moving Rectangles having them *bounce* off of each other
		rectangleObject:flipMovingDirection()
		rectangleObject2:flipMovingDirection()
	end



	
end

function endContact(a, b, coll)
-----------Player Collision Handlers START--------------------
	local colliders = determineCollision(a,b)

	if colliders.movingRectangle and colliders.player then
		local playerObject = colliders.player:getUserData()
		playerObject.isTouching.movingRectangle = false
	end

-----------Player Collision Handlers END--------------------
end

function preSolve(a, b, coll)	
end

function postSolve(a, b, coll)
end


function determineCollision(collider1, collider2, passedLocalVariables)
	--local ball, ball2, level, level2, movingRectangle,movingRectangle2, player, player2 = false
	--local colliderName1 = collider1:getUserData()
	--local colliderName2 = collider2:getUserData()
	local returnedTable = {}

	local function classifyType(collider)
		local colliderName = collider:getUserData()		
		if colliderName.type == "ball" then		
			
			if not returnedTable.ball then
				returnedTable["ball"] = collider
			else
				returnedTable["ball2"] = collider
			end

		elseif colliderName.type == "level" then			
			if not returnedTable.level then				
				returnedTable["level"] = collider
			else				
				returnedTable["level2"] = collider
			end
		elseif colliderName.type == "movingRectangle" then
			if not returnedTable.movingRectangle then	
				returnedTable["movingRectangle"] = collider
			else
				returnedTable["movingRectangle2"] = collider
			end
		elseif colliderName.type == "player" then
			if not returnedTable.player then
				returnedTable["player"] = collider
			else
				returnedTable["player2"] = collider
			end
		end
	end
	
	classifyType(collider1)
	classifyType(collider2)
		
	return ( returnedTable )

end
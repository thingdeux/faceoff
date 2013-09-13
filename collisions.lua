--preSolve is called just before a frame is resolved for a current collision
--beginContact gets called when two fixtures start overlapping (two objects collide). 
--endContact gets called when two fixtures stop overlapping (two objects disconnect).  
--postSolve is called just after a frame is resolved for a current collision 


function beginContact(a, b, coll)
	--The collision function does not easily determine what two things are colliding
	--This function will make it nice and easy to work with the colliders by giving them
	--Local variable names by type			
	local colliders = determineCollision(a,b)	
	
	------Player Collision Handlers START--------------------

	--Handler for when a player has collided with a ball
	if colliders.ball and colliders.player then
		--This passes the balls class variables to ballObject since this is working with
		--the Box2D Objects
		local ballObject = colliders.ball:getUserData()
		local playerObject = colliders.player:getUserData()
		
		--If the person who owns the dangerous ball touches it
		if ballObject.isOwned and ballObject.owner == playerObject and not
		   playerObject.isThrowing then
		   --And they're not currently reflecting
		   if not playerObject.isReflecting then
				playerObject:pickupBall(ballObject)
		   end
		
		--If the ball is dangerous (ie: thrown by an opponent) and hits an opposing player
		elseif ballObject.isDangerous and ballObject.owner ~= playerObject and not playerObject.isDead then									
			
			--If the player isn't catching or reflecting, THEY DEAD			
			if not playerObject.isCatching and not playerObject.isReflecting and not roundOver then				
				--Kill the hit player
				playerObject:die()							

				if ballObject.owner then
					--Add to the score of the person who threw the ball
					ballObject.owner.killCount = ballObject.owner.killCount + 1
				end
				--If the player is catching, catch the ball
			elseif playerObject.isCatching then
				local ballBody = colliders.ball:getBody()
				local ballvelocityx, ballvelocity = ballBody:getLinearVelocity()
				
				if not playerObject.caught then
					playerObject.caught = true --Set for AI tracking, super hacky			
				end

				ballBody:setLinearVelocity(ballvelocityx*.25,0)							
				playerObject:pickupBall(ballObject)
			end
		else
			--Player picks up the ball if no one owns it
			if not ballObject.isOwned and not playerObject.isReflecting then				
				playerObject:pickupBall(ballObject)
			end
		end

		--If the player is reflecting, REFLECT
		if playerObject.isReflecting then
			local ballBody = colliders.ball:getBody()
			--Get the balls current velocity
			local reversedVelocityX, reversedVelocityY = ballBody:getLinearVelocity()
			
			if not playerObject.reflected then
				playerObject.reflected = true  --Set for AI tracking, super hacky
			end


			--Change ownership of ball			
			ballObject.owner = playerObject
			ballObject.isOwned = true
			ballObject.wallsHit = 0
			ballObject.isDangerous = true
			
			--Reverse the velocity (making it shoot back in the other direction)
			reversedVelocityX = (reversedVelocityX*-1)*.07 --Have to cut the speed down by multiplying it by .07 or it's too fast
			reversedVelocityY = (reversedVelocityY*-1)*.07

			--Kill any current velocity
			ballBody:setLinearVelocity(0,0)
			--Apply reversed velocity
			ballBody:applyLinearImpulse(reversedVelocityX, reversedVelocityY)		
		end
	end

	--Handler for when a player is colliding with a movingRectangle
	if colliders.player and colliders.movingRectangle then
		local playerObject = colliders.player:getUserData()			
		
		if coll:isTouching() then
			playerObject.isTouching.movingRectangle = true		
		end
	end

	--Handler for when a player is colliding with a level
	if colliders.player and colliders.level then
		local playerObject = colliders.player:getUserData()
		local levelObject = colliders.level:getUserData()	

		if coll:isTouching() and not levelObject.bounciness then --If the player is touching the level			
			local playerx, playery = playerObject.body:getWorldPoints( playerObject.shape:getPoints() )
			local levelx, levely = levelObject.body:getWorldPoints( levelObject.shape:getPoints() )


			--This prevents the level touch flag from being triggered by the ground beneath the players feet
			if levely < (playery + 75) then  --If the top of a level object is above a players foot				
				playerObject.isTouching.level = true
				--Set whether the player is touching a left wall or a right wall
				if levelx < playerx then
					playerObject.isTouching.levelLeft = true
				else
					playerObject.isTouching.levelRight = true
				end

			elseif levely > (playery + 75) then  --If the top of a level object is lower than the players foot
				playerObject.isTouching.level = false			
			end

		elseif coll:isTouching() and levelObject.bounciness then --If there's a bouncy object BOUNCE the thing			
			local velx, vely = playerObject.body:getLinearVelocity()			
			
			if vely > 800 then
				vely = vely * -1			
				playerObject.body:applyLinearImpulse(0, vely*.12)
			end
		end

		--If the player is falling really fast - kill them
		if playerObject.isFallingTooFast then
			local playerx, playery = playerObject.body:getWorldPoints( playerObject.shape:getPoints() )
			local levelx, levely = levelObject.body:getWorldPoints( levelObject.shape:getPoints() )
			
			if levely > playery then				
				--Kill Player
				playerObject:die()
			end
		end
	end
	-------Player Collision Handlers END--------------------

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

	if colliders.ball and (colliders.movingRectangle or colliders.level) then
		local ballObject = colliders.ball:getUserData()
		--The ball hit a level object or a movingRectangle, add to its walls hit count
		ballObject.wallsHit = ballObject.wallsHit + 1
	end


	----Oil Handlers
	if colliders.oil and colliders.level or 
		colliders.oil and colliders. movingRectangle then

		local oilObject = colliders.oil:getUserData()

		--If an oil blob hits a level of movingRectangle run leaveOilTrail and leave an oil dot
		--where it it
		if colliders.level then
			oilObject.pointerToSelf:leaveOilTrail(oilObject, colliders.level)
		elseif colliders.movingRectangle then
			oilObject.pointerToSelf:leaveOilTrail(oilObject, colliders.movingRectangle)
		end

	end
	
end

function endContact(a, b, coll)	
	-----------Player Collision Handlers START--------------------
	local colliders = determineCollision(a,b)
	
	if colliders.movingRectangle and colliders.player then		
		local playerObject = colliders.player:getUserData()		
		playerObject.isTouching.movingRectangle = false

		if level.gameType == "Hot Foot" then			
			
			if not playerObject.canThrow then							
				playerObject.canThrow = false
			end
		end
	end

	if colliders.player and colliders.level then
		local playerObject = colliders.player:getUserData()
		local levelObject = colliders.level:getUserData()
		local playerx, playery = playerObject.body:getWorldPoints( playerObject.shape:getPoints() )
		local levelx, levely = levelObject.body:getWorldPoints( levelObject.shape:getPoints() )

		--This prevents the level touch flag from being triggered by the ground beneath the players feet		
		if levely < (playery + 75) then  --If the top of a level object is lower than the players foot
			playerObject.isTouching.level = false
			playerObject.isTouching.levelLeft = false			
			playerObject.isTouching.levelRight = false
		end	
	end	

	-----------Player Collision Handlers END--------------------
end

function preSolve(a, b, coll)	
end

function postSolve(a, b, coll)
	local colliders = determineCollision(a,b)
	
	--Only perform this check if 'Hot Foot' is the game mode	
	if level.gameType == "Hot Foot" then
		--Check to see if a player is making contact with a movingRectangle that's their color		
		if colliders.player and colliders.movingRectangle then
			local playerObject = colliders.player:getUserData()		
			local levelObject = colliders.movingRectangle:getUserData()
			
			--Allows the player to throw if they're on their color
			if levelObject.color == playerObject.color then
				playerObject.canThrow = true				
			else
				playerObject.canThrow = false				
			end

		end
	end

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
		elseif colliderName.type == "oil" then			
			if not returnedTable.oil then
				returnedTable["oil"] = collider
			else		
				returnedTable["oil2"] = collider
			end
		end
	end
	
	classifyType(collider1)
	classifyType(collider2)
		
	return ( returnedTable )
end
--beginContact gets called when two fixtures start overlapping (two objects collide). 
--endContact gets called when two fixtures stop overlapping (two objects disconnect). 
--preSolve is called just before a frame is resolved for a current collision 
--postSolve is called just after a frame is resolved for a current collision 


function beginContact(a, b, coll)	
	local ball, ball2, level, player, player2 = false

	local function determineCollision(collider)
		local colliderName = collider:getUserData()		
		if colliderName.type == "ball" then			
			if not ball then
				ball = collider
			else
				ball2 = collider
			end		
		elseif colliderName == "level" then
			level = collider
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

	if ball and player then
		--This passes the balls class variables to ballObject since this is working with
		--the Box2D Objects
		local ballObject = ball:getUserData()
		local playerObject = player:getUserData()

		if ballObject.isDangerous then
			--print("Hot Ball")
		else
			playerObject.ballCount = playerObject.ballCount + 1
			ballObject.isBeingHeld = true
			ballObject:destroyObject()
			ball:destroy()	

		end
	end
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)	
end

function postSolve(a, b, coll)
end
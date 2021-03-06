Entity = Class{

	update = function(self, dt)
		
		--Player Specific Updates
		if self.type == "player" then			
			
			if self.playerNumber == "One" then
				debugger:keepUpdated("Oil Blobs", #active_traps)
				debugger:keepUpdated("Blob Points", blobCount)
				debugger:keepUpdated("Joints", jointCount)
				if active_decals then			
					debugger:keepUpdated("Slime", #active_decals)
				end				
			end


			--Get the angle for the cursor, so it rotates			
			self:determineThrowingAngle()
			self.cursorAngle = math.angle(self.cursor.x,self.cursor.y , self.body:getX(), self.body:getY())
			
			--Pass the players x/y velocitdqy to a local variable for checking below		
			local velocity_x,velocity_y = self.body:getLinearVelocity()			
			
			if velocity_y >= -1 and velocity_y <= 1 and not self.isTouching.level and not self.isJumping then
				self.isOnGround = true
				self:stopJumping()
				self.isFallingTooFast = false
						
			elseif (velocity_y < -1 and self.isTouching.movingRectangle) or 
				   (velocity_y > 1 and self.isTouching.movingRectangle) and not self.isTouching.level then

				--if I'm moving vertically but touching a moving rectangle then I'm still "on ground"
				self.isOnGround = true
				self:stopJumping()				
			elseif velocity_y < -1 or velocity_y > 1 and not self.isTouching.movingRectangle then
				--If I'm not touching anyMoving Rectangles and my velocity is higher than 0
				self.isOnGround = false				
			elseif (velocity_y == 0 and self.isTouching.level) and not self.isOnGround then
				--Quick fix ground timer, goes into effect when the player is touching a wall and they hit another wall/floor
				--Should probably rewrite this so it only applies to floors
				if not self.timer.groundTimer then
					self.timer.groundTimer = love.timer.getTime() + gameSpeed*.2					
				else
					if love.timer.getTime() > self.timer.groundTimer and not self.isOnGround then
						self.isOnGround = true
						self.timer.groundTimer = nil
						self:stopJumping()								
					end
				end
				
			end

			--If the player is falling too fast set the flag
			if velocity_y > 1200 then
				--self.isFallingTooFast = true
			end

			--Move particle emitter with player
			if level.gameType == "Hot Foot" and self.canThrow then
				if self.killCount > 9 then
					self.roundOver = true
					self.gameOver = true
				end				
				self.particleSystem:setPosition(self.body:getX(), self.body:getY())
				self.particleSystem:setDirection(self.cursorAngle)
				self.particleSystem:start()
			elseif level.gameType == "Hot Foot" and not self.canThrow then
				self.particleSystem:stop()
			end

			if self.isJumping then
				if not self.timer.jumping then
					self.timer.jumping = love.timer.getTime() + gameSpeed*self.jumpDelay
				else
					if love.timer.getTime() > self.timer.jumping then
						self.isJumping = false
						self.timer.jumping = nil
					end
				end

			end			

			if self.isThrowing or self.timer.recentlyThrownBall then
				self:throw(dt) --Throw has to come before animate												
			end

			if self.isCatching then
				self:catch(dt)
			elseif self.isReflecting then
				self:reflect(dt)
			end	

			--if the player falls off of the screen, kill them
			if self.body:getY() > screenHeight + 50 and not self.isDead then				
				self:die()
				roundOver = true
			end
						
			--If the player isn't dead allow control
			--This should remain at the very end of the player update loop
			if not self.isDead then
				if not self.isAI then								
					self:controller(velocity_x, velocity_y, self.playerNumber, dt)								
				else					
					--self:think(dt)					
				end
				self.body:setAngle(0)
			else  --If a player is dead, no control for them!								
				if love.timer.getTime() > self.timer.deathTimer then					
					spawn_players(true)
				end
			end			

			--Update Anim8 objects
			self:animate(dt)
		end

		--Ball Specific Updates
		if self.type == "ball" and not self.isBeingHeld then
			local velocity_x,velocity_y = self.body:getLinearVelocity()						

			--If the ball has slowed down to a point where it's not bouncing much
			if ( (velocity_x >= -20 and velocity_x <= 20) or (velocity_y >= -20 and velocity_y <= 20) ) and 
				(self.isOwned) then	

				--If the balls X or Y velocity dips below 20 then start a counter
				--If the velocity stays low for more than 1 second then the ball is neutral
				if not self.timer.dangerousBallOneSecondRule then
					--Only start timing if a player is not holding the ball in his hand about to throw
					if not self.owner.isPullingBackToThrow then										
						self.timer.dangerousBallOneSecondRule = love.timer.getTime() + 1
					end
				elseif love.timer.getTime() > self.timer.dangerousBallOneSecondRule then					
					self.isDangerous = false
					self.isOwned = false
				end

			else
				if self.isOwned then --If the ball has an owner(ie: has been thrown)
					self.timer.dangerousBallOneSecondRule = nil
					self.isDangerous = true
				end
			end	

			--If the ball bounces off at least 3 walls it becomes neutral
			if self.isOwned and self.wallsHit > 2 then
				self.isDangerous = false
				self.isOwned = false
				self.owner = nil
			end

			--Destroy a ball if it gets accidentally pushed outside of the screen world
			if not self.isBeingHeld then
				if (self.body:getX() > screenWidth + 40 or self.body:getX() < 0 - 40) or
			   (self.body:getY() > screenHeight + 40 or self.body:getY() < 0 - 200) then

				self:destroyObject()				
				end			
			end
		end

		if self.type == "movingRectangle" then

			if self.direction == "horizontal" then
				self.body:setLinearVelocity(self.speed, 0)
			elseif self.direction == "vertical" then
				self.body:setLinearVelocity(0, self.speed)
			end

			if self.movementShape then
				--If a table of tables is used when creating a movingRectangle instead of a direction
				--This will iterate over the points passed in the table and make the rectangle move
				--a certain amount of pixels then stop, then move another amount.
				--Ex: {50, 0}, {0, -50}, {-50, -100} --Would move the platform in a repeating triangle

				local function pushPlatformInDirection(movedDistance, direction, plane )
					local velx, vely = self.body:getLinearVelocity()

					if direction < 0 and plane == "y" then  --If this is being used on the y axis
						self.body:setLinearVelocity(velx, -self.speed)
						return (movedDistance - self.speed*dt)
					elseif direction > 0 and plane == "y" then
						self.body:setLinearVelocity(velx, self.speed)
						return (movedDistance + self.speed*dt)						
					end

					if direction < 0 and plane == "x" then --If this is being used on the x axis
						self.body:setLinearVelocity(-self.speed, vely)						
						return (movedDistance - self.speed*dt)
					elseif direction > 0 and plane == "x" then							
						self.body:setLinearVelocity(self.speed, vely)						
						return (movedDistance + self.speed*dt)							
					end
				end

				local function checkMaxMovement(current, max)					
					if max > 0 then
						if current < max then
							return true
						else
							return false
						end					
					elseif max < 0 then --If the direction is going to be negative then flip the comparison
						if current > max then
							return true
						else
							return false
						end
					elseif max == 0 then
						return false
					end
				end

				--When both of these are set to true the platform will have travelled its tables distance
				local xReady, yReady = false				


				if checkMaxMovement(self.movedDistance.x, self.movementShape[self.movementShapePosition][1]) then					
					self.movedDistance.x = pushPlatformInDirection(self.movedDistance.x, self.movementShape[self.movementShapePosition][1], "x")
				else
					xReady = true
				end

				if checkMaxMovement(self.movedDistance.y, self.movementShape[self.movementShapePosition][2]) then
					self.movedDistance.y = pushPlatformInDirection(self.movedDistance.y, self.movementShape[self.movementShapePosition][2], "y")
				else
					yReady = true
				end				

				if xReady and yReady then
					self.body:setLinearVelocity(0, 0) --Stop the platform and prepare for new movement
					if self.movementShapePosition < #self.movementShape then															
						self.movementShapePosition = self.movementShapePosition + 1						
					else						
						self.movementShapePosition = 1
					end
					self.movedDistance.x = 0
					self.movedDistance.y = 0
				end

			end
		end

		if self.type == "object" then
			if self.isSpawner then		
				if not self.timer.spawnTimer then				
					self.timer.spawnTimer = self.timer.spawnTimer + self.spawnRate			
				else 
					if love.timer.getTime() > self.timer.spawnTimer then					
						if self.type_of_object == "spawner" then
							self:spawnBall()																								
							self.timer.spawnTimer = self.timer.spawnTimer + self.spawnRate
						elseif self.type_of_object == "oil trap" then
							self:spawnOil()
							self.timer.spawnTimer = self.timer.spawnTimer + self.spawnRate						
						end										
					end				
				end				
			end

			if self.oilPattern then

			end
		end

		if self.type == "oil" then
			local function setTimerToDestroyJointsOrPoints()
				if not self.timer.timeToDestroyJoints then
					if self.drawJoints then  --If joints are still active and being drawn
						--Once an oil blob spawns a timer is set for 4 seconds
						self.timer.timeToDestroyJoints = love.timer.getTime() + 8										
					end
				elseif self.timer.timeToDestroyJoints then
					if love.timer.getTime() > self.timer.timeToDestroyJoints then						
						self.drawJoints = false  --prevent graphics from trying to draw joints
						self.timer.timeToDestroyJoints = nil
						self:destroyObject()
					end
				end
				
				--Joints have now been deleted, queue up point deletion
				if not self.timer.timeToDestroyPoints and not self.drawJoints then
					if self.drawPoints then --If points are still active and being drawn									
						self.timer.timeToDestroyPoints = love.timer.getTime() + 6
					end
				elseif self.timer.timeToDestroyPoints then
					if love.timer.getTime() > self.timer.timeToDestroyPoints then
						self.drawPoints = false  --Prevent graphics from trying to draw points
						self:destroyObject()											
						self.timer.timeToDestroyPoints = nil
					end				
				end
			end


			setTimerToDestroyJointsOrPoints()
			
		end

		if self.type == "decal" then

			if self.isOil then
				self.x = self.attachedBody:getX() + self.collisionOffset.x
				self.y = self.attachedBody:getY() + self.collisionOffset.y
			end
		end

		--If the gametype is hot foot, prepare to start changing platform colors
		if level.gameType == "Hot Foot" and not level.timer.colorChange then			
			level.timer.colorChange = love.timer.getTime() + 4				
		elseif level.gameType == "Hot Foot" and level.timer.colorChange then
			--If the colorChange timer has elapsed then change colors
			if love.timer.getTime() > level.timer.colorChange then								
				changePlatformColors()
				level.timer.colorChange = nil
			end					
		end

		--Checks to see if there is a roundstart level timer (used for animating round starts)
		if level.timer.roundStart then
			if love.timer.getTime() > level.timer.roundStart then
				level.timer.roundStart = nil
			end
		end
		
	end;

	controller = function(self, velocity_x, velocity_y, playerNumber, dt)
		if self.type == "player" then	
			local function movePlayerLeftorRight(self, direction)
				local speed = self.speed				
				if direction == "Right" then					
					if velocity_x < self.maxSpeed then						
						if self.isOnGround then
							self.isRunning = true						
							self.body:applyForce(speed, 0)						
						else
							--If player is in the air then they can only move themselves at half the speed
							self.body:applyForce(speed*self.airControl, 0)						
						end
					end

				elseif direction == "Left" then
					speed = self.speed*-1
					
					if velocity_x > -self.maxSpeed then
						if self.isOnGround then
							self.isRunning = true						
							self.body:applyForce(speed, 0)						
						else
							--If player is in the air then they can only move themselves at half the speed
							self.body:applyForce(speed*self.airControl, 0)						
						end
					end
				end			
			end

			--Controller handler for when the player jumps
			if (love.keyboard.isDown("w") and playerNumber == "One") or
			   ( (love.joystick.isDown(1, 1) or love.joystick.isDown(1,5) ) and playerNumber == "Two") then			   
					
				--If I'm on the ground and not jumping, make me jump
				if self.isOnGround and not self.isJumping and self.canJump then					
					self.body:applyLinearImpulse(0, self.jumpForce)
					self.animations.jump:gotoFrame(1)
					self.isTouching.movingRectangle = false  --I don't like this being here	
					self.isJumping = true
					self.canJump = false				

				elseif not self.isOnGround and self.isJumping then					
					--After the first jump X amount of time must pass before double jumping
					--This sets up a timer to keep track of the time
					if not self.timer.doubleJump then
						self.timer.doubleJump = love.timer.getTime() + self.doubleJumpDelay
					else
						--If enough time has passed to be able to double Jump
						if (love.timer.getTime() > self.timer.doubleJump) then													
							--Double Jump - I don't want the character to be able to double jump without
							--Letting go of the initial jump button, so there's a keyrelease function in
							--The main thread that sets "canDoubleJump" to true						
							if self.canDoubleJump then
								local x, y = self.body:getLinearVelocity()
								self.body:setLinearVelocity(x,0)
								self.body:applyLinearImpulse(0, self.jumpForce)
								--self.isJumping = false
								self.canJump = false
								self.isDoubleJumping = true
								self.animations.jump:gotoFrame(1)											
								self.canDoubleJump = false
								self.timer.doubleJump = nil
							end
						end
					end

				end				

			--Controller handler for when the player slides
			elseif (love.keyboard.isDown("s") and playerNumber =="One") then
				--self.body:setLinearVelocity(0, 0)
			end

			--Controller handler for when the player presses right
			if (love.keyboard.isDown("d") and playerNumber == "One") or
			   (love.joystick.getAxis(1, 1) > 0.8 and playerNumber == "Two") then

			   --Flip the animations the other way if the player is facing left
			   	if not self.isFacingRight then
			   		self.isFacingRight = true
			   		self:flipAnimations()
			   	end

			   	--If the player isn't touching a wall
			   	if not self.isTouching.level then
					movePlayerLeftorRight(self, "Right")
				elseif self.isTouching.level and self.isTouching.levelLeft then
					movePlayerLeftorRight(self, "Right")

				--Player is sliding on the right wall if they are pushing right and touching a right wall
				elseif self.isTouching.level and self.isTouching.levelRight and not self.isOnGround then
					if velocity_y > self.wallSlideSpeed then --I want the player to slide down the wall at at least this speed						
						self.body:applyForce(0, self.wallSlideStoppingForce)
					end
				end

			--Turn running off if the joystick is not being pressed right
			elseif love.joystick.getAxis(1,1) < 0.8 and love.joystick.getAxis(1,1) > 0 and self.isRunning and 
				self.playerNumber == "Two" then
				self.isRunning = false
			--Turn running off if the joystick is not being pressed left
			elseif love.joystick.getAxis(1,1) > -0.8 and love.joystick.getAxis(1,1) < 0 and self.isRunning and
				self.playerNumber == "Two" then				
				self.isRunning = false

			--Controller handler for when the player presses left
			elseif (love.keyboard.isDown("a") and playerNumber =="One") or
			 	   (love.joystick.getAxis(1, 1) < -0.8 and playerNumber == "Two") then

			 	--Flip the animations the other way if the player is facing left
			   	if self.isFacingRight then
			   		self.isFacingRight = false
			   		self:flipAnimations()
			   	end

			   	if not self.isTouching.level then
					movePlayerLeftorRight(self, "Left")
				elseif self.isTouching.level and self.isTouching.levelRight then
					movePlayerLeftorRight(self, "Left")

				--Player is sliding on the left wall if they are pushing left and touching a left wall
				elseif self.isTouching.level and self.isTouching.levelLeft and not self.isOnGround then
					if velocity_y > 0 then --Prevents the player from sliding up the wall						
						if velocity_y > self.wallSlideSpeed then
							self.body:applyForce(0, self.wallSlideStoppingForce)
						end
					end
				end
				
			end			

			--Controller handler for when the player presses the throw button
			if ( (love.keyboard.isDown(" ") or love.mouse.isDown("l") ) and playerNumber =="One" and not roundOver) or 
			   ( (love.joystick.isDown(1, 3) or love.joystick.isDown(1,6) )and playerNumber == "Two" and not roundOver) then

				--If player presses the throw button, throw
				if not self.isThrowing and self.canThrow and self.ballCount > 0 then				
					self.isThrowing = true
					--Go to the start of the throw frame
					self.animations.throw:gotoFrame(1)
				end

			elseif not self.canThrow and not ( love.joystick.isDown(1,3) or love.joystick.isDown(1,6) ) and (self.playerNumber == "Two") then
				
				if not level.gameType then					
					self.canThrow = true
				end
			end


			--Controller handler for when player presses the 'catch' button
			if ( love.keyboard.isDown("e") and playerNumber == "One" ) or
			   ( love.joystick.getAxis(1, 3) > 0.4 and playerNumber == "Two" ) and not self.isReflecting then
			   
			   if not self.isCatching then
			   	  self.isCatching = true
			   	  self.animations.catch:gotoFrame(1)
			   end

			end

			--Controller handler for when player presses the 'reflect' button
			if ( love.keyboard.isDown("lshift") and playerNumber == "One" ) or
			   ( love.joystick.getAxis(1, 3) < -0.4 and playerNumber == "Two" ) and not self.isCatching then
			   
			   if not self.isCatching then
			   	  self.isReflecting = true
			   	  if self.currentAnimation ~= "reflect" then
			   	  	self.animations.reflect:gotoFrame(1)			   	  	
			   	  end
			   	  
			   end
			   
			end

		end
	end;
	
	--Deal with animations
	animate = function(self, dt)

		if self.isDead then
			self.currentAnimation = "dead"
		elseif self.isReflecting then
			self.currentAnimation = "reflect"
		elseif self.isCatching then
			self.currentAnimation = "catch"
		elseif self.isThrowing then
			self.currentAnimation = "throw"
		elseif self.isJumping or self.isDoubleJumping then
			self.currentAnimation = "jump"
		elseif self.isRunning then
			self.currentAnimation = "run"		
		else
			--Default 'idle animation'
			self.currentAnimation = "idle"
		end

		for __, animation in pairs(self.animations) do
			animation:update(dt)
		end

		--Updated particles
		self.particleSystem:update(dt)		
	end;

	destroyObject = function(self)
		local function removeFromTableById(self, passedTable)
			for i, itemToRemove in ipairs(passedTable) do       
                if itemToRemove.id == self.id then
                	--print("Removing #" .. tostring(i) .. " " .. tostring(itemToRemove) .. " onTable: " .. tostring(passedTable) )
                    table.remove(passedTable, i)                                   
                end
            end
		end

        --delete ball from active_balls table
        if self.type == "ball" then           
            for i, ball in ipairs(active_balls) do          
                if ball.id == self.id then
                	ball.body:destroy()
                    table.remove(active_balls, i)                                   
                end
            end
        elseif self.type == "oil" then        	
        	for __, oil in ipairs(active_traps) do --Iterate through the active traps and find the one that is requesting a deletion
        		if oil == self then
        			
        			if not self.drawJoints and self.drawPoints then  --If the joints are still being drawn, delete them all        				
        				for __, oilJoint in ipairs(self.oilJoints) do        				
        					oilJoint:destroy() --destroy distance joint        					
        				end
        				--Kill the big center circle in the oilBlobPoints Table
        				self.oilBlobPoints[1].isActive = false
        				self.oilBlobPoints[1].body:destroy()
        				table.remove(self.oilBlobPoints, 1)
        				self.oilJoints = nil

        			elseif not self.drawJoints and not self.drawPoints then --Delete oil body points        				
        				for i, oilPoint in ipairs(self.oilBlobPoints) do        					
        					oilPoint.body:destroy()  --Destroy oil points
        				end
        				self.oilBlobPoints = nil  --Remove the oilBlopPointsTable
						
						removeFromTableById(self, active_traps)
						removeFromTableById(self, active_entities)

        			end
        			
        		end
        	end
        end

        --delete ball from active_entities table
        for i, entity in ipairs(active_entities) do
            if entity.type == "ball" and entity.id == self.id then                          
                table.remove(active_entities, i)
            end
        end
        
        self = nil
end;

}



--[[
A = 1
B = 2
X = 3
Y = 4

Left Bumper = 5
Right Bumper = 6
Back Button = 7
Start Button = 8

Left Thumbstick Click = 9
Right Thumbstick Click = 10

getHat = D-Pad


axis designation:
	1          2         3         4              5
leftstick, leftstick, triggers, rightstickY, rightstickX = love.joystick.getAxes( controller )

{Stick Directional Numbers}
      	-

-		       +

	   +


]]--
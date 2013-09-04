Entity = Class{

	update = function(self, dt)
		

		--Player Specific Updates
		if self.type == "player" then
			if self.playerNumber == "One" then
				--debugger:keepUpdated("isJumping", self.isJumping)
				--debugger:keepUpdated("isDoubleJumping", self.isDoubleJumping)
				--debugger:keepUpdated("canDoubleJump", self.canDoubleJump)
			else
				--debugger:keepUpdated("distanceToPlayer.X", self.distanceToPlayer.x)
				--debugger:keepUpdated("distanceToPlayer.Y", self.distanceToPlayer.y)
				--debugger:keepUpdated("targetOnTheRight", self.targetOnTheRight)
				debugger:keepUpdated("isCloseEnoughToAttack", self.isCloseEnoughToAttack )
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
			
			--If the player isn't dead allow control
			if not self.isDead then
				if not self.isAI then								
					self:controller(velocity_x, velocity_y, self.playerNumber, dt)								
				else					
					self:think(dt)
				end
				self.body:setAngle(0)
			else  --If a player is dead, no control for them!								
				if love.timer.getTime() > self.timer.deathTimer then					
					spawn_players(true)
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
			end

			--Destroy a ball if it gets accidentally pushed outside of the screen world
			if not self.isBeingHeld then
				if (self.body:getX() > screenWidth or self.body:getX() < 0) or
			   (self.body:getY() > screenHeight or self.body:getY() < 0) then

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
		end

		if self.type == "object" then			
			if not self.timer.spawnTimer then								
				self.timer.spawnTimer = self.timer.spawnTimer + self.spawnRate				
			else 
				if love.timer.getTime() > self.timer.spawnTimer then
					if self.ammoLeft > 0 then
						self:spawnBall()																	
						self.ammoLeft = self.ammoLeft - 1
						self.timer.spawnTimer = self.timer.spawnTimer + self.spawnRate
					end
					
				end				
			end
		end
		
	end;

	controller = function(self, velocity_x, velocity_y, playerNumber, dt)
		if self.type == "player" then	

			if love.keyboard.isDown("f") then
				self.throwForce.speedModifier = 50
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
				self.body:applyForce(0, 0)
			end

			--Controller handler for when the player presses right
			if (love.keyboard.isDown("d") and playerNumber == "One") or
			   (love.joystick.getAxis(1, 1) > 0.8 and playerNumber == "Two") then

			   --Flip the animations the other way if the player is facing left
			   	if not self.isFacingRight then
			   		self.isFacingRight = true
			   		self:flipAnimations()
			   	end

				if velocity_x < self.maxSpeed then
					if self.isOnGround then
						self.isRunning = true
						self.body:applyForce(self.speed, 0)														
					else
						--If player is in the air then they can only move themselves at half the speed
						self.body:applyForce(self.speed/2, 0)						
					end

					if self.isTouching.level then
						self.body:applyForce(0, 75)						
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

				if velocity_x > -self.maxSpeed then
					if self.isOnGround then
						self.isRunning = true
						self.body:applyForce(-self.speed, 0)						
					else
						--If player is in the air then they can only move themselves at half the speed						
						self.body:applyForce(-self.speed/2, 0)						
					end
				end

				if self.isTouching.level then
					self.body:applyForce(0, 75)					
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
				self.canThrow = true
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


	destroyObject = function(self)

		--delete ball from active_balls table
		if self.type == "ball" then
			if not self.isTracker then
				for i, ball in ipairs(active_balls) do		
					if ball.id == self.id then
						table.remove(active_balls, i)					
					end
				end
			else
				for i, ball in ipairs(active_trackers) do		
					if ball.id == self.id then
						table.remove(active_trackers, i)					
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
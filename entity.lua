Entity = Class{

	update = function(self, dt)	
		

		--Player Specific Updates
		if self.type == "player" then			
			--Pass the players x/y velocity to a local variable for checking below		
			local velocity_x,velocity_y = self.body:getLinearVelocity()
			
			debugger:keepUpdated("isTouching", self.isTouching.movingRectangle)						
			debugger:keepUpdated("Velocity", velocity_y)

			
			if velocity_y >= -1 and velocity_y <= 1 then
				self.isOnGround = true
			elseif (velocity_y < -1 and self.isTouching.movingRectangle) or 
				   (velocity_y > 1 and self.isTouching.movingRectangle) then
				--if I'm moving vertically but touching a moving rectangle then I'm still "on ground"
				self.isOnGround = true			
			elseif velocity_y < -1 or velocity_y > 1 and not self.isTouching.movingRectangle then
				--If I'm not touching anyMoving Rectangles and my velocity is higher than 0				
				self.isOnGround = false	
			end			
			
			debugger:keepUpdated("OnGround", self.isOnGround)			

			--If the player isn't dead allow control
			if not self.isDead then
				self:controller(velocity_x, velocity_y, self.playerNumber, dt)				
				self.body:setAngle(0)
			else  --If a player is dead, no control for them!								
				if love.timer.getTime() > self.timer.deathTimer then					
					spawn_players(true)
				end
			end
			

			if self.isPullingBackToThrow or self.isThrowing or
			self.timer.recentlyThrownBall then
				self:throw(dt) --Throw has to come before animate												
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
				self.timer.spawnTimer = 0
				self.timer.spawnTimer = self.timer.spawnTimer + self.spawnRate				
			elseif love.timer.getTime() > self.timer.spawnTimer then
				if self.ammoLeft > 0 then
					self:spawnBall()
					self.timer.spawnTimer = nil	
					self.ammoLeft = self.ammoLeft - 1					
					
				end				
			end
		end
		
	end;

	controller = function(self, velocity_x, velocity_y, playerNumber, dt)
		if self.type == "player" then	

			--Controller handler for when the player jumps
			if (love.keyboard.isDown("w") and playerNumber == "One") or
			   ( (love.joystick.isDown(1, 1) or love.joystick.isDown(1,5) ) and playerNumber == "Two") and self.isOnGround then
								
				if self.isOnGround then
					self.body:applyLinearImpulse(0, -self.jumpForce)										
					self.isTouching.movingRectangle = false
				end

			--Controller handler for when the player slides
			elseif (love.keyboard.isDown("s") and playerNumber =="One") then
				self.body:applyForce(0, 0)
			end

			--Controller handler for when the player presses right
			if (love.keyboard.isDown("d") and playerNumber == "One") or
			   (love.joystick.getAxis(1, 1) > 0.8 and playerNumber == "Two") then
				if velocity_x < self.maxSpeed then
					if self.isOnGround then
						self.body:applyForce(self.speed, 0)
					else
						--If player is in the air then they can only move themselves at half the speed
						self.body:applyForce(self.speed/2, 0)
					end
				end

			--Controller handler for when the player presses left
			elseif (love.keyboard.isDown("a") and playerNumber =="One") or
			 	   (love.joystick.getAxis(1, 1) < -0.8 and playerNumber == "Two") then
				if velocity_x > -self.maxSpeed then
					if self.isOnGround then
						self.body:applyForce(-self.speed, 0)
					else
						--If player is in the air then they can only move themselves at half the speed
						self.body:applyForce(-self.speed/2, 0)
					end
				end
			end			

			--Controller handler for when the player presses the throw button
			if ( (love.keyboard.isDown(" ") or love.mouse.isDown("l") ) and playerNumber =="One" and not roundOver) or 
			   ( (love.joystick.isDown(1, 3) or love.joystick.isDown(1,6) )and playerNumber == "Two" and not roundOver) then
				
				--If player presses the throw button, start reeling back to throw
				if not self.isThrowing and not self.isPullingBackToThrow and self.ballCount > 0 then
					--Set the player to be realing back their arm ready to throw
					self.isPullingBackToThrow = true					
				end
			elseif self.isPullingBackToThrow then				
				self.isPullingBackToThrow = false			
				self.isThrowing = true
			end

			if playerNumber == "One" then
				self:trackMouse(dt)  --Keep this as the very end, updates the mouse location tracker
			elseif playerNumber == "Two" then
				self:trackThumbStick(dt)
			end
		end
	end;


	destroyObject = function(self)

		--delete ball from active_balls table
		if self.type == "ball" then
			for i, ball in ipairs(active_balls) do			
				if ball.id == self.id then
					table.remove(active_balls, i)
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
	animate = function(self)
		
		--While the player is reeling back
		if self.isPullingBackToThrow then		
			--Keep the ball moving with the player while the player is holding it
			self.activeBall.body:setPosition(self.body:getX() + 30 - (self.throwForce.current - 50), self.body:getY())				

			local ballx, bally = self.activeBall.body:getPosition()				
			self.throwForce.angle = math.angle(self.body:getX(), self.body:getY(), self.cursor.x, self.cursor.y)
						
			--debugger:keepUpdated("New Angle: ", math.sin(self.throwForce.angle)	)

			self.activeBall.body:setPosition( ballx + math.sin(self.throwForce.angle)*25, bally )
			self.activeBall.body:setPosition( ballx, bally + math.cos(self.throwForce.angle)*25 )

		end

		--Snap the cursor to the player
		self.cursor.x = self.body:getX()
		self.cursor.y = self.body:getY()
					
		--Use math to ummm...magically point the cursor in the direction of the mouse -- Maaaaaaath
		if self.playerNumber == "One" then
			local angle = math.angle(self.cursor.x, self.cursor.y, love.mouse.getX(), love.mouse.getY())
			self.cursor.x = self.cursor.x + math.sin(angle)*100
			self.cursor.y = self.cursor.y + math.cos(angle)*100
		elseif self.playerNumber == "Two" then
			local angle = math.angle(self.cursor.x, self.cursor.y, self.cursor.x + self.thumbStickTracker.x, self.cursor.y + self.thumbStickTracker.y)
			self.cursor.x = self.cursor.x + math.sin(angle)*100
			self.cursor.y = self.cursor.y + math.cos(angle)*100
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
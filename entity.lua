local parameters = {}
parameters.gravity = 5
parameters.windResistance = 10
parameters.terminal_velocity = 50


Entity = Class{

	update = function(self, dt)

		--Pass the players x/y velocity to a local variable for checking below
		local velocity_x,velocity_y = self.body:getLinearVelocity()
		
		if velocity_y >= -1 and velocity_y <= 1 then
			self.isOnGround = true
		else
			self.isOnGround = false
		end

		--Player Specific Updates
		if self.type == "player" then
			self:controller(velocity_x, velocity_y, self.playerNumber)

			if self.isPullingBackToThrow or self.isThrowing then
				self:throw(dt) --Throw has to come before animate				
				self:animate(dt)	
			end
		end

		--Ball Specific Updates
		if self.type == "ball" then
			--local ballvelocity_x,ballvelocity_y = self.body:getLinearVelocity()

			if (velocity_x >= -20 and velocity_x <= 20) and (velocity_y >= -6 and velocity_y <= 6) then
				self.isDangerous = false
			else
				if self.isOwned then --If the ball has an owner(ie: has been thrown)
					self.isDangerous = true
				end
			end	
		end
		
	end;

	controller = function(self, velocity_x, velocity_y, playerNumber)
		if self.type == "player" then			

			--Controller handler for when the player jumps
			if (love.keyboard.isDown("w") and playerNumber == "One") or
			(love.joystick.isDown(1, 1) and playerNumber == "Two") and self.isOnGround then
								
				if self.isOnGround then
					self.body:applyLinearImpulse(0, -self.jumpForce)
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
						self.body:applyForce(self.speed, 0)
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
						self.body:applyForce(-self.speed, 0)
					end
				end
			end

			--Controller handler for when the player presses the throw button
			if (love.keyboard.isDown(" ") and playerNumber =="One") or 
				(love.joystick.isDown(1, 3) and playerNumber == "Two") then
				
				--If player presses the throw button, start reeling back to throw
				if not self.isThrowing and not self.isPullingBackToThrow and self.ballCount > 0 then
					--Set the player to be realing back their arm ready to throw
					self.isPullingBackToThrow = true					
				end
			elseif self.isPullingBackToThrow then				
				self.isPullingBackToThrow = false			
				self.isThrowing = true
			end			
				
		end
	end;


	destroyObject = function(self)
		for i, myvariable in ipairs(self) do
			i = nil
		end
	end;

	--Deal with animations
	animate = function(self)
		
		--While the player is reeling back
		if self.isPullingBackToThrow then			
			--Keep the ball moving with the player while the player is holding it
			self.activeBall.body:setPosition(self.body:getX() + 30  - (self.throwForce.current - 50), self.body:getY())				
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


leftstick, leftstick, triggers, rightstick = love.joystick.getAxes( controller )

{Stick Directional Numbers}
      -0.5

-1		       1

	   0.5


]]--
local parameters = {}
parameters.gravity = 5
parameters.windResistance = 10
parameters.terminal_velocity = 50


Entity = Class{

	update = function(self, dt)
		local velocity_x,velocity_y = self.body:getLinearVelocity()
		
		if velocity_y >= -1 and velocity_y <= 1 then
			self.isOnGround = true
		else
			self.isOnGround = false
		end

		--Player Specific Updates
		if self.type == "player" then
			self:controller(velocity_x, velocity_y, self.playerNumber)
		end

		--Ball Specifi Updates
		if self.type == "ball" then
			--local ballvelocity_x,ballvelocity_y = self.body:getLinearVelocity()

			if (velocity_x >= -20 and velocity_x <= 20) and (velocity_y >= -6 and velocity_y <= 6) then
				self.isDangerous = false
			else
				self.isDangerous = true
			end	
		end
		
	end;

	controller = function(self, velocity_x, velocity_y, playerNumber)
		if self.type == "player" then

			if (love.keyboard.isDown("w") and playerNumber == "One") and self.isOnGround then
								
				if self.isOnGround then
					self.body:applyLinearImpulse(0, -self.jumpForce)
				end

			elseif love.keyboard.isDown("s") then
				self.body:applyForce(0, 0)
			end


			if love.keyboard.isDown("d") then
				if velocity_x < self.maxSpeed then
					if self.isOnGround then
						self.body:applyForce(self.speed, 0)
					else
						self.body:applyForce(self.speed/2, 0)
					end
				end
			elseif love.keyboard.isDown("a") then
				if velocity_x > -self.maxSpeed then
					if self.isOnGround then
						self.body:applyForce(-self.speed, 0)
					else
						self.body:applyForce(-self.speed/2, 0)
					end
				end
			end

			if love.keyboard.isDown("e") then
				if not self.isThrowing and self.ballCount > 0 then					
					local thrownBall = Ball({self.body:getX() + 30, self.body:getY()})
					thrownBall.body:applyLinearImpulse(80, 0)

					self.ballCount = self.ballCount - 1
					--self.isThrowing = true


				end

			end			
				
		end
	end;


	destroyObject = function(self)
		for i, myvariable in ipairs(self) do
			i = nil
		end
	end;

}
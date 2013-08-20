local parameters = {}
parameters.gravity = 5
parameters.windResistance = 10
parameters.terminal_velocity = 50


Entity = Class{

	update = function(self, dt)
		local function forces(self)
			self.y = self.y + self.velocity.y
			self.x = self.x + self.velocity.x

			if not self.isOnGround then
				--If the entity is off of the ground apply gravity and accelerate by weight
				if self.velocity.y < parameters.terminal_velocity then
					self.velocity.y = self.velocity.y + (self.weight + parameters.gravity)*dt
				end
			end

			if self.velocity.x > 0 or self.velocity.x < 0 then
				if self.velocity.x > 0 then
					self.velocity.x = self.velocity.x + -parameters.windResistance*dt
				else
					self.velocity.x = self.velocity.x + parameters.windResistance*dt
				end
			end
		end

		local x,y = self.body:getLinearVelocity()
		
		if y >= -1 and y <= 1 then
			self.isOnGround = true
		else
			self.isOnGround = false
		end


		if self.type == "player" then
			if love.keyboard.isDown("up") then
								
				if self.isOnGround then
					self.body:applyLinearImpulse(0, -self.jumpForce)
				end

			elseif love.keyboard.isDown("down") then
				self.body:applyForce(0, 0)
			end


			if love.keyboard.isDown("right") then
				if self.body:getLinearVelocity() < self.maxSpeed then
					if self.isOnGround then
						self.body:applyForce(self.speed, 0)
					else
						self.body:applyForce(self.speed/2, 0)
					end
				end
			elseif love.keyboard.isDown("left") then
				if self.body:getLinearVelocity() > -self.maxSpeed then
					if self.isOnGround then
						self.body:applyForce(-self.speed, 0)
					else
						self.body:applyForce(-self.speed/2, 0)
					end
				end
			end
		end
		
		

	end;

	beginContact = function(self, a, b, coll)
		print (tostring(self) .. "Collided")
	end;


}
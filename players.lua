Player = Class{
	init = function(self, coords, playerNumber)
		self.x = coords[1]
		self.y = coords[2]
		self.orientation = 0
		self.playerNumber = playerNumber		
		self.maxSpeed = 400
		self.speed = 250
		self.jumpForce = 28
		self.friction = 6
		self.width = 35
		self.height = 75
		self.ballCount = 5
		self.weight = .1		
		self.isOnGround = false
		self.gravitiesPull = 1.8
		self.isPullingBackToThrow = false
		self.isThrowing = false
		self.throwForce = {}
		self.throwForce.current = 40
		self.throwForce.speed = 200
		self.throwForce.max = 100
		self.throwForce.angle = 0
		self.cursor = {}
		self.cursor.x = 0
		self.cursor.y = 0
		self.cursor.speed = 200	
		self.cursor.angle = 0
		self.isDead = false
		self.killCount = 0
		
		self.mouseTracker = {}
		self.mouseTracker.x = 0
		self.mouseTracker.y = 0

		self.thumbStickTracker = {}
		self.thumbStickTracker.x = 0
		self.thumbStickTracker.y = -50
		
		self.thumbStickTracker.current = {}		
		self.thumbStickTracker.current.x = 0
		self.thumbStickTracker.current.y = 0

		self.type = "player"
		self.timer = {}
		self.activeBall = nil

		self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		self.shape = love.physics.newRectangleShape(self.width, self.height)
		self.fixture = love.physics.newFixture(self.body, self.shape)

		--Set Fixture parameters
		self.fixture:setFilterData(2, 2, 4)
		self.fixture:setUserData( self )
		self.fixture:setDensity(self.weight)
		self.fixture:setFriction(self.friction)		
		self.fixture:setRestitution(0) --Ie: Bounciness
		
		--Set Body parameters
		self.body:resetMassData()
		self.body:setFixedRotation(true) --Players body won't rotate unless this is changed
		self.body:setGravityScale(self.gravitiesPull)
		
		

		
		

		if not active_players then
			active_players = {}
			table.insert(active_players, self)
		else
			table.insert(active_players, self)
		end

		table.insert(active_entities, self)

	end;

	--Handlers for Throwing the ball
	throw = function(self, dt)

		if self.isPullingBackToThrow then
			if not self.activeBall then
				--Spawn a ball and put it next to the player (in their hand)								
				self.activeBall = Ball({self.body:getX() + 30, self.body:getY()})			

				--Set the ball to being owned by the current player
				self.activeBall.isOwned = true
				self.activeBall.owner = self
				self.isDangerous = true
			else
				--Stop the ball from simulating while the player holds it in their hand				
				self.activeBall.body:setActive (false)							

				--Start 'charging' up the throw				
				if self.throwForce.current < self.throwForce.max then
					self.throwForce.current = self.throwForce.current + self.throwForce.speed*dt
				end		
			end
			
		end
			
			
		if self.isThrowing and not self.timer.throwing then
			self.activeBall.body:setActive (true)
			--self.activeBall.body:applyLinearImpulse(self.throwForce.current, -20)			

			self.activeBall.body:applyLinearImpulse(math.sin(self.throwForce.angle)*100, math.cos(self.throwForce.angle)*100)
			self.ballCount = self.ballCount - 1
			self.timer.throwing = love.timer.getTime() + .4

			--This timer keeps the ball from colliding with the thrower
			self.timer.recentlyThrownBall = love.timer.getTime() + .02

		elseif self.isThrowing and self.timer.throwing then
			if love.timer.getTime() > self.timer.throwing then				
				self.isThrowing = false
				self.timer.throwing = nil				
				self.throwForce.current = 40
			end
		end

		--This keeps the ball from colliding with the thrower - 
		if self.timer.recentlyThrownBall then
			if love.timer.getTime() < self.timer.recentlyThrownBall then			
				self.activeBall.fixture:setMask(2)				
			else				
				self.activeBall.fixture:setMask(1)
				self.activeBall = nil
				self.timer.recentlyThrownBall = nil
			end
		end
					

	end;

	pickupBall = function(self, ballObject)
		self.ballCount = self.ballCount + 1
		ballObject.isBeingHeld = true
		ballObject:destroyObject()
		ballObject.fixture:destroy()
	end;

	trackMouse = function(self)
	    x, y = love.mouse.getPosition()
		self.mouseTracker.x = x					
		self.mouseTracker.y = y

		self:keepCursorNearPlayer(x,y, "mouse")	
	end;

	trackThumbStick = function(self, dt)
		self.thumbStickTracker.current.y = love.joystick.getAxis(1, 4)
		self.thumbStickTracker.current.x = love.joystick.getAxis(1, 5)
		
		if self.thumbStickTracker.current.x >= -0.4 and self.thumbStickTracker.current.x < 0.4 then
			self.thumbStickTracker.current.x = 0 --Stops things from happening if the stick has just barely been touched
		end

		if self.thumbStickTracker.current.y >= -0.3 and self.thumbStickTracker.current.y < 0.3 then
			self.thumbStickTracker.current.y = 0 --Stops things from happening if the stick has just barely been touched
		end		

		--X Plane movement for thumbstick tracking
		if self.thumbStickTracker.current.x > 0 and 
			not self:keepCursorNearPlayer(self.cursor.x + self.thumbStickTracker.x, self.body:getY(), "stick", dt) then
			self.thumbStickTracker.x = self.thumbStickTracker.x + self.cursor.speed*dt
		elseif self.thumbStickTracker.current.x < 0 and
			not self:keepCursorNearPlayer(self.cursor.x + self.thumbStickTracker.x, self.body:getY(), "stick", dt) then

			self.thumbStickTracker.x = self.thumbStickTracker.x - self.cursor.speed*dt
		end


		--Y movement for thumbstick tracking
		if  self.thumbStickTracker.current.y < 0 and not
			self:keepCursorNearPlayer(self.body:getX(), self.cursor.y + self.thumbStickTracker.y, "stick", dt) then

			self.thumbStickTracker.y = self.thumbStickTracker.y - self.cursor.speed*dt
		elseif self.thumbStickTracker.current.y > 0 and not
			self:keepCursorNearPlayer(self.body:getX(), self.cursor.y + self.thumbStickTracker.y, "stick", dt) then
			self.thumbStickTracker.y = self.thumbStickTracker.y + self.cursor.speed*dt
		end
		
				
	end;

	keepCursorNearPlayer = function(self, x, y, controlType, dt)
		if y >= self.body:getY() + 100 then
			if controlType == "mouse" then
				love.mouse.setPosition(x, self.body:getY() + 100)
			elseif controlType == "stick" then				
				if self.thumbStickTracker.current.y > 0 then
					self.thumbStickTracker.y = self.thumbStickTracker.y					
					return true
				else
					return false
				end				
			end
		elseif y <= self.body:getY() - 100 then
			if controlType == "mouse" then
				love.mouse.setPosition(x, self.body:getY() - 100)
			
			elseif controlType == "stick" then				
				if self.thumbStickTracker.current.y < 0 then
					self.thumbStickTracker.y = self.thumbStickTracker.y					
					return true
				else
					return false
				end

			end
		end

		if x <= self.body:getX() - 100 then
			if controlType == "mouse" then
				love.mouse.setPosition(self.body:getX() - 100, y)
			elseif controlType == "stick" then
				if self.thumbStickTracker.current.x < 0 then
					self.thumbStickTracker.y = self.thumbStickTracker.y					
					return true
				else
					return false
				end				
			end
		elseif x >= self.body:getX() + 100 then
			if controlType == "mouse" then
				love.mouse.setPosition(self.body:getX() + 100, y)
			elseif controlType == "stick" then
				if self.thumbStickTracker.current.x > 0 then
					self.thumbStickTracker.y = self.thumbStickTracker.y					
					return true
				else
					return false
				end
			end
		end
		
		--If the cursor tracker isn't pass the threshold.
		if controlType == "stick" then			
			return false
		end
	end;

}

Player:include(Entity)
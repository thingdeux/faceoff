Player = Class{
	init = function(self, coords, playerNumber)
		self.x = coords[1]
		self.y = coords[2]
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
		self.throwForce.max = 100

		self.type = "player"
		self.timer = {}
		self.activeBall = nil

		self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		self.shape = love.physics.newRectangleShape(self.width, self.height)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData( self )
		self.fixture:setFilterData(2, 2, 4)

		--Set the weight/density of the player
		self.fixture:setDensity(self.weight)
		self.body:resetMassData()

		--Set the friction
		self.fixture:setFriction(self.friction)
		self.fixture:setRestitution(0)

		--Players body won't rotate unless this is changed
		self.body:setFixedRotation(true)
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
					self.throwForce.current = self.throwForce.current + 55*dt					
				end				
			end
			
		end
			
			
		if self.isThrowing and not self.timer.throwing then
			self.activeBall.body:setActive (true)
			self.activeBall.body:applyLinearImpulse(self.throwForce.current, 0)
			self.ballCount = self.ballCount - 1
			self.timer.throwing = love.timer.getTime() + .4
		elseif self.isThrowing and self.timer.throwing then
			if love.timer.getTime() > self.timer.throwing then				
				self.isThrowing = false
				self.timer.throwing = nil
				self.activeBall = nil
				self.throwForce.current = 40
			end
		end
					

	end;

	pickupBall = function(self, ballObject)
		self.ballCount = self.ballCount + 1
		ballObject.isBeingHeld = true
		ballObject:destroyObject()
		ballObject.fixture:destroy()
	end;
}

Player:include(Entity)



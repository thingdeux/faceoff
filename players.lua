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
		self.throwForce.speed = 75
		self.throwForce.max = 100
		self.cursor = {}
		self.cursor.x = 0
		self.cursor.y = 0		
		self.cursor.angle = 0

		self.cursor.tracker = {}
		self.cursor.tracker.x = 0
		self.cursor.tracker.y = 0
		
		self.mouseTracker = {}
		self.mouseTracker.x = 0
		self.mouseTracker.y = 0

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
			self.activeBall.body:applyLinearImpulse(self.throwForce.current, 0)
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
		self.mouseTracker.x = love.mouse.getX()					
		self.mouseTracker.y = love.mouse.getY()		
		love.mouse.setPosition(512, 384)
	end;
}

Player:include(Entity)





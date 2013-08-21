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

		self.isPullingBackToThrow = false
		self.isThrowing = false
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

		if not active_players then
			active_players = {}
			table.insert(active_players, self)
		else
			table.insert(active_players, self)
		end

		table.insert(active_entities, self)

	end;
}

Player:include(Entity)



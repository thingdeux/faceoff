Player = Class{
	init = function(self, coords, size)
		self.x = coords[1]
		self.y = coords[2]
		self.maxSpeed = 400
		self.speed = 250
		self.jumpForce = 28
		self.friction = 6
		self.width = 35
		self.height = 75
		self.ballCount = 0
		self.weight = .1
		self.isOnGround = false
		self.type = "player"

		self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		self.shape = love.physics.newRectangleShape(self.width, self.height)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData("player")
		self.fixture:setFilterData(2, 2, 4)

		--Set the weight/density of the player
		self.fixture:setDensity(self.weight)
		self.body:resetMassData()

		--Set the friction
		self.fixture:setFriction(self.friction)


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
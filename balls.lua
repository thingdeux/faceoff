Ball = Class{
	init = function(self, coords)
		self.x = coords[1]
		self.y = coords[2]
		self.velocity = {}
		self.velocity.x = 0
		self.velocity.y = 0		
		self.size = {}
		self.friction = .5
		self.size.x = .65
		self.size.y = .65
		self.weight = 4
		self.bounciness = .8 --The higher the bouncier
		self.isBeingHeld = false
		self.wallsHit = 0 --Counts number of balls hit

		self.isOwned = false
		self.owner = false

		self.isDangerous = false
		self.animation = "no_squish"
		self.type = "ball"		
		self.isOnGround = false
		self.timer = {}

		--Create the active_balls table
		if not active_balls then
			active_balls = {}
			table.insert(active_balls, self)					
		else
			table.insert(active_balls, self)	
		end

		if not totalBallsSpawned then
			totalBallsSpawned = 1
		else
			totalBallsSpawned = totalBallsSpawned + 1
		end
		--Assign the ball an ID (for use in deletion)
		self.id = totalBallsSpawned
		
		 --place the body in the center of the world and make it dynamic, so it can move around
		self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		--Ball shape has a radius of 20
		self.shape = love.physics.newCircleShape(5)
		-- Attach fixture to body and give it a density of 1.
		self.fixture = love.physics.newFixture(self.body, self.shape, 1)

		--This is gonna cause more processing but may be necessary if the collision is not accurate enough
		self.body:setBullet(true)

		--fixture parameters
		self.fixture:setDensity(self.weight)
		--Set the balls friction
		self.fixture:setFriction(self.friction)		
		--Set a filter mask so balls will not collide with each other
		self.fixture:setFilterData(2, 2, -2)
		--Set how springy the ball is
		self.fixture:setRestitution(self.bounciness)
		--Identify the type of physics object
		self.fixture:setUserData( self )

		--body parameters
		self.body:resetMassData()

		--Insert a reference into the active_entities table
		table.insert(active_entities, self)
	end;

	

}

Ball:include(Entity)
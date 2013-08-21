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

		self.isOwned = false
		self.owner = false

		self.isDangerous = true
		self.animation = "no_squish"
		self.type = "ball"		
		self.isOnGround = false		

		--Create the active_balls table
		if not active_balls then
			active_balls = {}
			table.insert(active_balls, self)			
		else
			table.insert(active_balls, self)			
		end	
		
		 --place the body in the center of the world and make it dynamic, so it can move around
		self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		--Ball shape has a radius of 20
		self.shape = love.physics.newCircleShape(5)
		-- Attach fixture to body and give it a density of 1.
		self.fixture = love.physics.newFixture(self.body, self.shape, 1)


		
		--Set the balls density
		self.fixture:setDensity(self.weight)
		self.body:resetMassData()

		--Set the balls friction
		self.fixture:setFriction(self.friction)		
		--Set a filter mask so balls will not collide with each other
		self.fixture:setFilterData(2, 2, -2)
		--Set how springy the ball is
		self.fixture:setRestitution(self.bounciness)
		--Identify the type of physics object
		self.fixture:setUserData( self )
		

		

		

		--Insert a reference into the active_entities table
		table.insert(active_entities, self)
	end;

	

}

Ball:include(Entity)
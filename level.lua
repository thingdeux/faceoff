Level = Class{
	init = function(self, coords, type_of_object, width, height, direction, speed, isInvisible)
		self.type_of_object = type_of_object
		
		if self.type_of_object == "rectangle" then
			self.width = width
			self.height = height
			self.x = coords[1] --Starting X point of the line
			self.y = coords[2] --Starting Y point of the line
			self.type = "level"
			
			--The shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)		
			self.body = love.physics.newBody(world, self.x + self.width/2, self.y + self.height/2, "static")
			--make a rectangle with a width of width and a height of height
			self.shape = love.physics.newRectangleShape(self.width, self.height)
			--attach shape to body (think, skeleton)
			self.fixture = love.physics.newFixture(self.body, self.shape)			

			--Set the level filter mask to 3 so level pieces won't collide with each other
			self.fixture:setFilterData(3, 3, -3)
		elseif self.type_of_object == "edge" then
			self.x = coords[1]
			self.y = coords[2]
			self.x1 = coords[3]
			self.y1 = coords[4]
			self.type = "level"
			self.body = love.physics.newBody(world, self.x, self.y - self.y)
			self.shape = love.physics.newEdgeShape(self.x, self.y, self.x1, self.y1)
			self.fixture = love.physics.newFixture(self.body, self.shape)						
			self.fixture:setFriction(0)

			--Set the level filter mask to 3 so level pieces won't collide with each other
			self.fixture:setFilterData(3, 3, -3)
		elseif self.type_of_object == "movingRectangle" then			
			self.width = width
			self.height = height
			self.isInvisible = isInvisible
			self.x = coords[1] --Starting X point of the line
			self.y = coords[2] --Starting Y point of the line
			self.type = "movingRectangle"
			self.direction = direction
			self.speed = speed
			self.mass = 10000000
			self.currentDirection = "right"

			--The shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)		
			self.body = love.physics.newBody(world, self.x + self.width/2, self.y + self.height/2, "dynamic")
			--make a rectangle with a width of width and a height of height
			self.shape = love.physics.newRectangleShape(self.width, self.height)
			--attach shape to body (think, skeleton)
			self.fixture = love.physics.newFixture(self.body, self.shape)

			--Fixture parameters
			self.fixture:setDensity(self.mass)

			--Body parameters
			self.body:setMass(self.mass)			
			self.body:setFixedRotation(true)
			self.body:setGravityScale(0)
			self.body:resetMassData()


			--Fixture parameters
			self.fixture:setFilterData(3, 3, 3)
			table.insert(active_entities, self)		
		end
		
		
		
		self.fixture:setUserData( self )

		if not current_level then
			current_level = {}
			table.insert(current_level, self)
		else
			table.insert(current_level, self)
		end	
	end;

	--Flips the moving rectangle and sends it the opposite way
	flipMovingDirection = function(self)
		if self.currentDirection == "right" then
			self.currentDirection = "left"
		elseif self.currentDirection == "left" then
			self.currentDirection = "right"
		elseif self.currentDirection == "up" then
			self.currentDirection = "down"
		elseif self.currentDirection == "down" then
			self.currentDirection = "up"
		end
		--Flip the speed from positive to negative or vice-versa
		self.speed = self.speed * -1		
	end;

}

Level:include(Entity)



function load_level(name)
	if name == "basic" then
		level = {}
		level.name = name
		level.spawnPoints = {}
		table.insert(level.spawnPoints, {["x"] = 120, ["y"] = 50, ["name"] = "Top Left"})
		table.insert(level.spawnPoints, {["x"] = 10, ["y"] = 600, ["name"] = "Bottom Left"})
		table.insert(level.spawnPoints, {["x"] = 950, ["y"] = 50, ["name"] = "Top Right"})
		table.insert(level.spawnPoints, {["x"] = 950, ["y"] = 600, ["name"] = "Bottom Right"})
		level.roundOver = false

		--Ground
		Level({0, 758}, "rectangle", 1024, 10)
		--Roof
		Level({0, 0}, "rectangle", 1024, 10)
		--Outcropping to stop the elevator
		Level({460, 0}, "rectangle", 100, 140)

		--Elevator platform
		Level({460, 740}, "rectangle", 100, 20)

		--Stationary block overhangs
		Level({10, 400}, "rectangle", 300, 50)
		Level({720, 400}, "rectangle", 300, 50)

		--Right Ball container
		Level({900, 370}, "rectangle", 5, 30)		
		--Right Ball container
		Level({100, 370}, "rectangle", 5, 30)		



		--Left Wall
		Level({0, 0}, "rectangle", 10, 768)
		--Right Wall
		Level({1014, 0}, "rectangle", 10, 768)
			

		--Sloped Platform bottom left
		Level({0, 650, 150, 768}, "edge")
		--Sloped Platform bottom right
		Level({520, 650, 350, 768}, "edge")

		--Moving Sections				
		--Pounders below the overhang
		Level({300, 500}, "movingRectangle", 20, 80, "vertical", 200)
		Level({710, 500}, "movingRectangle", 20, 80, "vertical", 200)

		--Elevator
		Level({460, 500}, "movingRectangle", 100, 5, "vertical", 200)	
		
		--Objects
		Object({940, 350}, "spawner")
		Object({940, 350}, "spawner")




	end
end

function getSpawnPoint(name)
	for __, spawnpoint in ipairs(level.spawnPoints) do		
		if spawnpoint.name == name then			
			return spawnpoint.x, spawnpoint.y

		end
	end
end
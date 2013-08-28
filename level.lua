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
			self.body = love.physics.newBody(world, 0, 0)
			self.shape = love.physics.newEdgeShape(self.x, self.y, self.x1, self.y1)
			self.fixture = love.physics.newFixture(self.body, self.shape)

			if width == "slippery" then
				self.fixture:setFriction(0)
			elseif width == "passable" then				
				self.body:setActive(false)
			elseif width == "rough" then
				self.fixture:setFriction(1)
			end

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
		level.spawnerBallCount = 5
		level.spawnPoints = {}

		table.insert(level.spawnPoints, {["x"] = 10, ["y"] = screenHeight -100, ["name"] = "Bottom Left"})		
		table.insert(level.spawnPoints, {["x"] = screenWidth - 30, ["y"] = screenHeight -100, ["name"] = "Bottom Right"})
		table.insert(level.spawnPoints, {["x"] = 120, ["y"] = 50, ["name"] = "Top Left"})
		table.insert(level.spawnPoints, {["x"] = 950, ["y"] = 50, ["name"] = "Top Right"})

		level.roundOver = false

		
		Level({0, screenHeight - 10}, "rectangle", screenWidth, 10) --Ground		
		Level({0, 0}, "rectangle", screenWidth, 10) --Roof		
		Level({0, 0}, "rectangle", 10, screenHeight) --Left Wall		
		Level({screenWidth - 10, 0}, "rectangle", 10, screenHeight) --Right Wall
		
		--Stationary block overhangs
		Level({10, screenHeight - 400}, "rectangle", 300, 50)
		Level({screenWidth - 300, screenHeight - 400}, "rectangle", 300, 50)

		
		Level({screenWidth - 124, screenHeight - 430}, "rectangle", 5, 30)		--Right Ball container		
		Level({100, screenHeight - 430}, "rectangle", 5, 30)		--Left Ball container
							
		Level({screenWidth - 990, screenHeight - 200}, "movingRectangle", 20, 80, "vertical", 200) --Left pounder below the overhang
		Level({screenWidth - 300, screenHeight - 200}, "movingRectangle", 20, 80, "vertical", 200) --Right pounder below the overhang
	
		Level({screenWidth/2, 0}, "rectangle", 100, 140) --Outcropping to stop the elevator		
		Level({screenWidth/2, 500}, "movingRectangle", 100, 5, "vertical", 200)	 --Elevator		
		Level({screenWidth/2, screenHeight - 20}, "rectangle", 100, 20) --Elevator platform
		
		--Objects (Spawning)
		Object({screenWidth - 50, screenHeight - 500}, "spawner")
		Object({50, screenHeight - 500}, "spawner")

		--Spawn players
		spawn_players()
	elseif name == "single" then
		level = {}
		level.name = name
		level.spawnerBallCount = 1
		level.spawnPoints = {}
		level.game_mode = "single ball"

		table.insert(level.spawnPoints, {["x"] = 100, ["y"] = screenHeight -100, ["name"] = "Bottom Left"})		
		table.insert(level.spawnPoints, {["x"] = screenWidth - 100, ["y"] = screenHeight -100, ["name"] = "Bottom Right"})
		--table.insert(level.spawnPoints, {["x"] = 120, ["y"] = 50, ["name"] = "Top Left"})
		--table.insert(level.spawnPoints, {["x"] = 950, ["y"] = 50, ["name"] = "Top Right"})

		level.roundOver = false
		
		Level({0, screenHeight - 10}, "rectangle", screenWidth, 10)  --Ground		
		--[[
		Level({0, 0}, "rectangle", 10, screenHeight) --Left Wall		
		Level({screenWidth - 10, 0}, "rectangle", 10, screenHeight) ----Right Wall				
		Level({0, 0}, "rectangle", screenWidth, 10) --Roof

		Level({screenWidth/2 - 50, screenHeight - 200}, "rectangle", 100, 190) --Podium in center
		Level({screenWidth/2 - 100, screenHeight - 100}, "rectangle", 50, 90) --Step left of the podium
		Level({screenWidth/2 + 50, screenHeight - 100}, "rectangle", 50, 90) --Step right of the podium

		Level({screenWidth/2, screenHeight - 200,  screenWidth/2, screenHeight - 220}, "edge", "passable") --Ball Stand Leg
		Level({screenWidth/2, screenHeight - 220,  screenWidth/2 - 30, screenHeight - 230}, "edge", "rough") --Ball Stand Left Arm
		Level({screenWidth/2, screenHeight - 220,  screenWidth/2 + 30, screenHeight - 230}, "edge", "rough") --Ball Stand Right Arm

		Level({0, screenHeight - 50}, "movingRectangle", 50, 2, "vertical", 200)  --Left Elevator		
		Level({screenWidth-50, screenHeight - 50}, "movingRectangle", 50, 2, "vertical", 200)  --Right Elevator


		Level({screenWidth*.15, screenHeight - 700}, "rectangle", 200, 50) --Left upper floating platform
		Level({screenWidth*.70, screenHeight - 700}, "rectangle", 200, 50) --Right upper floating platform

		Level({screenWidth*.25, screenHeight - 500}, "rectangle", 200, 50) --Left upper floating platform
		Level({screenWidth/2 + 100, screenHeight - 500}, "rectangle", 200, 50) --Left upper floating platform
		--]]

		--Objects (Spawning)
		spawner = Object({screenWidth/2, screenHeight - 280}, "spawner")
		spawner:setSpawnerAmmo(level.spawnerBallCount)


		--Spawn players
		spawn_players()

	end
end

function getSpawnPoint(name)
	for __, spawnpoint in ipairs(level.spawnPoints) do		
		if spawnpoint.name == name then			
			return spawnpoint.x, spawnpoint.y

		end
	end
end
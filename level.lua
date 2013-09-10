Level = Class{
	init = function(self, coords, type_of_object, width, height, direction, speed)
		self.type_of_object = type_of_object
		self.color = color.white
		self.timer = {}

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

			--Made up of a table, assumes the 1st segment of the table is the first movement distance
			--If the table starts off with {-100, 0} then the shape will move exactly 100 pixels up
			--Then move to the 2nd table element and follow its directions
			if type(direction) == "table" then			
				self.movementShapePosition = 1
				self.movementShape = direction
				self.movedDistance = {}
				self.movedDistance.x = 0
				self.movedDistance.y = 0				
			else
				self.direction = direction
			end
			self.x = coords[1] --Starting X point of the line
			self.y = coords[2] --Starting Y point of the line
			self.type = "movingRectangle"			
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
		elseif self.type_of_object == "bouncyBox" then
			self.width = width
			self.height = height
			self.x = coords[1] --Starting X point of the line
			self.y = coords[2] --Starting Y point of the line
			self.type = "level"
			self.color = color.orange
			self.bounciness = 15
			
			--The shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)		
			self.body = love.physics.newBody(world, self.x + self.width/2, self.y + self.height/2, "static")
			--make a rectangle with a width of width and a height of height
			self.shape = love.physics.newRectangleShape(self.width, self.height)
			--attach shape to body (think, skeleton)
			self.fixture = love.physics.newFixture(self.body, self.shape)			

			--Set the level filter mask to 3 so level pieces won't collide with each other
			self.fixture:setFilterData(3, 3, -3)
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
	if name == "Crappy First Level" then
		level = {}
		level.name = name
		level.spawnerBallCount = 5
		level.spawnPoints = {}
		level.timer = {}

		table.insert(level.spawnPoints, {["x"] = 10, ["y"] = screenHeight -100, ["name"] = "Bottom Left"})		
		table.insert(level.spawnPoints, {["x"] = screenWidth - 30, ["y"] = screenHeight -100, ["name"] = "Bottom Right"})
		table.insert(level.spawnPoints, {["x"] = 120, ["y"] = 50, ["name"] = "Top Left"})
		table.insert(level.spawnPoints, {["x"] = 950, ["y"] = 50, ["name"] = "Top Right"})	

		
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
	elseif name == "Podium" then
		level = {}
		level.name = name
		level.playerBallCount = 5
		level.spawnerBallCount = 1
		level.spawnPoints = {}
		level.timer = {}	

		table.insert(level.spawnPoints, {["x"] = 100, ["y"] = screenHeight -100, ["name"] = "Bottom Left"})		
		table.insert(level.spawnPoints, {["x"] = screenWidth - 100, ["y"] = screenHeight -100, ["name"] = "Bottom Right"})
		--table.insert(level.spawnPoints, {["x"] = 120, ["y"] = 50, ["name"] = "Top Left"})
		--table.insert(level.spawnPoints, {["x"] = 950, ["y"] = 50, ["name"] = "Top Right"})		
		
		Level({0, screenHeight - 10}, "rectangle", screenWidth, 10)  --Ground	
		
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

		--Objects (Spawning)
		spawner = Object({screenWidth/2, screenHeight - 280}, "spawner")
		spawner:setSpawnerAmmo(level.spawnerBallCount)

		Level({screenWidth-210, screenHeight - 150}, "movingRectangle", 10, 100, "vertical", 300)  --Right Block next to bottom right start
		Level({210, screenHeight - 450}, "movingRectangle", 10, 100, "vertical", 300)  --Left Block next to bottom right start	
	elseif name == "Catch n' Release" then
		level = {}
		level.name = name
		level.spawnerBallCount = 5
		level.playerBallCount = 2
		level.spawnPoints = {}
		level.timer = {}	

		table.insert(level.spawnPoints, {["x"] = screenWidth/2 - 360, ["y"] = screenHeight/2 + 155, ["name"] = "Bottom Left"})		
		table.insert(level.spawnPoints, {["x"] = screenWidth/2 + 200, ["y"] = screenHeight/2 + 155, ["name"] = "Bottom Right"})		

		level.roundOver = false
		Level({screenWidth/2 - 400, screenHeight/2 + 200}, "rectangle", screenWidth/2, 10) --Ground		
		Level({screenWidth/2 - 400, screenHeight/2 + 100}, "rectangle", screenWidth/2, 10) --Roof		
		Level({screenWidth/2 - 400, screenHeight/2 + 100}, "rectangle", 10, 100) --Left Wall		
		Level({screenWidth/2 + 230, screenHeight/2 + 100}, "rectangle", 10, 100) --Right Wall

		Level({screenWidth/2 - 85, screenHeight/2 + 150}, "movingRectangle", 5, 20, "vertical", 100)  --Left Elevator
	elseif name == "Four Walls All Balls" then
		level = {}
		level.name = name
		level.spawnerBallCount = 5
		level.playerBallCount = 8
		level.spawnPoints = {}
		level.timer = {}

		table.insert(level.spawnPoints, {["x"] = 10, ["y"] = screenHeight -100, ["name"] = "Bottom Left"})		
		table.insert(level.spawnPoints, {["x"] = screenWidth - 30, ["y"] = screenHeight -100, ["name"] = "Bottom Right"})

		Level({0, screenHeight - 10}, "rectangle", screenWidth, 10) --Ground		
		Level({0, 0}, "rectangle", screenWidth, 10) --Roof		
		Level({0, 0}, "rectangle", 10, screenHeight) --Left Wall		
		Level({screenWidth - 10, 0}, "rectangle", 10, screenHeight) --Right Wall
	elseif name == "Hot Footin' It" then
		level = {}
		level.name = name
		level.spawnerBallCount = 0
		level.playerBallCount = 10
		level.spawnPoints = {}
		level.timer = {}
		level.platformSpeed = 150
		level.gameType = "Hot Foot"
		level.platformConfigurations = {
									{1,1}, {1,1}, {1,0}, {0,1},
									{2,2}, {2,2}, {0,2}, {2,0},
									{2,2}, {2,2}, {1,2}, {2,1},
									{1,2}, {2,1}, {3, 1}, {1, 3}
									}		

		table.insert(level.spawnPoints, {["x"] = 10, ["y"] = 0, ["name"] = "Bottom Left"})		
		table.insert(level.spawnPoints, {["x"] = screenWidth - 20, ["y"] = 0, ["name"] = "Bottom Right"})

		--Level({0, screenHeight - 10}, "rectangle", screenWidth, 10) --Ground		
		--Level({0, 0}, "rectangle", screenWidth, 10) --Roof		
		Level({0, 0}, "rectangle", 10, screenHeight) --Left Wall		
		Level({screenWidth - 10, 0}, "rectangle", 10, screenHeight) --Right Wall

		Level({0, 70}, "rectangle", 50, 10) --P1 Diving Board (left)
		Level({screenWidth - 50, 70}, "rectangle", 50, 10) --P2 Diving Board (right)


		--Moving Platform that starts at bottom left and moves clockwise
		Level({screenWidth/2 - 400, screenHeight/2 + 350}, "movingRectangle", 80, 15, { {0, -600}, 
																					 {640, 0},
																				 	 {0, 600},
																				 	 {-640, 0},
																							 }, level.platformSpeed)
		--Moving Platform that starts at top left and moves in an clockwise
		Level({screenWidth/2 - 400, screenHeight - 740}, "movingRectangle", 80, 15, { {640, 0}, 
																					 {0, 600},
																				 	 {-640, 0},
																				 	 {0, -600},
																							 }, level.platformSpeed)
		--Moving Platform that starts at top right and moves in an clockwise
		Level({screenWidth/2 + 200, screenHeight - 740}, "movingRectangle", 80, 15, { {0, 600}, 
																					 {-640, 0},
																				 	 {0, -600},
																				 	 {640, 0},
																							 }, level.platformSpeed)
		--Moving Platform that starts at bottom right and moves in an clockwise
		Level({screenWidth/2 + 200, screenHeight/2 + 350}, "movingRectangle", 80, 15, { {-640, 0}, 
																					 {0, -600},
																				 	 {640, 0},
																				 	 {0, 600},
																							 }, level.platformSpeed)

		Level({10.40, screenHeight - 10}, "bouncyBox", screenWidth - 20, 10)
	end

	--Spawn players
	spawn_players()
end

function getSpawnPoint(name)
	for __, spawnpoint in ipairs(level.spawnPoints) do		
		if spawnpoint.name == name then			
			return spawnpoint.x, spawnpoint.y

		end
	end
end


changePlatformColors = function(self)
	local function determinePlatformMakeup()
		--If I haven't reached the end of the configuration list
		if level.currentPlatformConfiguration < #level.platformConfigurations then
			level.currentPlatformConfiguration = level.currentPlatformConfiguration + 1				
		else
			level.currentPlatformConfiguration = 1
		end

		return (level.platformConfigurations[level.currentPlatformConfiguration])	
	end

	local function setPlatforms(makeup)
		debugger:insert("Config: " .. tostring(makeup[1]) .. "," .. tostring(makeup[2]))
		local function resetPlatforms()
			for __, platform in ipairs(current_level) do
				if platform.type == "movingRectangle" then
					platform.color = color.white
				end
			end
		end

		--Recursive function that finds unused platforms to give color
		local function findUnusedPlatforms(platformsLeftToActivate, playerNumber, platformsToUse)				
			local platformsLeft = platformsLeftToActivate
			local playerIndex = false
			local platformsToUse = platformsToUse
			local playerNumber = playerNumber			

			--Get the table reference pointer for the active player number passed in playernumber
			for __, player in ipairs(active_players) do				
				if player.playerNumber == playerNumber then					
					playerIndex = player
				end
			end				

			--Get a random number between 1 and the length of the passed active Platforms
			local randomNumber = ranNum:random(1, #platformsToUse)
			--Assign that platform a color
			platformsToUse[randomNumber].color = playerIndex.color
			--Remove the platform from the active list
			table.remove(platformsToUse, randomNumber)						
			
			--If there's at least 1 more platform left to assign to a player
			if (platformsLeft - 1) > 0 then
				--take away from the amount of platforms left and recursively run the function again				
				platformsLeft = platformsLeft - 1							
				findUnusedPlatforms(platformsLeft, playerNumber, platformsToUse)
				
			else
				return 0
			end
		end

		--Take the amount of colored platforms the chosen player should have
		player1Count = makeup[1]
		player2Count = makeup[2]
		local activePlatformTable = {}					

		--Insert the active platform references into a table
		for __, level in ipairs(current_level) do
			if level.type == "movingRectangle" then
				table.insert(activePlatformTable, level)				
			end
		end

		--Reset each platform to neutral
		resetPlatforms()
		if player1Count > 0 then
			findUnusedPlatforms(player1Count, "One", activePlatformTable)
		end

		if player2Count > 0 then
			findUnusedPlatforms(player2Count, "Two", activePlatformTable)
		end
	end

	--Create the currentPlatformConfiguration variable - hacky...ughs
	if not level.currentPlatformConfiguration then
		level.currentPlatformConfiguration = 0
	end
	
	--This will get the current configuration from the level.platformConfigurations table and dole out the color assignments
	--ex: {2, 1} would be 2 platforms for Player 1, 1 platform for player 2
	setPlatforms( determinePlatformMakeup() )

end
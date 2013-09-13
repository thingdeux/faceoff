Object = Class{
	init = function(self, coords, type_of_object)
		self.x = coords[1]
		self.y = coords[2]
		self.type = "object"
		self.type_of_object = type_of_object
		self.timer = {}		

		if self.type_of_object == "spawner" then
			self.isSpawner = true
			self.ammoLeft = 0
			self:setSpawnerAmmo()  --If no ammo amount is specified set it to 5
			self.spawnRate = 4
			self.timer.spawnTimer = 0

			if not active_spawners then
				active_spawners = {}
				table.insert(active_spawners, self)
			else
				table.insert(active_spawners, self)
			end	
		elseif self.type_of_object == "oil trap" then
			self.isSpawner = true
			self.ammoLeft = 0
			self:setSpawnerAmmo()
			self.spawnRate = 3
			self.timer.spawnTimer = 0
			
			if not active_spawners then
				active_spawners = {}
				table.insert(active_spawners, self)
			else
				table.insert(active_spawners, self)
			end

		elseif self.type_of_object == "oil" then
			local function createOilPoint(coords, size)
				local x = coords[1]
				local y = coords[2]
				local point = {}
				point.type = "oil"
				point.isOilBlob = true
				point.body = love.physics.newBody(world, x, y, "dynamic")
				if size then			
					point.shape = love.physics.newCircleShape(size)  --Ball shape has a radius of 3
				else
					point.shape = love.physics.newCircleShape(self.parameters.oilGranualSize)  --Ball shape has a radius of 3
				end
				point.pointerToSelf = self
				point.fixture = love.physics.newFixture(point.body, point.shape, 1)			
				point.fixture:setFilterData(-3, -3, 3)
				point.fixture:setRestitution(self.parameters.bounciness)
				point.fixture:setDensity(self.parameters.density)								
				point.fixture:setFriction(self.parameters.friction)
				point.fixture:setUserData( point )

				if not self.oilBlobPoints then
					self.oilBlobPoints = {}
					point.isFirstPoint = true
					table.insert(self.oilBlobPoints, point)
				else
					table.insert(self.oilBlobPoints, point)
				end
			end

			local function createOilJoints(blobPoints)
				if not self.oilJoints then
					self.oilJoints = {}
				end

				for pointNumber, point in ipairs(blobPoints) do

					if not point.isFirstPoint then
						local previousPoint = blobPoints[pointNumber - 1]
						local joint = love.physics.newDistanceJoint(point.body, previousPoint.body, point.body:getX(), point.body:getY(),
															                       previousPoint.body:getX(), previousPoint.body:getY(), true)
						joint:setDampingRatio(self.parameters.dampingRatio)
						joint:setFrequency(self.parameters.frequencyHz)
						joint:setLength(self.parameters.Length)

						--Insert the current joint into the oilJoints table
						table.insert(self.oilJoints, joint)
						
						--Create a joint back to the main blob
						local primePoint = blobPoints[1]
						local joint = love.physics.newDistanceJoint(point.body, primePoint.body, point.body:getX(), point.body:getY(),
															                       primePoint.body:getX(), primePoint.body:getY(), true)
						joint:setDampingRatio(self.parameters.dampingRatio)
						joint:setFrequency(self.parameters.frequencyHz)
						joint:setLength(self.parameters.Length)
						--Insert the current joint into the oilJoints table
						table.insert(self.oilJoints, joint)

						--If this is the final point in the pattern link it up to the first
						if pointNumber == #blobPoints then
							local primePoint = blobPoints[2]
							local joint = love.physics.newDistanceJoint(point.body, primePoint.body, point.body:getX(), point.body:getY(),
															                       primePoint.body:getX(), primePoint.body:getY(), false)
							joint:setDampingRatio(self.parameters.dampingRatio)
							joint:setFrequency(self.parameters.frequencyHz)
							joint:setLength(self.parameters.Length)
							
							--Insert the current joint into the oilJoints table
							table.insert(self.oilJoints, joint)
						end
						


						
					end				
				end
			
			end

			self.type = "oil"
			self.oilPattern = {
								{["x"] = self.x, ["y"] = self.y},

								{["x"] = self.x - 15, ["y"] = self.y - 10},								
								{["x"] = self.x - 18, ["y"] = self.y},
								{["x"] = self.x - 14, ["y"] = self.y + 10},		
								{["x"] = self.x - 5, ["y"] = self.y + 18},
								{["x"] = self.x + 7, ["y"] = self.y + 16},
								{["x"] = self.x + 16, ["y"] = self.y + 10},
								{["x"] = self.x + 17, ["y"] = self.y - 1},
								{["x"] = self.x + 12, ["y"] = self.y - 12},								
								{["x"] = self.x, ["y"] = self.y - 15},

								--{["x"] = self.x - 7, ["y"] = self.y - 7},
								--{["x"] = self.x - 8, ["y"] = self.y},
								--{["x"] = self.x - 3, ["y"] = self.y + 8},	
								--{["x"] = self.x + 3, ["y"] = self.y + 8},
								--{["x"] = self.x + 8, ["y"] = self.y},
								--{["x"] = self.x, ["y"] = self.y-6},

								
							  }	  

			self.parameters = {}
			self.parameters.density = 3
			self.parameters.dampingRatio = 1
			self.parameters.frequencyHz = 1  --.20
			self.parameters.Length = 8  --10
			self.parameters.bounciness = 0.2
			self.parameters.friction = 1 --.5
			self.parameters.oilGranualSize = 3  --.2.5
			
			--Create points for each x/y pair in the pattern
			for count, point in ipairs(self.oilPattern) do
				if count == 1 then
					createOilPoint({point.x, point.y}, 8) --8
				else
					createOilPoint({point.x, point.y})
				end
			end

			--for i=1,50 do
				--createOilPoint({self.x + (i*.65), self.y+ (i*.65)})
			--end

			--Join the points together into a distance joint
			createOilJoints(self.oilBlobPoints)				

			if not active_traps then
				active_traps = {}
				table.insert(active_traps, self)
			else
				table.insert(active_traps, self)
			end

			self.parameters = nil
		end

		table.insert(active_entities, self)


	end;



	setSpawnerAmmo = function(self, amount)		
		if not amount then
			self.ammoLeft = 5
		else
			self.ammoLeft = amount
		end	
	end;

	setSpawnRate = function(self, rate)
		if not rate then
			self.spawnRate = 3
		else
			self.spawnRate = rate
		end
	end;

	spawnBall = function(self)
		if self.ammoLeft > 0 then
			thisBall.body:applyLinearImpulse(0, 1)		
			local thisBall = Ball({self.x,self.y + 20})
			self.ammoLeft = self.ammoLeft - 1
		end
		
	end;

	spawnOil = function(self)
		if self.ammoLeft > 0 then
			local thisOil = Object({self.x, self.y + 30}, "oil")
			self.ammoLeft = self.ammoLeft - 1
		end
	end;

	leaveOilTrail = function(self, oilObject, collidedWith)
		local collisionSpotX = oilObject.body:getX()
		local collisionSpotY = oilObject.body:getY() + 2
		local collidedBody = collidedWith:getBody()
		local offsetX = collisionSpotX - collidedBody:getX()
		local offsetY = collisionSpotY - collidedBody:getY()	

		Decal({offsetX, offsetY}, collidedBody)
	end;
	
}

Object:include(Entity)


--[[   Joint notes:

Softness is achieved by tuning two constants in the definition: frequency and damping ratio. Think of the frequency as the frequency of a harmonic oscillator (like a guitar string). The frequency is specified in Hertz. Typically the frequency should be less than a half the frequency of the time step. So if you are using a 60Hz time step, the frequency of the distance joint should be less than 30Hz. The reason is related to the Nyquist frequency.

The damping ratio is non-dimensional and is typically between 0 and 1, but can be larger. At 1, the damping is critical (all oscillations should vanish).

jointDef.frequencyHz = 4.0f;

jointDef.dampingRatio = 0.5f;



]]--
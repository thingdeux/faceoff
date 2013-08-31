Object = Class{
	init = function(self, coords, type_of_object)
		self.x = coords[1]
		self.y = coords[2]
		self.type = "object"
		self.type_of_object = type_of_object
		self.timer = {}
		self.spawnRate = 4
		self.timer.spawnTimer = 0

		if self.type_of_object == "spawner" then
			self.ammoLeft = 0
			self:setSpawnerAmmo()  --If no ammo amount is specified set it to 5

			if not active_spawners then
				active_spawners = {}
				table.insert(active_spawners, self)
			else
				table.insert(active_spawners, self)
			end		
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
		end
	end;

	spawnBall = function(self)
		local thisBall = Ball({self.x,self.y + 20})
		thisBall.body:applyLinearImpulse(0, 1)		
	end;
	
}

Object:include(Entity)
Object = Class{
	init = function(self, coords, type_of_object)
		self.x = coords[1]
		self.y = coords[2]
		self.type = "object"
		self.type_of_object = type_of_object
		self.timer = {}
		self.spawnRate = 3
		self.timer.spawnTimer = 0

		if self.type_of_object == "spawner" then
			self.ammoLeft = 0
			self:setSpawnerAmmo()  --If no ammo amount is specified set it to 5
		end

		table.insert(active_entities, self)
	end;

	setSpawnerAmmo = function(self, amount)
		if not amount then
			self.ammoLeft = 5
		end
	end;

	setSpawnRate = function(self, rate)
		if not rate then
			self.spawnRate = 3
		end
	end;

	spawnBall = function(self)
		local thisBall = Ball({self.x,self.y + 20})
		thisBall.body:applyLinearImpulse(.5, 10)		
	end;
	
}

Object:include(Entity)
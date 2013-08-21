level = Class{
	init = function(self, coords, type_of_object, width, height)
		self.type_of_object = type_of_object
		
		if self.type_of_object == "rectangle" then
			self.width = width
			self.height = height
			self.x = coords[1] --Starting X point of the line
			self.y = coords[2] --Starting Y point of the line	
			
			--The shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)		
			self.body = love.physics.newBody(world, self.x + self.width/2, self.y + self.height/2, "static")
			--make a rectangle with a width of width and a height of height
			self.shape = love.physics.newRectangleShape(self.width, self.height)
			--attach shape to body (think, skeleton)
			self.fixture = love.physics.newFixture(self.body, self.shape)			
		elseif self.type_of_object == "edge" then
			self.x = coords[1]
			self.y = coords[2]
			self.x1 = coords[3]
			self.y1 = coords[4]
			self.body = love.physics.newBody(world, self.x, self.y - self.y)
			self.shape = love.physics.newEdgeShape(self.x, self.y, self.x1, self.y1)
			self.fixture = love.physics.newFixture(self.body, self.shape)						
			self.fixture:setFriction(0)
		end
		
		--This is gonna cause more processing but may be necessary if the collision is not accurate enough
		self.body:setBullet(false)
		--Set the level filter mask to 3 so level pieces won't collide with each other
		self.fixture:setFilterData(3, 3, -3)
		self.fixture:setUserData( self )

		if not current_level then
			current_level = {}
			table.insert(current_level, self)
		else
			table.insert(current_level, self)
		end	
	end;

	

}



function load_level(name)
	if name == "basic" then
		--Ground
		level({0, 758}, "rectangle", 1024, 10)
		--Roof
		level({0, 0}, "rectangle", 1024, 10)
		--Left Wall
		level({0, 0}, "rectangle", 10, 768)
		--Right Wall
		level({1014, 0}, "rectangle", 10, 768)

		--Sloped Platform bottom left
		level({0, 650, 150, 768}, "edge")

		--Sloped Platform bottom left
		level({520, 650, 350, 768}, "edge")


	end
end
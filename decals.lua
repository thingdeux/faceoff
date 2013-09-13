Decal = Class{
	init = function(self, coords, attachedBody)

		self.collisionOffset = {}
		self.collisionOffset.x = coords[1]
		self.collisionOffset.y = coords[2]
		self.attachedBody = attachedBody		
		self.type = "decal"
		self.isOil = true
		
		self.x = self.attachedBody:getX() + self.collisionOffset.x
		self.y = self.attachedBody:getY() + self.collisionOffset.x

		if not active_decals then
			active_decals = {}
			table.insert(active_decals, self)
		else
			table.insert(active_decals, self)
		end

		table.insert(active_entities, self)

	end;
}


Decal:include(Entity)
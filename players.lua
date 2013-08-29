Player = Class{
	init = function(self, coords, playerNumber)
		self.x = coords[1]
		self.y = coords[2]		

		self.orientation = 0
		self.playerNumber = playerNumber		
		self.maxSpeed = 400
		self.speed = 250
		self.jumpForce = 40
		self.friction = 6
		self.width = 35
		self.height = 75
		self.ballCount = 100
		self.weight = .1
		self.catchDuration = .3
		self.reflectDuration = .5
		
		--Status booleans
		self.isOnGround = false
		self.gravitiesPull = 1.8		
		self.isThrowing = false
		self.isCatching = false
		self.isReflecting = true
		self.isDead = false
		self.isFallingTooFast = false
		self.isTouching = {}
		self.isTouching.level = false
		self.isTouching.movingRectangle = false
		self.canThrow = true

		--Throw variables
		self.throwDelay = .3
		self.throwForce = {}		
		self.throwForce.speed = 100
		self.throwForce.angle = 0
		self.throwForce.speedModifier = 0

		--Cursor tracking variables
		self.cursor = {}
		self.cursor.x = 0
		self.cursor.y = 0
		self.cursor.speed = 200	
		self.cursor.angle = 0
		self.cursorAngle = 0		
		
		--Score trackers
		self.killCount = 0
		
		
		self.mouseTracker = {}
		self.mouseTracker.x = 0
		self.mouseTracker.y = 0

		self.thumbStickTracker = {}
		self.thumbStickTracker.x = 0
		self.thumbStickTracker.y = -50
		
		self.thumbStickTracker.current = {}		
		self.thumbStickTracker.current.x = 0
		self.thumbStickTracker.current.y = 0

		self.type = "player"
		self.timer = {}
		self.activeBall = nil

		self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		self.shape = love.physics.newRectangleShape(self.width, self.height)
		self.fixture = love.physics.newFixture(self.body, self.shape)

		--Set Fixture parameters
		self.fixture:setFilterData(2, 2, 4)
		self.fixture:setUserData( self )
		self.fixture:setDensity(self.weight)
		self.fixture:setFriction(self.friction)		
		self.fixture:setRestitution(0) --Ie: Bounciness
		
		--Set Body parameters
		self.body:resetMassData()
		self.body:setFixedRotation(true) --Players body won't rotate unless this is changed
		self.body:setGravityScale(self.gravitiesPull)
		
		

		
		

		if not active_players then
			active_players = {}
			table.insert(active_players, self)
		else
			table.insert(active_players, self)
		end

		table.insert(active_entities, self)

	end;

	--Handlers for Throwing the ball
	throw = function(self, dt)

		if self.isPullingBackToThrow then
			if not self.activeBall then
				
			else
				--Stop the ball from simulating while the player holds it in their hand				
				self.activeBall.body:setActive (false)							

				--Start 'charging' up the throw				
				if self.throwForce.current < (self.throwForce.max + self.throwForce.speedModifier) then
					self.throwForce.current = self.throwForce.current + self.throwForce.speed*dt
				end		
			end
			
		end
			
		--Throw the ball		
		if self.isThrowing and not self.timer.throwing then
			if not self.activeBall then
				--Spawn a ball and put it next to the player (in their hand)											
				self.activeBall = Ball({self.body:getX(), self.body:getY()})	

				--Set the ball to being owned by the current player
				self.activeBall.isOwned = true
				self.activeBall.owner = self
				self.activeBall.isDangerous = true				
				self.activeBall.fixture:setMask(2)
			
				--Find the angle at which the ball should be thrown (determined by cursor)
				local ballx, bally = self.activeBall.body:getPosition()
				self.throwForce.angle = math.angle(self.body:getX(), self.body:getY(), self.cursor.x, self.cursor.y)									
				self.activeBall.body:setPosition( ballx + math.sin(self.throwForce.angle), bally )
				self.activeBall.body:setPosition( ballx, bally + math.cos(self.throwForce.angle) )

				--Apply linear velocity to the ball - ie: make it SHOOT in a direction
				self.activeBall.body:applyLinearImpulse(math.sin(self.throwForce.angle)*(self.throwForce.speed+self.throwForce.speedModifier), math.cos(self.throwForce.angle)*(self.throwForce.speed+self.throwForce.speedModifier) )
				
				--Subtract ball from inventory
				self.ballCount = self.ballCount - 1

				--Set the throw delay timer
				self.timer.throwing = love.timer.getTime() + self.throwDelay
				--This timer keeps the ball from colliding with the thrower
				self.timer.recentlyThrownBall = love.timer.getTime() + .02
				--Prevent repeat throws
				self.canThrow = false


			end

		elseif self.isThrowing and self.timer.throwing then
			if love.timer.getTime() > self.timer.throwing then				
				self.isThrowing = false
				self.timer.throwing = nil				
				self.throwForce.current = 40
			end
		end
		
		--This keeps the ball from colliding with the thrower - 
		if self.timer.recentlyThrownBall then
			if love.timer.getTime() < self.timer.recentlyThrownBall then			
				self.activeBall.fixture:setMask(2)				
			else				
				self.activeBall.fixture:setMask(1)
				self.activeBall = nil
				self.timer.recentlyThrownBall = nil
			end
		end
	end;

	catch = function(self, dt)
		if self.isCatching and not self.timer.catching then
			self.timer.catching = love.timer.getTime() + gameSpeed*self.catchDuration
		elseif self.isCatching and love.timer.getTime() > self.timer.catching then
			self.isCatching = false
			self.timer.catching = nil
		end
	end;

	reflect = function(self, dt)
		if self.isReflecting and not self.timer.reflecting then
			self.timer.reflecting = love.timer.getTime() + gameSpeed*self.reflectDuration
		elseif self.isReflecting and love.timer.getTime() > self.timer.reflecting then
			self.isReflecting = false
			self.timer.reflecting = nil
		end
	end;



	pickupBall = function(self, ballObject)
		self.ballCount = self.ballCount + 1
		ballObject.isBeingHeld = true				
		ballObject.body:destroy()
		ballObject.fixture:destroy()
		ballObject.body:isActive(false)
		ballObject:destroyObject()
	end;

	trackMouse = function(self)
	    x, y = love.mouse.getPosition()
		self.mouseTracker.x = x					
		self.mouseTracker.y = y

		--Make sure the mouse doesn't move too far away from the player
		self:keepCursorNearPlayer(x,y, "mouse")	
	end;

	trackThumbStick = function(self, dt)
		self.thumbStickTracker.current.y = love.joystick.getAxis(1, 4)
		self.thumbStickTracker.current.x = love.joystick.getAxis(1, 5)
		
		if self.thumbStickTracker.current.x >= -0.4 and self.thumbStickTracker.current.x < 0.4 then
			self.thumbStickTracker.current.x = 0 --Stops things from happening if the stick has just barely been touched
		end

		if self.thumbStickTracker.current.y >= -0.3 and self.thumbStickTracker.current.y < 0.3 then
			self.thumbStickTracker.current.y = 0 --Stops things from happening if the stick has just barely been touched
		end		

		--X Plane movement for thumbstick tracking
		if self.thumbStickTracker.current.x > 0 and 
			not self:keepCursorNearPlayer(self.cursor.x + self.thumbStickTracker.x, self.body:getY(), "stick", dt) then
			self.thumbStickTracker.x = self.thumbStickTracker.x + self.cursor.speed*dt
		elseif self.thumbStickTracker.current.x < 0 and
			not self:keepCursorNearPlayer(self.cursor.x + self.thumbStickTracker.x, self.body:getY(), "stick", dt) then

			self.thumbStickTracker.x = self.thumbStickTracker.x - self.cursor.speed*dt
		end


		--Y movement for thumbstick tracking
		if  self.thumbStickTracker.current.y < 0 and not
			self:keepCursorNearPlayer(self.body:getX(), self.cursor.y + self.thumbStickTracker.y, "stick", dt) then

			self.thumbStickTracker.y = self.thumbStickTracker.y - self.cursor.speed*dt
		elseif self.thumbStickTracker.current.y > 0 and not
			self:keepCursorNearPlayer(self.body:getX(), self.cursor.y + self.thumbStickTracker.y, "stick", dt) then
			self.thumbStickTracker.y = self.thumbStickTracker.y + self.cursor.speed*dt
		end
		
				
	end;

	keepCursorNearPlayer = function(self, x, y, controlType, dt)

		if y >= self.body:getY() + 100 then
			if controlType == "mouse" then
				--If the passed mouse location is greater than Y + 100 set it back to Y + 100 so it goes no further
				love.mouse.setPosition(x, self.body:getY() + 100)
			elseif controlType == "stick" then				
				if self.thumbStickTracker.current.y > 0 then
					self.thumbStickTracker.y = self.thumbStickTracker.y					
					return true
				else
					return false
				end				
			end
		elseif y <= self.body:getY() - 100 then
			if controlType == "mouse" then
				--If the passed mouse location is greater than Y - 100 set it back to Y - 100 so it goes no further
				love.mouse.setPosition(x, self.body:getY() - 100)
			
			elseif controlType == "stick" then				
				if self.thumbStickTracker.current.y < 0 then
					self.thumbStickTracker.y = self.thumbStickTracker.y					
					return true
				else
					return false
				end

			end
		end

		if x <= self.body:getX() - 100 then
			if controlType == "mouse" then
				love.mouse.setPosition(self.body:getX() - 100, y)
			elseif controlType == "stick" then
				if self.thumbStickTracker.current.x < 0 then
					self.thumbStickTracker.y = self.thumbStickTracker.y					
					return true
				else
					return false
				end				
			end
		elseif x >= self.body:getX() + 100 then
			if controlType == "mouse" then
				love.mouse.setPosition(self.body:getX() + 100, y)
			elseif controlType == "stick" then
				if self.thumbStickTracker.current.x > 0 then
					self.thumbStickTracker.y = self.thumbStickTracker.y					
					return true
				else
					return false
				end
			end
		end
		
		--If the cursor tracker isn't pass the threshold.
		if controlType == "stick" then			
			return false
		end
	end;

	--Moves the 'invisible' aiming cursor (mouse or trackpad cursor) along with the characters velocity
	moveCursorWithPlayer = function(self, controlType, dt)
		if controlType == "Mouse" then
			x, y = self.body:getLinearVelocity()
									
			if x > 0 then
				love.mouse.setPosition(love.mouse.getX() + (x+30)*dt, love.mouse.getY() )
			elseif x < 0 then
				love.mouse.setPosition(love.mouse.getX() + (x+30)*dt, love.mouse.getY() )
			end

			if y > 0 then
				love.mouse.setPosition(love.mouse.getX(), love.mouse.getY() + (y+30)*dt)
			elseif y < 0 then
				love.mouse.setPosition(love.mouse.getX(), love.mouse.getY() + (y+30)*dt )
			end							
		end
	end;

	die = function(self)
		--Cut the gamespeed down and go into slow mo 
		gameSpeed = .3
		--Turn off the fixed rotation so the player will spin after they're hit
		--WEEEEEEEEEEEEEEEEEEEEE		
		self.body:setFixedRotation(false)
		self.fixture:setRestitution(.3)

		--Kill the player hit by a ball and set a 3 second timer until respawn
		self.timer.deathTimer = love.timer.getTime() + 3		

		self.isDead = true
	end;

}

Player:include(Entity)


function spawn_players(respawn)

	if not respawn then
		--Create Player 1	
		Player({getSpawnPoint("Bottom Left")}, "One")

		--If a joystick is enabled, two characters will spawn
		if checkForJoystick() == "One Joystick" then
			--Create Player 2
			Player({getSpawnPoint("Bottom Right")}, "Two")
			--debugger:insert("One Joystick Detected")		
		elseif checkForJoystick() == "Two Joystick" then
			--debugger:insert("Two Joysticks Detected")
		else
			debugger:insert("No Joysticks Detected")
		end
	else		
		--Delete all active balls
		for __, ball in ipairs(active_balls) do			
			ball.isBeingHeld = true
			ball.isOwned = false
			ball.owner = false
			ball.body:setActive(false)		
		end

		--Reset the spawners
		for __, spawner in ipairs(active_spawners) do
			spawner:setSpawnerAmmo(level.spawnerBallCount)
		end


		for __, player in pairs(active_players) do
			--Set the number of balls the players respawn with
			player.ballCount = 1

			--If a player has died reset some parameters and let THEM LIVE!
			if player.isDead then
				player.body:isActive(false)				
				player.isDead = false
				player.body:setFixedRotation(true)			
				player.body:setLinearDamping(0)
				player.body:setAngularVelocity(0)
				player.body:setLinearVelocity(0,0)
				player.fixture:setRestitution(0)														
				player.body:isActive(true)
			end

			--Spawn the players in their respective positions
			if player.playerNumber == "One" then
				player.body:setPosition(getSpawnPoint("Bottom Left"))								
			else
				player.body:setPosition(getSpawnPoint("Bottom Right"))				
			end

			--Give the player a lil' shove downwards so they fall after spawn
			player.body:applyLinearImpulse(0,1)
			
		end		

		gameSpeed = 1
		roundOver = false
	end

end
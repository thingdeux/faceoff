Player = Class{
	init = function(self, coords, playerNumber, ai)
		self.x = coords[1]
		self.y = coords[2]		

		self.orientation = 0
		self.playerNumber = playerNumber		
		self.maxSpeed = 400
		self.speed = 250
		self.jumpForce = -40
		self.friction = 6
		self.width = 35
		self.height = 75
		if level.playerBallCount then
			self.ballCount = level.playerBallCount
		else
			self.ballCount = 5
		end
		self.isAI = ai		
		self.weight = .1
		self.catchDuration = .3
		self.reflectDuration = .5
		self.jumpDelay = 1
		self.doubleJumpDelay = .1
		self.target = nil		
		self.objectsBlockingLineOfSight = {}
		self.objectsBlockingLineOfSight.level = false
		self.objectsBlockingLineOfSight.movingRectangle = false
		
		--Status booleans
		self.isOnGround = false
		self.gravitiesPull = 1.8	
		self.isThrowing = false
		self.isJumping = false
		self.isDoubleJumping = false
		self.isCatching = false
		self.isReflecting = false
		self.isDead = false
		self.isFallingTooFast = false
		self.isTouching = {}
		self.isTouching.level = false
		self.isTouching.movingRectangle = false
		self.canSeeEnemy = false
		
		--Created these to track repeated key holds
		self.canJump = true
		self.canThrow = true
		self.canDoubleJump = false

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
		self.cursor.angle = 0
		self.cursorAngle = 0
		--self.cursor.speed = 200
		
		--Score trackers
		self.killCount = 0				

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

	stopJumping = function(self)		
		self.isJumping = false
		self.canDoubleJump = false		
		self.isDoubleJumping = false
		self.timer.doubleJump = nil
	end;

	findThrowPath = function(self)	
		self.timer.pathFinderDelay = love.timer.getTime() + self.pathFinderDelay
		--Spawn a tracker ball
		local trackerBall = Ball({self.body:getX(), self.body:getY()}, true)
		--Set the ball to not collide with anything but the level mask
		trackerBall.fixture:setMask(2)		
		trackerBall.isBeingHeld = false

		--Set the ball to have no owner and not be dangerous
		trackerBall.isOwned = false
		trackerBall.owner = nil
		trackerBall.isDangerous = false	
		trackerBall.trackingOwner = self
		
		--Find the angle at which the ball should be thrown (determined by cursor)
		local ballx, bally = trackerBall.body:getPosition()
		self.throwForce.angle = math.angle(self.body:getX(), self.body:getY(), self.cursor.x, self.cursor.y)									
		trackerBall.body:setPosition( ballx + math.sin(self.throwForce.angle), bally )
		trackerBall.body:setPosition( ballx, bally + math.cos(self.throwForce.angle) )

		--Apply linear velocity to the ball - ie: make it SHOOT in a direction
		trackerBall.body:applyLinearImpulse(math.sin(self.throwForce.angle)*(self.throwForce.speed+self.throwForce.speedModifier), math.cos(self.throwForce.angle)*(self.throwForce.speed+self.throwForce.speedModifier) )
	end;

	determineThrowingAngle = function(self)
		local function findTarget()			
			for __, player in ipairs(active_players) do
				if player ~= self then					
					return (player)
				end
			end
		end

		local function aimAtEnemy()
			self.cursor.x = self.body:getX()
            self.cursor.y = self.body:getY()
             --Use math to ummm...magically point the cursor in the direction of the enemy -- Maaaaaaath
			local angle = math.angle(self.body:getX(), self.body:getY(), self.target.body:getX(), self.target.body:getY() - 40)
			self.cursor.x = self.cursor.x + math.sin(angle)*100
			self.cursor.y = self.cursor.y + math.cos(angle)* 100
			
		end

		local function checkLineOfSightToEnemy(target)
			if self.playerNumber == "One" then			
				world:rayCast(self.body:getX(), self.body:getY() - 30, target.body:getX(), target.body:getY() - 30, worldRayCastCallback)							
			end
		end

		--If I don't have a target acquire one
		if not self.target then			
			self.target = findTarget()			
		end

		--Check a constantly running raycast and see if an object is in between the players
		if self.target then
			checkLineOfSightToEnemy(self.target)
			if not self.objectsBlockingLineOfSight.level and not self.objectsBlockingLineOfSight.movingRectangle then
				self.canSeeEnemy = true
			else
				self.canSeeEnemy = false
			end
		end


		--If you can't see an enemy, aim straight ahead
		if not self.canSeeEnemy then
			self.cursor.x = self.body:getX() + 50
			self.cursor.y = self.body:getY() - 5								
		elseif self.canSeeEnemy and self.target then
			--If the player can see an enemy then aim at them						
			aimAtEnemy(self.target)
		end

	end;

	ai = function(self, velocity_x, velocity_y, playerNumber, dt)		
		if self.canSeeEnemy then
			if self.ballCount > 0 and not roundOver then		
				self.isThrowing = true
			end
		end
	end;


}

Player:include(Entity)


function spawn_players(respawn)

	if not respawn then
		--Create Player 1	
		Player({getSpawnPoint("Bottom Left")}, "One")
		
		--If a joystick is enabled, two characters will spawn
		if checkForJoystick() == "One Joystick" then
			Player({getSpawnPoint("Bottom Right")}, "Two")
			--Create Player 2
			--Player({getSpawnPoint("Bottom Right")}, "Two")
			--debugger:insert("One Joystick Detected")		
		elseif checkForJoystick() == "Two Joystick" then
			--debugger:insert("Two Joysticks Detected")
		else
			debugger:insert("No Joysticks Detected, AI Opponent")
			Player({getSpawnPoint("Bottom Right")}, "Two", true)
		end
	else		
		--Delete all active balls
		for __, ball in ipairs(active_balls) do			
			ball.isBeingHeld = true
			ball.isOwned = false
			ball.owner = false
			ball.body:setActive(false)		
		end

		if active_spawners then
			--Reset the spawners
			for __, spawner in ipairs(active_spawners) do
				spawner:setSpawnerAmmo(level.spawnerBallCount)
			end
		end


		for __, player in pairs(active_players) do
			--Set the number of balls the players respawn with
			if level.playerBallCount then
				player.ballCount = level.playerBallCount
			else
				player.ballCount = 5
			end

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

	roundOver = true
	timer:queueBoolean(1.5, "roundOver")
end

--This is the raycast "handler" or callback function for players
--It handles what happens with the invisible drawn lines between each player
--If there are no obstructions in the way it will set the 'canSeeEnemy' flag and start auto-targeting
function worldRayCastCallback(fixture, x, y, xn, yn, fraction)
	local hit = {}
	hit.fixture = fixture
	hit.x, hit.y = x,y
	hit.xn, hit.yn = xn, yn
	hit.fraction = fraction

	local fixtureObject = hit.fixture:getUserData()

	if fixtureObject.type == "level" then
		--If a level object is in the way, no need to continue raycasting, stop this check the player is blocked		
		for __, player in ipairs(active_players) do
			--Set both players BlockingLineofsight for levels to yes
			player.objectsBlockingLineOfSight.level = true			
		end

		return 0
	elseif fixtureObject.type == "movingRectangle" then

		--Set both players BlockingLineofsight for rectangles to yes
		for __, player in ipairs(active_players) do
			player.objectsBlockingLineOfSight.movingRectangle = true
		end
		return 0
	elseif fixtureObject.type == "player" then		
		for __, player in ipairs(active_players) do		
			player.objectsBlockingLineOfSight.level = false			
			player.objectsBlockingLineOfSight.movingRectangle = false
			player.canSeeEnemy = true
		end
		
		
	end

	return 1
end

AI = Class{	
	--The brain, will coordinate actions
	think = function(self, dt)
		
		--Analyze surroundings
		self:checkSurroundings(dt)

		--Strategize		
		self:studyPlayer(dt)
		self:referencePlayerKnowledge(dt)
		
		--React
		self:act(dt)
		
		--Move

		--self:debugTrackingValues()
		--ranNum:random(1,100) --Random number betwixt 1,100
	end;

	checkSurroundings = function(self)
		if self.target then
			local function determineIfTargetIsOnLeftOrRight(targetx, selfx)
				if targetx > selfx then
					return true
				else
					return false
				end
			end

			local function determineIfTargetIsOnMyLevel(targety, selfy)
				if selfy >= (targety - 10) and selfy <= (targety + 10) then
					return true
				else
					return false
				end
			end

			local function determineifTargetIsAboveOrBelow(targety, selfy)
				if selfy < (targety - 10) then
					return true
				elseif selfy > (targety + 10) then
					return false
				end
			end

			local function determineIfTargetIsCloseEnoughToAttack(distanceToPlayerX, distanceToPlayerY)
				--If target is within 700 pixels horizontally and 500 vertically
				if distanceToPlayerX <= 700 and distanceToPlayerY <= 500 then
					return true
				--If target is directly above or below and very close horizontally
				elseif distanceToPlayerX <= 50 and distanceToPlayerY <= 900 then
					return true
				else
					return false
				end
			end

			local targetx, targety = self.target.body:getPosition()
			local selfx, selfy = self.body:getPosition()		
				
			self.distanceToTarget.x = math.distOnePlane(self.body:getX(), targetx)
			self.distanceToTarget.y = math.distOnePlane(self.body:getY(), targety)
			self.targetOnTheRight = determineIfTargetIsOnLeftOrRight(targetx, selfx)			
			self.isBeneathTarget = determineifTargetIsAboveOrBelow(targety, selfy)
			self.isOnTargetsLevel = determineIfTargetIsOnMyLevel(targety, selfy)
			self.isCloseEnoughToAttack = determineIfTargetIsCloseEnoughToAttack(self.distanceToTarget.x, self.distanceToTarget.y)	
		end
	end;

	referencePlayerKnowledge = function(self)
	end;

	studyPlayer = function(self)
		--Used to keep track of booleans and see when they change (see usage below) - used for tracking isJumping and isReflecting ... etc
		local function tallyAction(boolean, timer)
			if boolean and not timer then				
				return 1
			else
				return 0				
			end
		end

		--Track how long it takes for the target to throw a ball at me even though he's locked on
		local function trackTargetThrowingDelay(target)
			if not target.isThrowing and not target.timer.throwing then

				--Start tallying time when target can see player
				if target.canSeeTarget then
					self.playerStudy.timeTargetLockedOnNotThrowing = self.playerStudy.timeTargetLockedOnNotThrowing + love.timer.getDelta()
				end
			else
				--Place the current time it took for a player to throw into the tracking table
				if self.playerStudy.timeTargetLockedOnNotThrowing > 0 then
					table.insert(self.playerStudy.timesUntilTargetThrowsAfterLockOn, self.playerStudy.timeTargetLockedOnNotThrowing )					
				end

				--Reset tracker
				self.playerStudy.timeTargetLockedOnNotThrowing = 0
			end	
		end
		--Calculate the targets average throw time
		local function calculateAverageLockOnThrowingTime()
			local sum, count = 0, #self.playerStudy.timesUntilTargetThrowsAfterLockOn			
			for __, number in pairs(self.playerStudy.timesUntilTargetThrowsAfterLockOn) do
				--Go through the table and add each number to the sum variable
				sum = sum + number				
			end

			--Return the average of the times found in the tracker table.
			return (sum / count)
		end
		--Track the angle (above or below the AI) the target throws the ball from
		local function trackTargetThrowingAngle(target)
			if target.isThrowing and not target.timer.throwing then
				if self.isBeneathTarget == true then					
					self.playerStudy.angle.below = self.playerStudy.angle.below + 1
				elseif self.isBeneathTarget == false then					
					self.playerStudy.angle.above = self.playerStudy.angle.above + 1
				elseif self.isOnTargetsLevel then					
					self.playerStudy.angle.level = self.playerStudy.angle.level + 1
				end
			end
		end
		--Track success or failure of catches/reflects
		local function trackTargetSuccessFailureRate(target)
			--Turn off the caught and reflected flags (for use with ai counting) --*SIGH* SUPER HACKY
			if target.caught then
				self.playerStudy.catches.succesful = self.playerStudy.catches.succesful + 1				
				self.target.caught = false
			elseif target.reflected then
				self.playerStudy.reflects.succesful = self.playerStudy.reflects.succesful + 1				
				self.target.reflected = false
			end

			--Calculate the failure count
			self.playerStudy.catches.failed = self.playerStudy.catches.count - self.playerStudy.catches.succesful
			self.playerStudy.reflects.failed = self.playerStudy.reflects.count - self.playerStudy.reflects.succesful
		end

		trackTargetThrowingDelay(self.target)
		trackTargetThrowingAngle(self.target)
		trackTargetSuccessFailureRate(self.target)
		--Calculate the average time it takes the player to throw a ball at me when he is locked on.
		self.playerStudy.averageTimeUntilTargetThrows = calculateAverageLockOnThrowingTime()			
		self.playerStudy.jumps = self.playerStudy.jumps + tallyAction(self.target.isJumping, self.target.timer.jumping)
		self.playerStudy.reflects.count = self.playerStudy.reflects.count + tallyAction(self.target.isReflecting, self.target.timer.reflecting)
		self.playerStudy.catches.count = self.playerStudy.catches.count + tallyAction(self.target.isCatching, self.target.timer.catching)							
	end;

	gaugeSuccess = function(self)
	end;

	move = function(self, direction)
	end;

	act = function(self, dt)		
		if self.canSeeTarget and self.isCloseEnoughToAttack then
			if self.ballCount > 0 and not roundOver then		
				self.isThrowing = true
			end
		end
	end;

	debugTrackingValues = function(self)
		--Display all of the AI's tracking variables
		for i, trackeditem in pairs(self.playerStudy) do
			if type(trackeditem) == "table" and i ~= "timesUntilTargetThrowsAfterLockOn" then
				for tablename, trackedtableitem in pairs(trackeditem) do
					debugger:keepUpdated(tostring(i) .. "." .. tostring(tablename), trackedtableitem)
				end
			else
				debugger:keepUpdated(tostring(i), trackeditem)
			end
		end
		-----------------------
	end;

	createAIVariables = function(self)
		--Seed the random number generator
		ranNum:randomseed( ranNum:random(1, 100000000000) )		
		--States
		self.reactionSpeed = 1
		self.reflectionSuccessChance = .4
		self.catchSuccessChange = .4
		self.canSeeBallSpawn = false
		self.isCloseEnoughToAttack = false
		self.isFeelingLucky = false
		self.isLowOnAmmo = false
		self.mood = {}		
		self.mood.isAggressive = false
		self.mood.isDefensive = false		

		--Trackers
		self.isBeneathTarget = false
		self.isOnTargetsLevel = false
		self.targetOnTheRight = false
		self.distanceToTarget = {}
		self.distanceToTarget.x = 0
		self.distanceToTarget.y = 0

		--Memory
		self.playerStudy = {}		
		self.playerStudy.timesUntilTargetThrowsAfterLockOn = {}  --Time player usually takes to throw after spotting me
		self.playerStudy.timeTargetLockedOnNotThrowing = 0
		self.playerStudy.averageTimeUntilTargetThrows = 0
		
		self.playerStudy.reflects = {}
		self.playerStudy.reflects.count = 0
		self.playerStudy.reflects.succesful = 0  --Players succesful reflects
		self.playerStudy.reflects.failed = 0  --Players failed reflects
		self.playerStudy.catches = {}
		self.playerStudy.catches.count = 0
		self.playerStudy.catches.succesful = 0  --Players succesful catches
		self.playerStudy.catches.failed = 0  --Players failed catches
		self.playerStudy.jumps = 0 --Player jumpiness tracker
		self.playerStudy.angle = {}
		self.playerStudy.angle.above = 0
		self.playerStudy.angle.below = 0
		self.playerStudy.angle.level = 0

		--Strategy Variables
		self.strategy = {}
		self.strategy.generalOffensive
		self.strategy.generalDefensive
		self.strategy.HighThrower
		self.strategy.LevelThrower
		self.strategy.LowThrower
		self.strategy.jumpy
		self.strategy.reflecting
		self.strategy.notACatcher
		self.strategy.notAReflector
		self.strategy.veryCatchy
		self.strategy.veryReflecty
	end;
}


--[[
aggresive:
	can I see anyone?
	    Yes: Are they relatively close enough to hit with a ball?
	        Yes: Throw a ball
	            Gauge success (F)
	            Strategize(F)
	        
	        No: Close Distance (F)
	    No:
	        Do I need ammo?
	        Yes: Can I see a ball pit?
	                Yes: Go to Ball Pit
	                No: Get to higher ground (F)
	        Close Distance(F)

defensive:
	can I see anyone?
	    Yes: Are they relatively close enough to hit with a ball?
	        Yes: Have they thrown a ball before or at ~2 seconds?
	        	Yes: Try to reflect(F)
	        		Gauge success (F)
	            	Strategize(F)
	        	No: Throw Ball
	            
	        
	        No: Close Distance (F)
	    No:
	        Do I need ammo?
	        Yes: Can I see a ball pit?
	                Yes: Go to Ball Pit
	                No: Get to higher ground (F)
	        Close Distance(F)

states:
	canSeeTarget
	canSeeBallSpawn
	isCloseEnoughToAttack
	isFeelingLucky
	isLowOnAmmo
	isAggresive	
	reactionSpeed
	reflectionSuccessChance
	catchSuccessChance


ballSpawnTracker
	ballSpawnPoints {x,y}


playerTracker:
	isBeneathPlayer
	isOnPlayersLevel
	isToTheRightOfPlayer
	distanceToPlayer{x,y}
	playerStudy
		typicalTimeToThrow
		blocksOften (Iterate on player Blocks)
			succesful (Iterates on succesful blocks)
			failed (Iterates on whiffed blocks)
		reflects (Iterates on player reflects)
			succesful (Iterates on succesful reflects)
			failed (Iterates on whiffed reflects)
		
		jumpsOften (Iterate on player jumps)




X < 700 - Close enough to throw
Y  < 400



playerStudy

timers:
	playerInRangeAndNotThrowing



If No Info
	Ammo good?
		Move Towards Player
			Good Range for more than half a sec?
				Throw
	(Learn)		TargetReflected?
				FastEnoughToCatch/Reflect?
					(Percentage chance increases with range)
					Chance for failure
					Reflect/Catch
					-or-
					Die


If info on target
	if veryJumpy and AnglesAboveOften
		gain distance for increasing reflect chance

	if levelOften and shortThrowTimeAverage
		Go defensive and try reflecting often

	if doesn't reflect or catch
		Bombard

	if catches often or reflects often
		go defensive and try juggling and mixup




strategy.generalOffensive
strategy.generalDefensive
strategy.HighThrower
strategy.LevelThrower
strategy.LowThrower
strategy.jumpy
strategy.reflecting
strategy.notACatcher
strategy.notAReflector
strategy.veryCatchy
strategy.veryReflecty


]]--


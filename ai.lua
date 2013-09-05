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
			self.isBeneathPlayer = determineifTargetIsAboveOrBelow(targety, selfy)
			self.isOnTargetsLevel = determineIfTargetIsOnMyLevel(targety, selfy)
			self.isCloseEnoughToAttack = determineIfTargetIsCloseEnoughToAttack(self.distanceToTarget.x, self.distanceToTarget.y)	
		end
	end;

	referencePlayerKnowledge = function(self)
	end;

	studyPlayer = function(self)		
		local function tallyAction(boolean, timer)
			if boolean and not timer then				
				return 1
			else
				return 0				
			end
		end

		self.playerStudy.jumps = self.playerStudy.jumps + tallyAction(self.target.isJumping, self.target.timer.jumping)
		self.playerStudy.reflects.count = self.playerStudy.reflects.count + tallyAction(self.target.isReflecting, self.target.timer.reflecting)
		self.playerStudy.catches.count = self.playerStudy.catches.count + tallyAction(self.target.isCatching, self.target.timer.catching)
	
		--Display all of the AI's tracking variables
		for i, trackeditem in pairs(self.playerStudy) do
			if type(trackeditem) == "table" then
				for tablename, trackedtableitem in pairs(trackeditem) do
					debugger:keepUpdated(tostring(i) .. "." .. tostring(tablename), trackedtableitem)
				end
			else
				debugger:keepUpdated(tostring(i), trackeditem)
			end
		end

	end;


	gaugeSuccess = function(self)
	end;



	act = function(self, dt)		
		if self.canSeeTarget and self.isCloseEnoughToAttack then
			if self.ballCount > 0 and not roundOver then		
				self.isThrowing = true
			end
		end
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
		self.isBeneathPlayer = false
		self.isOnTargetsLevel = false
		self.targetOnTheRight = false
		self.distanceToTarget = {}
		self.distanceToTarget.x = 0
		self.distanceToTarget.y = 0

		--Memory
		self.playerStudy = {}
		self.playerStudy.timeToThrow = 0  --Time player usually takes to throw after spotting me
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
	canSeePlayer
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





]]--


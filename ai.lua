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
	        	No: Throw Ball
	            Gauge success (F)
	            Strategize(F)
	        
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





timers:
	playerInRangeAndNotThrowing





]]--


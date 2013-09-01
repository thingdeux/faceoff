--Creates a timer class that will allow queueing up timers that fire off events

Timer = Class{
	init = function(self, time, boolean)
		
		if not active_timers then
			active_timers = {}
		end
	end;

	queueBoolean = function(self, time, pointer, value)
		self.queuedTime = love.timer.getTime() + time
		self.booleanPointer = pointer				
		table.insert(active_timers, self)
	end;

	update = function(self)
		for i, timer in ipairs(active_timers) do
			if timer.booleanPointer and timer.queuedTime then
				if love.timer.getTime() > timer.queuedTime then					
					_G[self.booleanPointer] = not _G[self.booleanPointer]
					table.remove(active_timers, i)
				end
			end
		end
	end;
}
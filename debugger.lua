Debugger = Class{
	init = function(self)			
		
		if not active_debugging_text then
			active_debugging_text = {}
		end

		if not updated_debugging_text then
			updated_debugging_text = {}
		end
		
	end;

	--Pops a message into a scrolling section of the screen
	insert = function(self, inserter)
		table.insert(active_debugging_text, inserter)		
	end;

	--Trims the message table if it gets too long
	update = function(self, dt)
		if #active_debugging_text > 20 then
			table.remove(active_debugging_text, 1)
		end
	end;

	--Keep a stationary position on the screen updated with a variable
	keepUpdated = function(self, label, inserter)		
		updated_debugging_text[label] = inserter
	end;


}
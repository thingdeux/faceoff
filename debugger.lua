Debugger = Class{
	init = function(self)				
		
		if not active_debugging_text then
			active_debugging_text = {}
		end
		
	end;

	insert = function(self, inserter)
		table.insert(active_debugging_text, inserter)		
	end;

	update = function(self, dt)
		if #active_debugging_text > 20 then
			table.remove(active_debugging_text, 1)
		end
	end;


}
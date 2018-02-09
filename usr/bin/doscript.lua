 --[[
doscript.lua opens a file and feeds the contents into the act language interpreter.

Actions:
	- Gets the arguments
	- Confirms that there is only one argument. Otherwise returns "Expected only one argument, the name of the file to run. Recieved n arguments."
	- Looks for the file. If the argument is "dig" then doscript looks for a file named "dig" or "dig.act" in the current directory, home directory, or library path. If no file with correct name returns the names it was looking for and a list of where it looked.
	- Reads the contents of the file. 
	- Closes the file.
	- Opens (requires) act.
	- calls act with the contents of the file.
 --]]


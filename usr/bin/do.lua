-- VERSION 2016.11.05 1835
-- command line interfact to act api
-- you will need the act script
--print("Starting do.")
a=require( "act-oc" )
--print("past require.")
local tArgs = { ... }
if #tArgs < 1 then
    print( "Usage: do <list of commands>" )
	-- return
end
-- os.loadAPI("act-oc")
-- local act = require( "act-oc" )
--print(act)

local plan =  table.concat(tArgs) 
-- print("plan is: "..plan)
--print("Calling act.")
act(plan)
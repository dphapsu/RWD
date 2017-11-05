local component = require("component")
local sides = require("sides")
local robot = require( "robot" )
local sides = require( "sides" )
local gen = component.generator
local com = component.computer
local geo = component.geolyzer
local incon = component.inventory_controller


 
local slot = 5
--[[local item = component.inventory_controller.getStackInInternalSlot(slot)
print("Printing ")
print(item)
 
if item then
	print("Item name: ", item.name)
	print("Item count: ", item.size)
	print("Item damage: ", item.damage)
else
	print("Slot " .. slot .. " is empty")
end --]]

--[[
robot.select(1)
robot.place(sides.up)
os.sleep(2)
robot.swing(sides.up) --]]

function whatBelow( )
	-- Returns the name of the block below the robot.
	local block
	local item = geo.analyze(0)
	block = item -- convertOres(item.name)
	return block
end

local below = whatBelow()
print(below.name)
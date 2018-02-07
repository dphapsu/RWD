local component = require("component")
local sides = require("sides")
local robot = require( "robot" )
local sides = require( "sides" )
local gen = component.generator
local com = component.computer
local geo = component.geolyzer
local incon = component.inventory_controller

dofile("/mnt/50e/dev/act-oc.lua")
local tBadOres = {	[1] = "minecraft:cobblestone",
					[2] = "minecraft:gravel",
					[3] = "minecraft:sand",
					[4] = "minecraft:lava",
					[5] = "minecraft:stone",
					[6] = "minecraft:bedrock",
					[7] = "minecraft:water",
					[8] = "minecraft:dirt",
					[9] = "minecraft:sandstone"}

local tSoftSpace = {	[1] = "minecraft:water",
						[2] = "minecraft:air",
						[3] = "minecraft:lava"}


function convertOres( block )
	--print("convertOres is called with ",block)
	local newBlock
	newBlock = block
	if block == "minecraft:stone" then newBlock = "minecraft:cobblestone" end
	--print("convertOres is returning with ",newBlock)
	return newBlock
end

function whatBelow( )
	-- Returns the name of the block below the robot.
	local block
	local item = geo.analyze(0)
	block = convertOres(item.name)
	print("whatBelow is returning ",block)
	return block
end


function whatAhead()
	-- Returns the name of the block in front of the robot.
	local block
	local item = geo.analyze(3)
	block = convertOres(item.name)
	return block
end

function whatAbove()
	--Returns the name of the block above the robot.
	local block
	local item = geo.analyze(1)
	block = convertOres(item.name)
	return block
end


function isValuable( block )
	-- Returns true if block is not in Bad Ores table.
	local result = true
	for _ in pairs(tBadOres) do
		if (block == tBadOres[_]) then
			result = false
		end
	end
	return result
end

function manageStorage( block )
	-- Makes sure there is storage space available for the block. 
	-- If there is no storage then empty inventory into ender chest.
	-- ender chest goes in slot 1
	-- coal goes into slot 2
	local i
	local blockAbove, stack, stackName, stackSize, item
	-- see if there is a slot with space for that block or an empty slot.
	-- print( "Entering manageStorage" )
	--print("manageStorage is called with ",block) os.sleep(2)
	for i = 3,16 do
		 item = component.inventory_controller.getStackInInternalSlot(i)
		 if not item then
		 	 --print("Stack is empty")
		 	robot.select(i)
		 	return true
		 elseif item then
		 stackName = item.name
		 --print("stackName is ",stackName) os.sleep(0.5)
		 stackSize = item.size
		 -- print("stackName " , stackName , " stackSize ", stackSize)
			 if stackName == block and stackSize < 64 then
			 	robot.select(i)
			 	return true
			 end
		end
	end -- for
	-- OK, so no available slots for it to go into so ...
	-- Deploy ender chest.
	print("Deploy ender chest")
	while robot.detectUp() do
		--print("swinging")
		robot.swingUp()
	end -- while
	-- Transfer inventory into enderchest.
	-- TODO - Implement getting size of inventory.
	--print("selecting 1")
	robot.select(1)
	--print("Trying to place chest")
	robot.placeUp()
	for i = 3,16 do
		robot.select(i)
		robot.dropUp(64)
		print("Emptying slot ",i)
	end
	-- And recover ender chest.
	robot.select(1)
	robot.swingUp()
	robot.select(3)
end

 

function manageEnergy( ... )
	-- body
end

function mineShaft( ... )
	local depth = 0
	local i, block
	while (whatBelow() ~= "minecraft:bedrock") do
		block = whatBelow()
		manageStorage(block)
		tryDown()
		depth = depth + 1
		---[[
		for i = 1, 4 do
			block = whatAhead()
			if isValuable(block) then
				manageStorage(block) 
				robot.swing()
			end -- if
			robot.turnRight()
		end -- for ]]
		manageEnergy()
	end -- while
	for i = 1, depth do
		tryUp()
	end
end

function excavateChunk(...)

end

mineShaft()
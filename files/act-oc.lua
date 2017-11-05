-- VERSION 2016.11.05 1835
-- TODO
--   history
--   save
--   actor (rednet)
--   blueprints
--   relative coords/facing
--   return home
--   infinite loop
--   waypoints
-- mini language for making scripts smaller
-- and doing ad-hoc commands faster
--
-- look down in the handlers for all the commands
-- you can put a number afterwards to repeat a single command
-- you can put parenthesis around a list and a number after that to repeat several commands
-- detect and compare will break out of parethesis
--
-- examples:
--   Chop down tree to a max height of 48
--
--   Dff(?uDuu)48d48
--
--   Here is how the commands are interpreted
--
--   Df   - robot.dig()
--   f    - robot.forward()
--   (    - for i = 1, 48 do
--     ?u -   if not robot.detectUp() then break end
--     Du -   robot.digUp()
--     u  -   robot.up()
--   ) 48 - end
--   d 48 - for i = 1, 48 do robot.down() end
--
-- You can use the language in other scripts like so
--
-- os.loadAPI("act")
-- act.act("f5rrf5ll")

-- act internal functions
-- print("Starting act-oc")
--[[
function dump(o)
   if type(o) == 'table' then
      --print("Entering first if.")
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      -- print("Entering else.")
      -- print(tostring(o) .. " is not a table.")
      return tostring(o)
   end
end
]]--
local inspect = require("inspect")

local robot = require( "robot" )
local computer = require( "computer" )
local component = require("component")
local g
if component.isAvailable("generator") then
  g = component.generator
  -- print("Line 62")
end
-- print("Line 67: " .. tostring(g)
-- inspect(g)


local forward = 0
local up = 1
local down = 2
local tMove = {[forward] = robot.forward,
               [up] = robot.up,
               [down] = robot.down}
local tDetect = {[forward] = robot.detect,
                 [up] = robot.detectUp,
                 [down] = robot.detectDown}
local tAttack = {[forward] = robot.attack,
                 [up] = robot.attackUp,
                 [down] = robot.attackDown}
local tDig = {[forward] = robot.swing,
              [up] = robot.swingUp,
              [down] = robot.swingDown}
local tPlace = {[forward] = robot.place,
                [up] = robot.placeUp,
                [down] = robot.placeDown}

local function tryDir(dir)
  while not tMove[dir]() do
    -- print("tMove[dir] is ",tMove[dir])
    if tDetect[dir]() then
      tDig[dir]()
      os.sleep(1)
    else
      tAttack[dir]()
    end
  end
  return true
end

-- act robot functions

function try()
  return tryDir(forward)
end

function tryUp()
  return tryDir(up)
end

function tryDown()
  return tryDir(down)
end

local currentSlot = 1
function select(slot)
  currentSlot = slot
  robot.select(slot)
  return true
end

local function findSimilar()
  for s = 1, 16 do
    if s ~= currentSlot then
      robot.select(s)
      if robot.compareTo(currentSlot) then
        robot.select(currentSlot)
        return s
      end
    end
  end
  robot.select(currentSlot)
  return nil
end

local function placeDir(dir)
  if robot.count(currentSlot) == 1 then
    local resupplySlot = findSimilar()
    if resupplySlot then
      if tPlace[dir]() then
        robot.select(resupplySlot)
        robot.transferTo(currentSlot, robot.getItemCount(resupplySlot))
        robot.select(currentSlot)
        return true
      else
        return false
      end
    else
      return tPlace[dir]()
    end
  else
    return tPlace[dir]()
  end
end

function place()
  return placeDir(forward)
end

function placeUp()
  return placeDir(up)
end

function placeDown()
  return placeDir(down)
end

-- This code was mostly copied from:
-- http://lua-users.org/wiki/SleepFunction
--[[
function sleep(n)  -- seconds
  -- print("sleep called is argument ",n)
  local clock = os.clock
  local t0 = clock()
  local z
  -- print("Function sleep argument ",n)
  if n == nil then 
    -- print("n is nil.")
    z = 1
  else
    -- print("n is ",n)
    z = n
  end
   print("Waiting ",n," seconds from ",clock())
  while clock() - t0 <= z do 
    os.queueEvent("clockWaitEvent")
    os.pullEvent()
  end
  -- print(t0,"    ",clock())
  return true
end
--]]
-- warning: clock can eventually wrap around for sufficiently large n
-- (whose value is platform dependent).  Even for n == 1, clock() - t0
-- might become negative on the second that clock wraps.

function rDig()
  -- print("rDig entered")
  -- print("robot.detect = ",robot.detect())
  while robot.detect() do
    robot.swing()
    os.sleep(0.4)
    -- print("robot.detect() is ",robot.detect())
  end
  return true
end

function rDigUp()
  -- print("rDig entered")
  -- print("robot.detect = ",robot.detect())
  while robot.detectUp() do
    robot.swingUp()
    os.sleep(0.4)
    -- print("robot.detect() is ",robot.detect())
  end
  return true
end
-- command handlers

function tmpFunc()
  -- print("Running placeholder function.")
  g.insert()
end

local tHandlers = {
    -- move
  ["f"] = robot.forward,
  ["b"] = robot.back,
  ["u"] = robot.up,
  ["d"] = robot.down,
  ["l"] = robot.turnLeft,
  ["r"] = robot.turnRight,
  -- others
  ["s"] = select,
  ["t"] = robot.transferTo,
  -- ["R"] = g.insert,
  ["R"] = g.insert,
  ["v"] = g.remove,
  -- dig
  ["Df"] = rDig,
  ["Du"] = rDigUp,
  ["Dd"] = robot.swingDown,
  -- attack
  ["Af"] = robot.swing,
  ["Au"] = robot.swingUp,
  ["Ad"] = robot.swingDown,
  -- place
  ["Pf"] = place,
  ["Pu"] = placeUp,
  ["Pd"] = placeDown,
  -- suck
  ["Sf"] = robot.suck,
  ["Su"] = robot.suckUp,
  ["Sd"] = robot.suckDown,
  -- drop (E for eject)
  ["Ef"] = robot.drop,
  ["Eu"] = robot.dropUp,
  ["Ed"] = robot.dropDown,
  -- try, dig routing with anti-gravel/sand and anti-mob logic
  ["Tf"] = try,
  ["Tu"] = tryUp,
  ["Td"] = tryDown,
  -- detect
  ["?f"] = robot.detect,
  ["?u"] = robot.detectUp,
  ["?d"] = robot.detectDown,
  -- compare
  ["=f"] = robot.compare,
  ["=u"] = robot.compareUp,
  ["=d"] = robot.compareDown,
  ["=="] = robot.compareTo,

  ["Z"] = os.sleep
}

function getNumber(s, pos, max, default)
  if tonumber(s:sub(pos + 1, pos + 1)) == nil then
    return default, pos
  else
    local n = 0
    while pos <= max and tonumber(s:sub(pos + 1, pos + 1)) ~= nil do
      pos = pos + 1
      n = n * 10 + tonumber(s:sub(pos, pos))
    end
    return n, pos
  end
end

-- print("Reading in")


function act(plan)
  local pos = 1
  local max = plan:len()
  while pos <= max do
    local c = plan:sub(pos, pos)
    -- Begin handling sub plan.
    if c == "(" then
      -- read until matching )
      local p = 1
      local sub_plan = ""
      while p > 0 do
        pos = pos + 1
        if plan:sub(pos, pos) == ")" then
          p = p - 1
        elseif plan:sub(pos, pos) == "(" then
          p = p + 1
        end
        if p > 0 then
          sub_plan = sub_plan .. plan:sub(pos, pos)
        end
      end
      -- get optional count
      local n = nil
      n, pos = getNumber(plan, pos, max, 1)
      -- call recursively
      for i = 1, n, 1 do
        if not act(sub_plan, n) then
          print("sub plan failure")
          return false
        end
      end
      -- End handling sub plan.
    else
      -- Begin getting 2 character commands
      if c == "D"
        or c == "A"
        or c == "P"
        or c == "S"
        or c == "E"
        or c == "T"
        or c == "?"
        or c == "=" then
        pos = pos + 1
        c = c .. plan:sub(pos, pos)
      end
      -- End getting 2 character commands.

      -- call handler
      local fn = tHandlers[c]
      local tmp = tHandlers[c]
      -- print("Call "..c.." is handled by: ")
-- print("c is ",c)
-- print( "fn is ",fn )
      -- Get optional following number for commands that can use one.
      if fn then
        -- print( "if at line 348" )
        if c == "f" or c == "b" or c == "u" or c == "d" or c == "l" or c == "r" or c == "Tf" or c == "Td" or c == "Tu" then
          -- move handlers, number defines iterations
          -- get optional count
          local n = nil
          n, pos = getNumber(plan, pos, max, 1)
          for i = 1, n, 1 do
             -- print("Calling fn with c= ",c)
             -- print("fn = ",fn)
            if not fn() then
              if computer.energy() == 0 then
                print("Out of fuel")
                return false -- stop entire plan
              else
                print("Blocked: " .. plan:sub(1, pos) .. " / " .. plan:sub(pos + 1))
                return false -- stop entire plan
              end
            end
          end
          -- End getting optional following number.
          
          -- Begin evaluating comparison commands.
        elseif c:sub(1,1) == "?" or c:sub(1,1) == "=" then
          --print( "if at line 371" )
          -- detect and compare, failure will only skip out of the current block
          local result = nil
          if c == "==" then
            local n = nil
            n, pos = getNumber(plan, pos, max, 1)
            result = fn(n)
          else
            result = fn()
          end
          if not result then
            return true -- stop current plan
          end
          -- End handling comparison commands.


        else
          --print( "else at line 388" )


          -- all other handlers, number gets passed to function
          local n = nil
          n, pos = getNumber(plan, pos, max)

          -- Check to see if there is a handler for that command.
          -- print("fn is ",fn)
          -- print("fn(n) is ",fn(n))
          if not fn(n) then
            print("Can't perform action: " .. c)
            -- return false
          end
        end

      else
        -- If there is no handler for the command then you end up here.
        print("Unknown command: " .. c)
        return false
      end
    end
    pos = pos + 1
  end
  return true
end
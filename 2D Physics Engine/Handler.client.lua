local Point = require(script.Point)
local Segment = require(script.Segment)

local pinned = nil;
local points = {}
local segments = {}

local height = workspace.CurrentCamera.ViewportSize.Y
local width = workspace.CurrentCamera.ViewportSize.X

local UIS = game:GetService("UserInputService")

local boxes = 4
local id = 0

function addPoint(posX, posY)
	local newPoint = Point.new(posX, posY, id)
	table.insert(points, newPoint)
	
	id+=1
	
	return newPoint
end

function addSegment(p1, p2, visible, name)
	local newSegment = Segment.new(p1, p2, visible, name)
	table.insert(segments, newSegment)

	return newSegment
end

function Setup()
	for i = 1, boxes do 
		local topleft = addPoint(width/2-30, height/2)
		local topright = addPoint(width/2+30, height/2)
		local bottomleft = addPoint(width/2-30, height/2+60)
		local bottomright = addPoint(width/2+30, height/2+60)

		addSegment(topleft, topright, true, "top")
		addSegment(topleft, bottomleft, true, "left");
		addSegment(topright, bottomright, true, "right");
		addSegment(bottomleft, bottomright, true, "bottom");
		addSegment(topleft, bottomright, false);
		addSegment(topright, bottomleft, false);

		topleft.oldPos += Vector2.new(math.random(-20, 20), math.random(-20, 20));			
	end
	
	--local one = addPoint(width/2, height/2)
	--local two = addPoint(width/2, height/2 + 60)
	--addSegment(one, two, true)
	
	
	-- triangles
	
	--local top = addPoint(width/2, height/2)
	--local left = addPoint(width/2 - 30, height/2 + 60)
	--local right = addPoint(width/2 + 30, height/2 + 60)
	
	--addSegment(top, left, true)
	--addSegment(top, right, true)
	--addSegment(left, right, true)
end

Setup()

function Draw(dt)
	for _, pt in ipairs(points) do
		pt:Simulate(segments, dt)
	end
	
	for timeStep = 1, 6 do 
		for _, segment in ipairs(segments) do
			segment:Simulate()
		end
	end
	
	for _, pt in ipairs(points) do
		pt:Draw()
	end
	
	for _, seg in ipairs(segments) do
		seg:Draw()
	end	
end

function mousePressed(mouse)
	for _, pt in ipairs(points) do
		if pt.pos and (pt.pos - mouse).magnitude < 10 then
			pinned = pt
			pt.snap = true
			break
		end
	end
end

function released()
	if pinned ~= nil then
		pinned.snap = false
		pinned = nil
	end
end

function dragged(mouse)	
	if pinned ~= nil then
		pinned.pos = mouse
	end
end

game:GetService("RunService").RenderStepped:Connect(Draw)

UIS.InputBegan:Connect(function(input)
	local mouse = UIS:GetMouseLocation()
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mousePressed(mouse)
	end
end)

UIS.InputChanged:Connect(function(input)
	local mouse = UIS:GetMouseLocation()

	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragged(mouse)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		released()
	end
end)

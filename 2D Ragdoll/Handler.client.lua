local Point = require(script.Point)
local Segment = require(script.Segment)

local pinned = nil;
local points = {}
local segments = {}

local height = workspace.CurrentCamera.ViewportSize.Y
local width = workspace.CurrentCamera.ViewportSize.X

--local head = game:GetService("ReplicatedStorage").Ellipse:Clone()
--head.Size = UDim2.new(0, 30, 0, 30)
--head.AnchorPoint = Vector2.new(.5, .8)
--head.ZIndex = 2
--head.Parent = script.Parent.Canvas

local topHead = nil 
local neck = nil

function addPoint(posX, posY)
	local newPoint = Point.new(posX, posY)
	table.insert(points, newPoint)
	
	return newPoint
end

function addSegment(p1, p2, visible)
	local newSegment = Segment.new(p1, p2, visible)
	table.insert(points, newSegment)

	return newSegment
end

function Setup()
	-- body
	
	local body1 = addPoint(width/2-10, height/2)
	local body2 = addPoint(width/2+10, height/2)
	local body3 = addPoint(width/2-10, height/2+40)
	local body4 = addPoint(width/2+10, height/2+40)
	local body5 = addPoint(width/2, height/2)
	
	neck = body2
	
	addSegment(body1, body2, true);
	addSegment(body1, body3, true);
	addSegment(body2, body4, true);
	addSegment(body3, body4, true);
	addSegment(body1, body4, false);
	addSegment(body2, body3, false);
	
	local head1 = addPoint(width/2-10, height/2-30);
	local head2 = addPoint(width/2+10, height/2-30);
	addSegment(head1, head2, true);
	addSegment(body1, head1, true);
	addSegment(body2, head2, true);
	addSegment(body2, head1, false);
	addSegment(body1, head2, false)
	
	-- left arm
	
	local leftElbow = addPoint(width/2-45, height/2+5);
	local leftHand = addPoint(width/2-70, height/2+20);

	addSegment(body1, leftElbow, true);
	addSegment(leftElbow, leftHand, true);
	
	-- right arm
	
	local rightElbow = addPoint(width/2+45, height/2+5);
	local rightHand = addPoint(width/2+70, height/2+20);
	addSegment(body2, rightElbow, true);
	addSegment(rightElbow, rightHand, true);
	
	-- left leg 
	
	local leftKnee = addPoint(width/2-25, height/2+80);
	local leftFoot = addPoint(width/2-20, height/2+130);
	addSegment(body3, leftKnee, true);
	addSegment(leftKnee, leftFoot, true);
	addSegment(body3, leftFoot, false);
	
	-- right leg
	
	local rightKnee = addPoint(width/2+25, height/2+80);
	local rightFoot = addPoint(width/2+20, height/2+130);
	addSegment(body4, rightKnee, true);
	addSegment(rightKnee, rightFoot, true);
	addSegment(body4, rightFoot, false);
	
	body1.oldPos += Vector2.new(0, 20);
end

Setup()

function Draw()
	for _, pt in ipairs(points) do
		pt:Simulate()
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
game:GetService("UserInputService").InputBegan:Connect(function(input)
	local mouse = game:GetService("UserInputService"):GetMouseLocation()
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mousePressed(mouse)
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	local mouse = game:GetService("UserInputService"):GetMouseLocation()

	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragged(mouse)
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		released()
	end
end)

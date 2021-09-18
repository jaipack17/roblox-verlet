local Point = require(script.Point)
local Segment = require(script.Segment)
local Body = require(script.Body)

local pinned = nil;
local points = {}
local segments = {}
local bodies = {}

local height = workspace.CurrentCamera.ViewportSize.Y
local width = workspace.CurrentCamera.ViewportSize.X

local UIS = game:GetService("UserInputService")

local boxes = 15
local triangles = 10
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
		local w = math.random(30, 60)
		
		local topleft = addPoint(width/2-30, height/2)
		local topright = addPoint(width/2+30, height/2)
		local bottomleft = addPoint(width/2-30, height/2+60)
		local bottomright = addPoint(width/2+30, height/2+60)

		local a = addSegment(topleft, topright, true, "top")
		local b = addSegment(topleft, bottomleft, true, "left");
		local c = addSegment(topright, bottomright, true, "right");
		local d = addSegment(bottomleft, bottomright, true, "bottom");
		addSegment(topleft, bottomright, false);
		addSegment(topright, bottomleft, false);

		--topleft.oldPos += Vector2.new(math.random(-20, 20), math.random(-20, 20));		
		
		local newBody = Body.new({ topleft, topright, bottomleft, bottomright }, { a, b, c, d }, id)
		bodies[#bodies + 1] = newBody		
		id+=1
	end

	 -- triangles
	
	for j = 1, triangles do 
		local top = addPoint(width/2, height/2)
		local left = addPoint(width/2 - 30, height/2 + 60)
		local right = addPoint(width/2 + 30, height/2 + 60)

		local a = addSegment(top, left, true)
		local b = addSegment(top, right, true)
		local c = addSegment(left, right, true)

		local newBody = Body.new({ top, right, left }, { a, b, c }, id)
		bodies[#bodies + 1] = newBody		
		id+=1
	end
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
	
	for _, b1 in ipairs(bodies) do 
		for _, b2 in ipairs(bodies) do 
			if b1.id ~= b2.id then 
				local run = b1:DetectCollision(b2)
				local isColliding = run[1]
				local CollisionInfo = run[2]
				
				if isColliding then 
					local CollisionVector = CollisionInfo.Normal * CollisionInfo.Depth;
					
					local E1 = CollisionInfo.E.point1;
					local E2 = CollisionInfo.E.point2;
					
					local t;
					if math.abs(E1.pos.x - E2.pos.x) > math.abs(E1.pos.y - E2.pos.y) then
						t = (CollisionInfo.V.pos.x - CollisionVector.x - E1.pos.x)/(E2.pos.x - E1.pos.x);
					else 
						t = (CollisionInfo.V.pos.y - CollisionVector.y - E1.pos.y)/(E2.pos.y - E1.pos.y);
					end
					
					local universalMass = 1
					
					local lambda = 1.0/(t*t+(1-t)*(1-t));
					local edgeMass = t*universalMass + (1-t)*universalMass; 
					local invCollisionMass = 1.0/(edgeMass + universalMass);

					local ratio1 = universalMass*invCollisionMass;
					local ratio2 = edgeMass*invCollisionMass;
					
					E1.pos -= CollisionVector * (( 1 - t )*lambda*ratio1)
					E2.pos -= CollisionVector * ((   t   )*lambda*ratio1)
					CollisionInfo.V.pos += CollisionVector * ratio2
				end	
			end
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

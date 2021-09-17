local Point = require(script.Point)
local Segment = require(script.Segment)

local points = {}
local segments = {}
local fabric = {}

local height = workspace.CurrentCamera.ViewportSize.Y
local width = workspace.CurrentCamera.ViewportSize.X

function Setup()
	-- stiff
	
	local interval = width/90
	
	for i = 2, interval - 1 do 
		local newPoint = Point.new(50 * i, 50)
		newPoint.snap = true 
		points[#points + 1] = newPoint
		
		if not fabric[1] then 
			fabric[1] = {}
		end
		
		fabric[1][i] = newPoint
		
		if points[i - 1] then 
			local newSegment = Segment.new(newPoint, points[i - 1], true, 2)
			table.insert(segments, newSegment)
		end
	end
	
	-- movable 
	
	local numHeight = 8
	local numWidth = interval
	
	for i = 2, numWidth - 1 do 
		for j = 2, numHeight - 1 do 
			local newPoint = Point.new(50 * i, 50 * j)
			newPoint.snap = false 
			points[#points + 1] = newPoint
			
			if not fabric[j] then 
				fabric[j] = {}
			end
			
			fabric[j][i] = newPoint
		end
	end	
	
	-- segments 
	
	for i = 1, #fabric do 
		for j = 1, #fabric[1] do 
			if j ~= 1 then 
				if fabric[i][j] and fabric[i][j - 1] then 
					local newSegment = Segment.new(fabric[i][j], fabric[i][j - 1], true, 2)
					table.insert(segments, newSegment)					
				end				

				if i ~= #fabric then 
					if fabric[i][j] and fabric[i + 1][j] then 
						local newSegment2 = Segment.new(fabric[i][j], fabric[i + 1][j], true, 2)
						table.insert(segments, newSegment2)
					end
				end
			end
		end
	end
end

Setup()

function Draw()
	-- wind 
	
	local x = math.random(2, #fabric[1])
	local y = math.random(2, #fabric)  

	fabric[y][x]:ApplyForce(Vector2.new(math.random(-2, 6), 0))
	
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

game:GetService("RunService").RenderStepped:Connect(Draw)


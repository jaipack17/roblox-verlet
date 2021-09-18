local Body = {}
Body.__index = Body 

function Body.new(vertices, edges, id) 	
	local self = setmetatable({
		vertices = vertices,
		edges = edges,
		vertexCount = #vertices,
		edgeCount = #edges,
		id = id,
		Center = Vector2.new(0, 0),
	}, Body)
	
	for _, edge in ipairs(edges) do
		edge.Parent = self
	end
	
	return self
end

function Body:ProjectToAxis(Axis, Min, Max, Type) 
	local DotP = Axis.x * self.vertices[1].pos.x + Axis.y * self.vertices[1].pos.y;

	Min, Max = DotP, DotP;

	for I = 2, self.vertexCount, 1 do
		DotP = Axis.x * self.vertices[I].pos.x + Axis.y * self.vertices[I].pos.y;

		Min = math.min(DotP, Min)
		Max = math.max(DotP, Max)
	end
	
	return Min, Max
end

local function IntervalDistance(minA, maxA, minB, maxB)
	if (minA < minB) then
		return minB - maxA;
	else 
		return minA - maxB;
	end
end

function Body:DetectCollision(body)
	self.Center = Vector2.new(0, 0)

	local minX = 10000.0;
	local minY = 10000.0;
	local maxX = -10000.0;
	local maxY = -10000.0;

	for i = 1, self.vertexCount, 1 do
		self.Center += self.vertices[ i ].pos

		minX = math.min( minX, self.vertices[ i ].pos.x );
		minY = math.min( minY, self.vertices[ i ].pos.y );
		maxX = math.max( maxX, self.vertices[ i ].pos.x );
		maxY = math.max( maxY, self.vertices[ i ].pos.y );
	end

	self.Center /= self.vertexCount;

	local B1 = self 
	local B2 = body 
	
	local MinLength = 10000.0; -- Initialize the length of the collision vector to a relatively large value
	local CollisionInfo = {
		Normal = nil,
		Depth = nil,
		E = nil,
		V = nil
	}
	
	for I = 1, B1.edgeCount + B2.edgeCount, 1 do
		local E;

		if I <= B1.edgeCount  then
			E = B1.edges[I];
		else
			E = B2.edges[I - B1.edgeCount];
		end

		-- Calculate the axis perpendicular to this edge and normalize it
		local Axis = Vector2.new(E.point1.pos.Y - E.point2.pos.Y, E.point2.pos.X - E.point1.pos.X).unit; 
		
		local MinA, MinB, MaxA, MaxB; -- Project both bodies onto the perpendicular axis
		MinA, MaxA = B1:ProjectToAxis(Axis, MinA, MaxA, "A");
		MinB, MaxB = B2:ProjectToAxis(Axis, MinB, MaxB, "B");

		-- Calculate the distance between the two intervals - see below
		local Distance = IntervalDistance(MinA, MaxA, MinB, MaxB);
		
		if Distance > 0 then -- If the intervals don't overlap, return, since there is no collision
			return { false, {} }; 
		elseif math.abs(Distance) < MinLength then
			MinLength = math.abs( Distance );

			CollisionInfo.Normal = Axis; -- Save collision information for later
			CollisionInfo.E = E
		end
	end
	
	CollisionInfo.Depth = MinLength;	
	
	if CollisionInfo.E.Parent ~= B2 then
		local Temp = B2;
		B2 = B1;
		B1 = Temp;
	end
	
	local xx = B1.Center.x - B2.Center.x;
	local yy = B1.Center.y - B2.Center.y;
	local mult = CollisionInfo.Normal.x * xx + CollisionInfo.Normal.y * yy;

	if mult < 0 then 
		CollisionInfo.Normal *= -1
	end	
	
	local SmallestD = 10000.0 
	
	for I = 1, B1.vertexCount, 1 do
		-- Measure the distance of the vertex from the line using the line equation
		xx = B1.vertices[I].pos.x - B2.Center.x;
		yy = B1.vertices[I].pos.y - B2.Center.y;
		local Distance = CollisionInfo.Normal.x * xx + CollisionInfo.Normal.y * yy;

		if Distance < SmallestD then
			SmallestD = Distance;
			CollisionInfo.V = B1.vertices[I];
		end
	end
	
	return { true, CollisionInfo }; -- There is no separating axis. Report a collision!
end


return Body

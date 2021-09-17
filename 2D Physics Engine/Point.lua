local Point = {}
Point.__index = Point

local height = workspace.CurrentCamera.ViewportSize.Y
local width = workspace.CurrentCamera.ViewportSize.X
local canvas = script.Parent.Parent.Canvas
local bounce = .8
local gravity = Vector2.new(0, .3)

function Point.new(posX, posY, id)
	local ellipse = game:GetService("ReplicatedStorage").Ellipse:Clone()
	ellipse.Parent = canvas
	
	local self = setmetatable({
		id = id;
		frame = ellipse,
		oldPos = Vector2.new(posX, posY),
		pos = Vector2.new(posX, posY),
		forces = Vector2.new(0, 0),
		snap = false,
	}, Point)
	
	return self 
end

function Point:ApplyForce(force)
	self.forces += force
end

function Point:Simulate(otherSegments, dt)
	self:Collide(otherSegments)

	if not self.snap then
		self:ApplyForce(gravity)

		local velocity = self.pos 
		velocity -= self.oldPos
		velocity += self.forces 
		
		local friction = .99
		velocity *= friction 
				
		self.oldPos = self.pos 
		self.pos += velocity
		self.forces *= 0		
	else
		self.oldPos = self.pos
	end
end

function Point:KeepInCanvas()
	local border = 10;
	local vx = self.pos.x - self.oldPos.x;
	local vy = self.pos.y - self.oldPos.y;
		
	if self.pos.y > height - border then
		self.pos = Vector2.new(self.pos.x, height - border) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y + vy * bounce)
	elseif self.pos.y < 0 + border then
		self.pos = Vector2.new(self.pos.x, 0 + border) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y - vy * bounce)
	end
	
	if self.pos.x < 0 + border then
		self.pos = Vector2.new(0 + border, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x + vx * bounce , self.oldPos.y)
	elseif self.pos.x > width - border then
		self.pos = Vector2.new(width - border, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x - vx * bounce , self.oldPos.y)
	end
end

function Point:Collide(segments)
	for _, segment in pairs(segments) do
		if segment.point1.id ~= self.id and segment.point2.id ~= self.id then
			local point = self.pos

			local a = segment.point1 
			local b = segment.point2 
						
			if ((a.pos - point).magnitude + (b.pos - point).magnitude) - (a.pos - b.pos).magnitude < 5 then 					
				local v0 = self.pos - self.oldPos
				local v1 = a.pos - a.oldPos 
				local v2 = b.pos - b.oldPos
				
				if (v0.x < v1.x and v0.y < v1.y) and (v0.x < v2.x and v0.y < v2.y) then 
					a.pos = a.oldPos - v1
					b.pos = b.oldPos - v2
				end		
				
				self.pos -= v0
			end
		end
	end
end

function Point:Draw()
	self.frame.Position = UDim2.new(0, self.pos.x, 0, self.pos.y)
	self:KeepInCanvas()
end

return Point

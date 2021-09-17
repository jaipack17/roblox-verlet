local Point = {}
Point.__index = Point


local height = workspace.CurrentCamera.ViewportSize.Y
local width = workspace.CurrentCamera.ViewportSize.X
local canvas = script.Parent.Parent.Canvas

function Point.new(posX, posY)
	local ellipse = game:GetService("ReplicatedStorage").Ellipse:Clone()
	ellipse.Parent = canvas
	
	local self = setmetatable({
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

function Point:Simulate()
	if not self.snap then
		local gravity = Vector2.new(0, .1)
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
		local bounce = .8
		self.pos = Vector2.new(self.pos.x, height - border) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y + vy * bounce)
	elseif self.pos.y < 0 + border then
		local bounce = .8
		self.pos = Vector2.new(self.pos.x, 0 + border) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y - vy * bounce)
	end
	
	if self.pos.x < 0 + border then
		local bounce = .8
		self.pos = Vector2.new(0 + border, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x + vx * bounce, self.oldPos.y)
	elseif self.pos.x > width - border then
		local bounce = .8
		self.pos = Vector2.new(width - border, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x - vx * bounce, self.oldPos.y)
	end
end

function Point:Draw(colliders)
	--self.frame.Position = UDim2.new(0, self.pos.x, 0, self.pos.y)
	
	self:KeepInCanvas()
end

return Point

local Segment = {}
Segment.__index = Segment

local line = require(script.Parent.Line)

function Segment.new(p1, p2, visible, th)
	local self = setmetatable({
		frame = line(0, 0, 0, 0, script.Parent.Parent.Canvas, 4),
		point1 = p1,
		point2 = p2,
		restLength = (p2.pos - p1.pos).magnitude,
		visible = visible,
		th = th or 7
	}, Segment)
	
	return self	
end

function Segment:Simulate()
	local currentLength = (self.point2.pos - self.point1.pos).magnitude
	local lengthDifference = self.restLength - currentLength
	local offsetPercent = (lengthDifference / currentLength) / 2
	
	local direction = self.point2.pos 
	direction -= self.point1.pos 
	direction *= offsetPercent
	
	if not self.point1.snap then
		self.point1.pos -= direction
	end
	
	if not self.point2.snap then
		self.point2.pos += direction
	end
end

function Segment:Draw()
	if self.visible then
		line(self.point1.pos.x, self.point1.pos.y, self.point2.pos.x, self.point2.pos.y, script.Parent.Parent.Canvas, self.th, self.frame)
	end
end

return Segment

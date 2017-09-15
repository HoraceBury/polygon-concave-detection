-- polygon concave detection

require("mathlib")

stage = display.getCurrentStage()

local text = display.newText{ text="- - -", x=display.contentCenterX, y=100, fontSize=24 }

lines = display.newGroup()
lines:insert(display.newGroup())

points = display.newGroup()

-- adds a dot
function tap(e)
	local dot = display.newCircle( points, e.x, e.y, 10 )
	
	-- removes a dot
	function dot:tap(e)
		dot:removeSelf()
		return true
	end
	dot:addEventListener("tap",dot)
	
	-- moves a dot
	function dot:touch(e)
		if (e.phase == "began") then
			e.target.hasFocus = true
			stage:setFocus(e.target)
			e.target.x, e.target.y = e.x, e.y
			return true
		elseif (e.target.hasFocus) then
			if (e.phase == "moved") then
				e.target.x, e.target.y = e.x, e.y
			else
				e.target.x, e.target.y = e.x, e.y
				e.target.hasFocus = false
				stage:setFocus(nil)
			end
			return true
		end
		return false
	end
	dot:addEventListener("touch",dot)
	
	return true
end
Runtime:addEventListener("tap",tap)

-- changes the colour of the point to indicate concave or convex (green is concave)
function updatePoint(a,b,c)
	if (isPointConcave(a,b,c)) then
		b.fill = {0,1,0}
	else
		b.fill = {1,0,0}
	end
end

function enterFrame()
	-- remove connecting lines
	lines[1]:removeSelf()
	lines:insert(display.newGroup())
	
	if (points.numChildren > 1) then
		-- render lines
		for i=1, points.numChildren-1 do
			local line = display.newLine(lines[1],points[i].x, points[i].y, points[i+1].x, points[i+1].y)
			line.strokeWidth = 2
			line.stroke = {0,0,1}
		end
	end
	
	if (points.numChildren > 2) then
		-- closing line
		local line = display.newLine(lines[1],points[1].x, points[1].y, points[points.numChildren].x, points[points.numChildren].y)
		line.strokeWidth = 2
		line.stroke = {0,0,1}
		
		-- test for concave
		for i=1, points.numChildren do
			if (i == 1) then
				updatePoint( points[points.numChildren],points[1],points[2] )
			elseif (i == points.numChildren) then
				updatePoint( points[points.numChildren-1],points[points.numChildren],points[1] )
			else
				updatePoint( points[i-1], points[i], points[i+1] )
			end
		end
	end
	
	-- is polygon concave?
	local isconcave = isPolygonConcave( points )
	if (isconcave == nil) then
		text.text = "- - -"
	elseif (isconcave) then
		text.text = "Concave"
	else
		text.text = "Convex"
	end
end
Runtime:addEventListener("enterFrame",enterFrame)

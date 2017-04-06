-- title:	TICuare
-- author:	Crutiatix
-- desc:	UI library for TIC-80 v0.4.0
-- script:	lua
-- input:	mouse

-- Based on Uare (c) 2015 Ulysse Ramage
-- Copyright (c) 2017 Crutiatix
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

ticuare = {name = "ticuare", elements = {}, z = 1, hz = nil}
ticuare.__index = ticuare

-- Private
local ticuareMt = {__index = ticuare}
--local abs, min, max = math.abs, math.min, math.max

local function withinBounds(x, y, x1, y1, x2, y2)
	return x > x1 and x < x2 and y > y1 and y < y2
end

local function mergeTables(t1, t2, overwrite)
	for k,v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				mergeTables(t1[k] or {}, t2[k] or {}, overwrite)
			else
				if not t1[k] or overwrite then t1[k] = v end
			end
		else
			if not t1[k] or overwrite then t1[k] = v end
		end
	end
	return t1
end

local function copyTable(object)
	local lookup_table = {}
	local function _copy(object)
			if type(object) ~= "table" then
					return object
			elseif lookup_table[object] then
					return lookup_table[object]
			end
			local new_table = {}
			lookup_table[object] = new_table
			for index, value in pairs(object) do
					new_table[_copy(index)] = _copy(value)
			end
			return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

-- multiline print
function ticuare.mlPrint(txt,x,y,c,ls,fix,fnt,key,sw) -- string; x,y position; color; line spacing; fixed letters size; use font func?; key color; space size
	local sl = {}
	local width = 0
	local width_result = 0
	for l in txt:gmatch("([^\n]+)") do
		table.insert(sl,l)
	end
	for i, l in ipairs(sl) do
		if fnt then
			width = font(l,x,y+((i-1)*ls),key,sw)
		else
			width = print(l,x,y+((i-1)*ls),c,fix)
		end
		if width > width_result then width_result = width end
	end
	return width, #sl*ls
end
-- Public methods

function ticuare.element(t, f)

	if not f then f = t t = "element" end

	local ticuareObj = f
	setmetatable(ticuareObj, ticuare)

	ticuareObj.hover, ticuareObj.click = false, false
	ticuareObj.active = f.active or true
	ticuareObj.drag = f.drag or {enabled = false}
	ticuareObj.visible = f.visible or true


	if ticuareObj.content then
		if not ticuareObj.content.scroll then ticuareObj.content.scroll = {x = 0, y = 0} end
		ticuareObj.content.w, ticuareObj.content.h = ticuareObj.content.w or ticuareObj.w, ticuareObj.content.h or ticuareObj.h
	end

	ticuareObj.type, ticuareObj.z = t, ticuare.z
	ticuare.z = ticuare.z + 1 ticuare.hz = ticuare.z --index stuff
	table.insert(ticuare.elements, ticuareObj)
	return ticuareObj
end

function ticuare.newElement(f) return ticuare.element("element", f) end

function ticuare.newStyle(f) return f end

function ticuare.newGroup() local t = {type = "group", elements = {}} setmetatable(t, ticuare) return t end

--
-- Update
--

function ticuare:updateSelf(mx, my, mp, e)

	local mlc = e ~= "s" and mp or false

	local rwb = withinBounds(mx, my, self.x, self.y, self.x+self.w, self.y+self.h)
	if self.center then
		rwb = withinBounds(mx, my, self.x-self.w*.5, self.y-self.h*.5, self.x+self.w*.5, self.y+self.h*.5)
	end

	local wb = e ~= "s" and rwb or false

	local thover, thold = self.hover, self.hold

	self.hover = wb or (self.drag.enabled and ticuare.holdt and ticuare.holdt.obj == self)

	self.hold = ((e == "c" and wb) and true) or (mlc and self.hold) or ((wb and e ~= "r" and self.hold))

	if e == "c" and wb and self.onClick then --clicked
		self.onClick()
	elseif (e == "r" and wb and thold) and self.onCleanRelease then
		self.onCleanRelease()
	elseif ((e == "r" and wb and thold) or (self.hold and not wb)) and self.onRelease then --released (or mouse has left element, still holding temporarly)
		self.onRelease()
	elseif self.hold and self.onHold then --holding
		self.onHold()
	elseif not thover and self.hover and self.onStartHover then --started hovering
		self.onStartHover()
	elseif self.hover and self.onHover then --hovering
		self.onHover()
	elseif thover and not self.hover and self.onReleaseHover then --released hover
		self.onReleaseHover()
	end

	if self.hold and (not wb or self.drag.enabled) and not ticuare.holdt then
		self.hold = self.drag.enabled ticuare.holdt = {obj = self, d = {x = self.x-mx, y = self.y-my}}
	elseif not self.hold and wb and (ticuare.holdt and ticuare.holdt.obj == self) then
		self.hold = true ticuare.holdt = nil
	end

	if ticuare.holdt and ticuare.holdt.obj == self and self.drag.enabled then --drag
		self.x = (not self.drag.fixed or not self.drag.fixed[1]) and mx + ticuare.holdt.d.x or self.x
		self.y = (not self.drag.fixed or not self.drag.fixed[2]) and my + ticuare.holdt.d.y or self.y
		if self.drag.bounds then
			self.drag.bounds[1].x = self.drag.bounds[1].x or self.x
			self.drag.bounds[1].y = self.drag.bounds[1].y or self.y
			self.drag.bounds[2].x = self.drag.bounds[2].x or self.x
			self.drag.bounds[2].y = self.drag.bounds[2].y or self.y

			self.x = (self.drag.bounds[1].x and self.x < self.drag.bounds[1].x) and self.drag.bounds[1].x or self.x
			self.y = (self.drag.bounds[1].y and self.y < self.drag.bounds[1].y) and self.drag.bounds[1].y or self.y
			self.x = (self.drag.bounds[2].x and self.x > self.drag.bounds[2].x) and self.drag.bounds[2].x or self.x
			self.y = (self.drag.bounds[2].y and self.y > self.drag.bounds[2].y) and self.drag.bounds[2].y or self.y

		end
		if self.track then
			self:anchor(self.track.ref)
		end
	end

	return wb

end

function ticuare:updateTrack()
	if self.track then
		self.x, self.y = self.track.ref.x + self.track.d.x, self.track.ref.y + self.track.d.y
	end
end

--
-- Draw
--
function ticuare:drawSelf()

	if self.visible then
		local tempX, tempY = self.x, self.y
		if self.center then tempX, tempY = self.x-self.w*.5, self.y-self.h*.5 end

		if self.colors then
			local colorf = ((self.hold and self.colors[3]) and self.colors[3]) or ((self.hover and self.colors[2]) and self.colors[2]) or self.colors[1] or nil
			if colorf then rect(tempX, tempY, self.w, self.h, colorf) end
		end

		if self.border and self.border.colors and self.border.width then
			local colorb = ((self.hold and self.border.colors[3]) and self.border.colors[3]) or ((self.hover and self.border.colors[2]) and self.border.colors[2]) or self.border.colors[1] or nil
			if colorb then
				for b=0,self.border.width-1 do
					rectb(tempX+b, tempY+b, self.w-2*b, self.h-2*b, colorb)
				end
			end
		end

		if self.icon and self.icon.sprites and #self.icon.sprites > 0 then
			local sprite = ((self.hold and self.icon.sprites[3]) and self.icon.sprites[3]) or ((self.hover and self.icon.sprites[2]) and self.icon.sprites[2]) or self.icon.sprites[1]
			local offset = self.icon.offset or {x=0,y=0}

			self.icon.key = self.icon.key or -1
			self.icon.scale = self.icon.scale or 1
			self.icon.flip = self.icon.flip or 0
			self.icon.rotate = self.icon.rotate or 0
			self.icon.size = self.icon.size or 1
			for x=1,self.icon.size do
				for y=1,self.icon.size do
					spr(sprite+(x-1)+((y-1)*16),
						(tempX+(self.center and 0 or self.w*.5)+offset.x-4),
						(tempY+(self.center and 0 or self.h*.5)+offset.y-4),
						self.icon.key,
						self.icon.scale,
						self.icon.flip,
						self.icon.rotate)
			 	end
			end

		end

		if self.text and self.text.display and self.text.colors[1] then
			self.text.colors[1] = self.text.colors[1] or 14
			self.text.space = self.text.space or 5
			self.text.key = self.text.key or -1
			self.text.spacing = self.text.spacing or (self.text.font and 8 or 6)
			self.text.fixed = self.text.fixed or false
			local fcolor
			if (self.hold and self.text.colors[3]) then fcolor = self.text.colors[3]
			elseif (self.hover and self.text.colors[2]) then fcolor = self.text.colors[2]
			else fcolor = self.text.colors[1] end
			local offset = self.text.offset or {x = 0, y = 0}


			local wsize, hsize = ticuare.mlPrint(self.text.display,300,300, -1, self.text.spacing, self.text.fixed, self.text.font, self.text.key, self.text.space)
			ticuare.mlPrint(self.text.display,
				self.x-(self.center and (self.w*0.5) or 0)+(self.text.center and (self.w*.5)-(wsize*.5) or 0)+offset.x+(self.text.center and 0 or self.border.width),
				self.y-(self.center and (self.h*0.5) or 0)+(self.text.center and (self.h*.5)-(hsize*.5) or 0)+offset.y+(self.text.center and 0 or self.border.width),
				fcolor, self.text.spacing, self.text.fixed, self.text.font, self.text.key, self.text.space
			)
		end

		if self.content and self.drawContent then
			self:renderContent()
		end
	end
end

--
-- Content
--

function ticuare:renderContent()
	local tx, ty = self.x, self.y
	if self.center then tx, ty = self.x-self.w*.5, self.y-self.h*.5 end
	local border = self.border.width and self.border.width+1 or 1
	local offsetX = tx-(self.content.scroll.x or 0)*(self.content.w-self.w) + border
	local offsetY = ty-(self.content.scroll.y or 0)*(self.content.h-self.h) + border
	self.drawContent(self,offsetX,offsetY)


end

function ticuare:setContent(f)
	self.drawContent = f
end

function ticuare:setContentDimensions(w, h)
	if self.content then
		self.content.w, self.content.h = w, h
	end
end

function ticuare:setScroll(f)
	f.x = f.x or 0
	f.y = f.y or 0
	if self.content then
		f.x = (f.x < 0 and 0) or (f.x > 1 and 1) or f.x
		f.y = (f.y < 0 and 0) or (f.y > 1 and 1) or f.y
		self.content.scroll.x, self.content.scroll.y = f.x or self.content.scroll.x, f.y or self.content.scroll.y
	end
end

function ticuare:getScroll()
	if self.content then
		return { x = self.content.scroll.x, y = self.content.scroll.y }
	end
end

--
-- Miscellaneous
--

function ticuare.update(x, y, p)

	if x and y then

		local e, c = "n", p
		if ticuare.c and not c then
			ticuare.c = false e = "r" ticuare.holdt = nil
		elseif not ticuare.c and c then
			ticuare.c = true e = "c" ticuare.holdt = nil
		end
		--update every element/window first...
		local focused = false

		local updateQueue = {}

		for i = 1, #ticuare.elements do table.insert(updateQueue, ticuare.elements[i]) end

		table.sort(updateQueue, function(a, b) return a.z > b.z end)

		for i = 1, #updateQueue do
			local elemt = updateQueue[i]
			if elemt then
				if elemt:updateSelf(x, y, p,((focused or (ticuare.holdt and ticuare.holdt.obj ~= elemt)) or not elemt.active) and "s" or e) then
					focused = true
				end
			end
		end
		--...then update their anchors
		for i = #ticuare.elements, 1, -1 do
			if ticuare.elements[i] then
				ticuare.elements[i]:updateTrack()
			end
		end
	end
end

function ticuare.draw()

	local drawQueue = {}

	for i = 1, #ticuare.elements do if ticuare.elements[i].draw then table.insert(drawQueue, ticuare.elements[i]) end end

	table.sort(drawQueue, function(a, b) return a.z < b.z end)

	for i = 1, #drawQueue do drawQueue[i]:drawSelf() end
end

--
-- Methods
--

--Creation / Linking

function ticuare:style(style)
	if self.type == "group" then
		for i = 1, #self.elements do
			mergeTables(self.elements[i], copyTable(style), false)
		end
	else
		mergeTables(self, copyTable(style), false)
	end
	return self
end

function ticuare:anchor(other)
	if self.type == "group" then
		self.elements[1].track = {ref = other.elements[1], d = {x = self.x-other.elements[1].x, y = self.y-otherelements.other.y}}
	else
		self.track = {ref = other, d = {x = self.x-other.x, y = self.y-other.y}}
	end



	return self
end

function ticuare:group(group)
	table.insert(group.elements, self)

	return self
end

--Active

function ticuare:setActive(bool)
	if self.type == "group" then
		for i = 1, #self.elements do
			self.elements[i]:setActive(bool)
		end
	else
		self.active = bool
	end
end

function ticuare:enable() return self:setActive(true) end

function ticuare:disable() return self:setActive(false) end

function ticuare:getActive() if self.active ~= nil then return self.active end end

--Visible

function ticuare:setVisible(bool) --l is for lerp

	if self.type == "group" then
		for i = 1, #self.elements do
			self.elements[i]:setVisible(bool)
		end
	else
		self.visible = bool
	end

end

function ticuare:show(l) return self:setVisible(true, l) end

function ticuare:hide(l) return self:setVisible(false, l) end

function ticuare:getVisible() if self.visible ~= nil then return self.visible end end

--Drag

function ticuare:setDragBounds(bounds)
	self.drag.bounds = bounds
end

function ticuare:setHorizontalRange(n)
	self.x = self.drag.bounds[1].x + (self.drag.bounds[2].x-self.drag.bounds[1].x)*n
end

function ticuare:setVerticalRange(n)
	self.y = self.drag.bounds[1].y + (self.drag.bounds[2].y-self.drag.bounds[1].y)*n
end

function ticuare:getHorizontalRange()
	assert(self.drag.bounds and self.drag.bounds[1] and self.drag.bounds[2] and self.drag.bounds[1].x and self.drag.bounds[2].x, "Element must have 2 horizontal boundaries")
	return (self.x-self.drag.bounds[1].x) / (self.drag.bounds[2].x-self.drag.bounds[1].x)
end

function ticuare:getVerticalRange()
	assert(self.drag.bounds and self.drag.bounds[1] and self.drag.bounds[2] and self.drag.bounds[1].y and self.drag.bounds[2].y, "Element must have 2 vertical boundaries")
	return (self.y-self.drag.bounds[1].y) / (self.drag.bounds[2].y-self.drag.bounds[1].y)
end

--Z-Index

function ticuare:setIndex(index)

	if self.type == "group" then
		local lowest
		for i = 1, #self.elements do
			if not lowest or self.elements[i].z < lowest then lowest = self.elements[i].z end
		end
		for i = 1, #self.elements do
			local ti = self.elements[i].z-lowest+index
			self.elements[i]:setIndex(ti)
		end
	else
		self.z = index
		if index > ticuare.hz then ticuare.hz = index end
	end

end

function ticuare:toFront()
	if self.z < ticuare.hz or self.type == "group" then return self:setIndex(ticuare.hz + 1) end
end

function ticuare:getIndex() return self.z end


function ticuare:remove()
	for i = #ticuare.elements, 1, -1 do
		if ticuare.elements[i] == self then table.remove(ticuare.elements, i) self = nil end
	end
end

function ticuare.clear()
	for i = 1, #ticuare.elements do ticuare.elements[i] = nil end
end

--return ticuare


ffont = false

function load()
	sliders={{},{},{}}
	for a=1, 3 do
		for s=1, 3 do
			sliders[a][s]={}
			local x = (15*s)+(60*(s-1))
			local y = 50+(a*20)
			sliders[a][s].sliderBg=ticuare.element({
				x=x,y=y,w=60,h=11,
				colors={7,7,7},
				border={
					colors={3,3,3},
					width=2
				}
			})
			sliders[a][s].slider=ticuare.element({
				x=x, y=y,w=20,h=11,
				colors={1,2,3},
				border={
					colors={4,5,6},
					width=1
				},
				drag = {
					bounds={
						{x=x},
						{x=x+(60-20)}
					},
					enabled = true,
					fixed = {x = false, y = true},
				},
				text={
					center = true,
					colors = {7,8,9},
					offset={x=0,y=1},
				}
			})

		end
	end

	button = ticuare.element({
		x = 185, y = 40, w = 80, h = 40,
		colors = {},
		center = true,
		border={
			colors={},
			width=5
		},
		text = {
			display = "Example\n Button",
			center = true,
			colors = {},
			font = false,
			key = 5,
			space = 5,
			spacing = 8
		},
		onCleanRelease = function ()
			if button.text.font then button.text.font = false else button.text.font = true end
			if ffont then ffont = false else ffont = true end
		end
	})

end



function draw ()
	ticuare.draw()
	ticuare.mlPrint(
		"button = ticuare.element({\n"..
		"  colors={"..table.concat(button.colors,",").."},\n"..
		"  border={\n"..
		"    colors={"..table.concat(button.border.colors,",").."},\n"..
		"  },\n"..
		"  text={\n"..
		"    colors={"..table.concat(button.text.colors,",").."},\n"..
		"  },\n"..
		"})\n", 5,5,9,8,false,ffont,5,5
	)
end

function update()
	ticuare.update(mouse())
	local value
	for ia, va in ipairs(sliders) do
		for is, vs in ipairs(va) do
			value = math.floor(vs.slider:getHorizontalRange()*15)
			vs.slider.text.display = tostring(value)
			vs.slider.colors = {value,value,3}
			vs.slider.border.colors = {15,0,value}
			vs.slider.text.colors = {0,15,value}
			if ia == 1 then
				button.colors[is] = value
			elseif ia == 2 then
				button.border.colors[is] = value
			elseif ia == 3 then
				button.text.colors[is] = value
			end
		end
	end
end

load()
function TIC()
	cls(1)
	update()
	draw()
end

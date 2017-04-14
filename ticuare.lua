-- title:	TICuare
-- author:	Crutiatix
-- desc:	UI library for TIC-80 v0.6.1
-- script:	lua
-- input:	mouse

-- Copyright (c) 2017 Crutiatix
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

ticuare = {name = "ticuare", elements = {}, z = 1, hz = nil}
ticuare.__index = ticuare
ticuare.me = {nothing=0,click=1,noclick=2,none=3}
-- Private
local ticuareMt = {__index = ticuare}

local function inArea(mx, my, x, y, w, h)
	return mx > x and mx < x+w and my > y and my < y+h
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
function ticuare.mlPrint(txt,x,y,c,ls,fix,fnt,key,sw) -- string; x,y position; color; line height; fixed letters size; use font func?; key color; gap size
	local width, width_result, li = 0, 0, 0
	for l in txt:gmatch("([^\n]+)") do
		li = li+1
		if fnt then
			width = font(l,x,y+((li-1)*ls),key,sw)
		else
			width = print(l,x,y+((li-1)*ls),c,fix)
		end
		if width > width_result then width_result = width end
	end
	return width, li*ls
end
-- Public methods

function ticuare.element(element_type, element_obj)

	if not element_obj then element_obj = element_type element_type = "element" end

	local ticuareObj = element_obj
	setmetatable(ticuareObj, ticuare)

	ticuareObj.hover, ticuareObj.click = false, false
	ticuareObj.active = element_obj.active or true
	ticuareObj.drag = element_obj.drag or {active = false}
	ticuareObj.align = element_obj.align or {x=0,y=0}
	ticuareObj.visible = element_obj.visible or true


	if ticuareObj.content then
		if not ticuareObj.content.scroll then ticuareObj.content.scroll = {x = 0, y = 0} end
		ticuareObj.content.w, ticuareObj.content.h = ticuareObj.content.w or ticuareObj.w, ticuareObj.content.h or ticuareObj.h
	end

	ticuareObj.type, ticuareObj.z = element_type, ticuare.z
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

function ticuare:updateSelf(mouse_x, mouse_y, mouse_press, mouse_event)

	local mouse_holding, mouse_over, element_in_focus, hovered, held, align_x, align_y
	local me, tempX, tempY = ticuare.me, self.x-(self.align.x==1 and self.w*.5 or (self.align.x==2 and self.w or 0)),
		self.y-(self.align.y==1 and self.h*.5-1 or (self.align.y==2 and self.h-1 or 0))

	mouse_holding = mouse_event ~= me.none and mouse_press or false

	mouse_over = inArea(mouse_x, mouse_y, tempX, tempY,	self.w,	self.h)


	element_in_focus = mouse_event ~= me.none and mouse_over or false

	hovered, held = self.hover, self.hold

	self.hover = element_in_focus or (self.drag.active and ticuare.draging_obj and ticuare.draging_obj.obj == self)

	self.hold = ((mouse_event == me.click and element_in_focus) and true) or
		(mouse_holding and self.hold) or ((element_in_focus and mouse_event ~= me.noclick and self.hold))

	if mouse_event == me.click and element_in_focus and self.onClick then --clicked
		self.onClick()
	elseif (mouse_event == me.noclick and element_in_focus and held) and self.onCleanRelease then
		self.onCleanRelease()
	elseif ((mouse_event == me.noclick and element_in_focus and held) or (self.hold and not element_in_focus)) and self.onRelease then --released (or mouse has left element, still holding temporarly)
		self.onRelease()
	elseif self.hold and self.onPress then --holding
		self.onPress()
	elseif not hovered and self.hover and self.onStartHover then --started hovering
		self.onStartHover()
	elseif self.hover and self.onHover then --hovering
		self.onHover()
	elseif hovered and not self.hover and self.onReleaseHover then --released hover
		self.onReleaseHover()
	end

	if self.hold and (not element_in_focus or self.drag.active) and not ticuare.draging_obj then
		self.hold = self.drag.active
		ticuare.draging_obj = {obj = self, d = {x = tempX-mouse_x, y = tempY-mouse_y}} -- save what and where is element holded
	elseif not self.hold and element_in_focus and (ticuare.draging_obj and ticuare.draging_obj.obj == self) then
		self.hold = true
		ticuare.draging_obj = nil
	end




	-- DRAGGING
	if ticuare.draging_obj and ticuare.draging_obj.obj == self and self.drag.active then
		self.x = (not self.drag.fixed or not self.drag.fixed.x) and mouse_x + ticuare.draging_obj.d.x or self.x
		self.y = (not self.drag.fixed or not self.drag.fixed.y) and mouse_y + ticuare.draging_obj.d.y or self.y

		local bounds = self.drag.bounds
		if bounds then
			if bounds.x then
				self.x = (bounds.x[1] and self.x < bounds.x[1]) and bounds.x[1] or self.x
				self.x = (bounds.x[2] and self.x > bounds.x[2]) and bounds.x[2] or self.x
			end
			if bounds.y then
				self.y = (bounds.y[1] and self.y < bounds.y[1]) and bounds.y[1] or self.y
				self.y = (bounds.y[2] and self.y > bounds.y[2]) and bounds.y[2] or self.y
			end
		end

		if self.track then
			self:anchor(self.track.ref)
		end
	end


	return element_in_focus
end

function ticuare:updateTrack()
	local bounds, track = self.drag.bounds, self.track
	if track then
		self.x, self.y = track.ref.x + track.d.x, track.ref.y + track.d.y

		if bounds and bounds.relative then
			if bounds.x then
				bounds.x[1] = track.ref.x + track.b.x[1] or nil
				bounds.x[2] = track.ref.x + track.b.x[2] or nil
			end
			if bounds.y then
				bounds.y[1] = track.ref.y + track.b.y[1] or nil
				bounds.y[2] = track.ref.y + track.b.y[2] or nil
			end
		end
	end
end

--
-- Draw
--
function ticuare:drawSelf()
	if self.visible then
		local color, shadow_color, border_color, text_shadow_color, text_color,
			sprite, tempX, tempY, text_width, text_height, text_x, text_y,
			sprite_offset, text_offset, text_shadow_offset, shadow_offset
		local shadow, border, text, icon = self.shadow, self.border, self.text, self.icon

		tempX = self.x-(self.align.x==1 and self.w*.5-1 or (self.align.x==2 and self.w-1 or 0))
		tempY = self.y-(self.align.y==1 and self.h*.5-1 or (self.align.y==2 and self.h-1 or 0))


		if shadow and shadow.colors then
			shadow.offset = shadow.offset or {x=1,y=1}
			shadow_color = ((self.hold and shadow.colors[3]) and shadow.colors[3]) or ((self.hover and shadow.colors[2]) and shadow.colors[2]) or shadow.colors[1] or nil
			if shadow_color then rect(tempX+shadow.offset.x, tempY+shadow.offset.y,self.w, self.h, shadow_color) end
		end

		if self.colors then
			color = ((self.hold and self.colors[3]) and self.colors[3]) or ((self.hover and self.colors[2]) and self.colors[2]) or self.colors[1] or nil
			if color then rect(tempX, tempY, self.w, self.h, color) end
		end

		if border and border.colors and border.width then
			border_color = ((self.hold and border.colors[3]) and border.colors[3]) or ((self.hover and border.colors[2]) and border.colors[2]) or border.colors[1] or nil
			if border_color then
				for b=0,border.width-1 do
					rectb(tempX+b, tempY+b, self.w-2*b, self.h-2*b, border_color)
				end
			end
		end

		if icon and icon.sprites and #icon.sprites > 0 then
			sprite = ((self.hold and icon.sprites[3]) and icon.sprites[3]) or ((self.hover and icon.sprites[2]) and icon.sprites[2]) or icon.sprites[1]
			sprite_offset = icon.offset or {x=0,y=0}

			icon.key = icon.key or -1
			icon.measure = icon.measure or 1
			icon.flip = icon.flip or 0
			icon.rotate = icon.rotate or 0
			icon.extent = icon.extent or {x=1,y=1}
			icon.align = icon.align or {x=0,y=0}
			for x=1,icon.extent.x do
				for y=1,icon.extent.y do
					spr(sprite+(x-1)+((y-1)*16),

						(tempX+(icon.align.x==1 and self.w*.5-((x*icon.measure*8)/2) or (icon.align.x==2 and self.w-(x*icon.measure*8) or 0))+sprite_offset.x),
						(tempY+(icon.align.y==1 and self.h*.5-((y*icon.measure*8)/2) or (icon.align.y==2 and self.h-(y*icon.measure*8) or 0))+sprite_offset.y),
						icon.key,
						icon.measure,
						icon.flip,
						icon.rotate)
			 	end
			end

		end

		--draw text
		if text and text.print and text.colors[1] then
			text.colors[1] = text.colors[1] or 14
			text.gap = text.gap or 5
			text.key = text.key or -1
			text.height = text.height or (text.font and 8 or 6)
			text.fixed = text.fixed or false


			-- set color for text
			if (self.hold and text.colors[3]) then
				text_color = text.colors[3]
			elseif (self.hover and text.colors[2]) then
				text_color = text.colors[2]
			else
				text_color = text.colors[1]
			end
			-- set color for text shadow
			if text.shadow then
				if (self.hold and text.shadow.colors[3]) then
					text_shadow_color = text.colors[3]
				elseif (self.hover and text.shadow.colors[2]) then
					text_shadow_color = text.shadow.colors[2]
				else
					text_shadow_color = text.shadow.colors[1]
				end
				text_shadow_offset = text.shadow.offset or {x=1, y=1}
			end
			-- initiate required vars
			text_offset = text.offset or {x = 0, y = 0}
			text_width, text_height = ticuare.mlPrint(text.print,0,200, -1, text.height, text.fixed, text.font, text.key, text.gap)
			text.align = text.align or {x=0,y=0}

			if text.align.x == 1 then
				text_x = tempX+((self.w*.5)-(text_width*.5))+text_offset.x
			elseif text.align.x == 2 then
				text_x = tempX+((self.w)-(text_width))+text_offset.x-border.width
			else
				text_x = tempX+text_offset.x+border.width
			end

			if text.align.y == 1 then
				text_y = tempY+((self.h*.5)-(text_height*.5))+text_offset.y
			elseif text.align.y == 2 then
				text_y = tempY+((self.h)-(text_height))+text_offset.y-border.width
			else
				text_y = tempY+text_offset.y+border.width
			end

			-- drawing text and text shadow
			if text.shadow and text_shadow_color then
				ticuare.mlPrint(text.print, text_x+text_shadow_offset.x, text_y+text_shadow_offset.y, text_shadow_color, text.height, text.fixed, text.font, text.key, text.gap)
				ticuare.mlPrint(text.print, text_x, text_y, text_color, text.height, text.fixed, text.font, text.key, text.gap)
			else
				ticuare.mlPrint(text.print, text_x, text_y, text_color, text.height, text.fixed, text.font, text.key, text.gap)
			end
		end
		-- drawing element content
		if self.content and self.drawContent then
			if self.content.wrap and clip then clip(tempX+border.width, tempY+border.width, self.w-(2*border.width), self.h-(2*border.width)) end
			self:renderContent()
			if self.content.wrap and clip then clip() end
		end
	end
end

--
-- Content
--

function ticuare:renderContent()
	local tx, ty = self.x-(self.align.x==1 and self.w*.5 or (self.align.x==2 and self.w or 0)), self.y-(self.align.y==1 and self.h*.5-1 or (self.align.y==2 and self.h-1 or 0))
	local border = self.border.width and self.border.width or 1
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

function ticuare.update(mouse_x, mouse_y, mouse_press)

	if mouse_x and mouse_y then
		local me, elements = ticuare.me, ticuare.elements
		local mouse_event, focused, updateQueue, elemt = me.nothing, false, {}, nil

		if ticuare.click and not mouse_press then
			ticuare.click = false
			mouse_event = me.noclick
			ticuare.draging_obj = nil
		elseif not ticuare.click and mouse_press then
			ticuare.click = true
			mouse_event = me.click
			ticuare.draging_obj = nil
		end
		--update every element/window first...
		for i = 1, #elements do table.insert(updateQueue, elements[i]) end

		table.sort(updateQueue, function(a, b) return a.z > b.z end)

		for i = 1, #updateQueue do
			elemt = updateQueue[i]
			if elemt then
				if elemt:updateSelf(mouse_x, mouse_y, mouse_press,((focused or (ticuare.draging_obj and ticuare.draging_obj.obj ~= elemt)) or not elemt.active) and me.none or mouse_event) then
					focused = true
				end
			end
		end
		--...then update their anchors
		for i = #elements, 1, -1 do
			if elements[i] then
				elements[i]:updateTrack()
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
	local b, b_x_min, b_x_max, b_y_min, b_y_max = self.drag.bounds, nil, nil, nil, nil
	if b and b.x then
		b_x_min = b.x[1] - other.x
		b_x_max = b.x[2] - other.x
	elseif b and b.y then
		b_y_min = b.y[1] - other.y
		b_y_max = b.y[2] - other.y
	end

	self.track = {ref = other, d = {x = self.x-other.x, y = self.y-other.y}, b={x={b_x_min,b_x_max},y={b_y_min,b_y_max}}}

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

function ticuare:setVisible(bool)

	if self.type == "group" then
		for i = 1, #self.elements do
			self.elements[i]:setVisible(bool)
		end
	else
		self.visible = bool
	end

end

function ticuare:view() return self:setVisible(true) end

function ticuare:hide() return self:setVisible(false) end

function ticuare:getVisible() if self.visible ~= nil then return self.visible end end

--Drag

function ticuare:setDragBounds(bounds)
	self.drag.bounds = bounds
end

function ticuare:setHorizontalRange(n)
	local bounds = self.drag.bounds
	self.x = bounds.x[1] + (bounds.x[2]-bounds.x[1])*n
end

function ticuare:setVerticalRange(n)
	local bounds = self.drag.bounds
	self.y = bounds.y[1] + (bounds.y[2]-bounds.y[1])*n
end

function ticuare:getHorizontalRange()
	local bounds = self.drag.bounds
	assert(bounds and bounds.x and #bounds.x==2, "X bounds error!")
	return (self.x-bounds.x[1]) / (bounds.x[2]-bounds.x[1])
end

function ticuare:getVerticalRange()
	local bounds = self.drag.bounds
	assert(bounds and bounds.y and #bounds.y==2, "Y bounds error!")
	return (self.y-bounds.y[1]) / (bounds.y[2]-bounds.y[1])
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

function ticuare.empty()
	for i = 1, #ticuare.elements do ticuare.elements[i] = nil end
end

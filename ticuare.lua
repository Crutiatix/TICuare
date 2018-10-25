-- title:	TICuare
-- author:	Crutiatix
-- desc:	UI library for TIC-80 v0.8.0
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

-- pallete switch
local function pal(c0,c1)
	if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end
	else poke4(0x3FF0*2+c0,c1)end
end

function ticuare.lerp(a, b, k)
  if a == b then return a else
    if math.abs(a-b) < 0.005 then return b else return a * (1-k) + b * k end
  end
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
			for i, v in pairs(object) do
					new_table[_copy(i)] = _copy(v)
			end
			return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

local function checkColors(hold, hover, one, two, three)
	if hold then
		return one
	elseif hover then
		return two
	else
		return three
	end
end
-- Public methods

function ticuare.print(text,x,y,color,fixed,scale) -- string; x,y position; color; line height; fixed letters width
	fixed = fixed or false
	scale = scale or 1
	local _, lines_count = text:gsub("\n","")
	local width, height = 0, 0
	if color then
		width, height = print(text,x,y,color,fixed,scale), (6+lines_count) *scale *(lines_count+1)
	end
	return width, height
end

function ticuare.font(text,x,y,colors,key,space_w,space_h,fixed,scale) -- string; x,y position; color/-s; line height; transparent color; space width
	key = key or -1
	space_w = space_w or 8
	space_h = space_h or 8
	fixed = fixed or false
	scale = scale or 1
	local _, lines_count = text:gsub("\n","")
	if type(key)=="table" and type(key[1]) == "table" then
		for si, sc in ipairs(key[1]) do
			if type(colors)=="table" then
				pal(sc,colors[si])
			else
				pal(sc,colors)
			end
		end
		key=key[2]
	end
	local width
	if colors then
		width = font(text,x,y,key,space_w,space_h,fixed,scale)
	end
	pal()
	return width, (space_h+lines_count)*scale*(1+lines_count)
end


function ticuare.element(element_type, element_obj)

	if not element_obj then element_obj = element_type element_type = "element" end

	local ticuareObj = element_obj
	setmetatable(ticuareObj, ticuare)

	ticuareObj.hover, ticuareObj.click = false, false
	ticuareObj.activity = element_obj.activity or true
	ticuareObj.drag = element_obj.drag or {activity = false}
	ticuareObj.align = element_obj.align or {x=0,y=0}
	ticuareObj.visibility = element_obj.visibility or true
	


	if ticuareObj.content then
		if not ticuareObj.content.scroll then ticuareObj.content.scroll = {x = 0, y = 0} end
		ticuareObj.content.w, ticuareObj.content.h = ticuareObj.content.w or ticuareObj.w, ticuareObj.content.h or ticuareObj.h
	end

	ticuareObj.type, ticuareObj.z = element_type, ticuare.z
	ticuare.z = ticuare.z + 1 ticuare.hz = ticuare.z --index stuff
	table.insert(ticuare.elements, ticuareObj)
	return ticuareObj
end

function ticuare.Element(f) return ticuare.element("element", f) end

function ticuare.Style(f) return f end

function ticuare.Group() local t = {type = "group", elements = {}} setmetatable(t, ticuare) return t end


--
-- Update
--

function ticuare:updateSelf(args)
	if args.mouse_x and args.mouse_y and args.event then
		mouse_x = args.mouse_x
		mouse_y = args.mouse_y
		mouse_press = args.press
		mouse_event = args.event
		
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
			self.onClick(self)
		elseif (mouse_event == me.noclick and element_in_focus and held) and self.onCleanRelease then
			self.onCleanRelease(self)
		elseif ((mouse_event == me.noclick and element_in_focus and held) or (self.hold and not element_in_focus)) and self.onRelease then --released (or mouse has left element, still holding temporarly)
			self.onRelease(self)
		elseif self.hold and self.onPress then --holding
			self.onPress(self)
		elseif not hovered and self.hover and self.onStartHover then --started hovering
			self.onStartHover(self)
		elseif self.hover and self.onHover then --hovering
			self.onHover(self)
		elseif hovered and not self.hover and self.onReleaseHover then --released hover
			self.onReleaseHover(self)
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
		
	elseif args.focused_element and args.event then
	
		local me, holding, over, element_in_focus, hovered, held = ticuare.me

		holding = args.event ~= me.none and args.press or false
		over = self == args.focused_element
		element_in_focus = args.event ~= me.none and over or false
		hovered, held = self.hover, self.hold
		self.hover = element_in_focus
		self.hold = ((args.event == me.click and element_in_focus) and true) or
			(holding and self.hold) or ((element_in_focus and args.event ~= me.noclick and self.hold))

		if args.event == me.click and element_in_focus and self.onClick then --clicked
			self.onClick(self)
		elseif (args.event == me.noclick and element_in_focus and held) and self.onCleanRelease then
			self.onCleanRelease(self)
		elseif ((args.event == me.noclick and element_in_focus and held) or (self.hold and not element_in_focus)) and self.onRelease then --released (or mouse has left element, still holding temporarly)
			self.onRelease(self)
		elseif self.hold and self.onPress then --holding
			self.onPress(self)
		elseif not hovered and self.hover and self.onStartHover then --started hovering
			self.onStartHover(self)
		elseif self.hover and self.onHover then --hovering
			self.onHover(self)
		elseif hovered and not self.hover and self.onReleaseHover then --released hover
			self.onReleaseHover(self)
		end
		
		return element_in_focus
	
	else
		error("updateSelf error in arguments!")
	end
	

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

function ticuare:drawSelf ()
	if self.visibility then
		local color, shadow_color, border_color, text_shadow_color, text_color, text_shadow, text_colors,
			sprite, tempX, tempY, text_width, text_height, text_x, text_y, border_colors,
			sprite_offset, text_offset, text_shadow_offset, shadow_offset, 
			border_width, border_key, border_sprites, tile, dbl_border_width, text_align
		local shadow, border, text, icon, tiled, colors = self.shadow, self.border, self.text, self.icon, self.tiled, self.colors

		tempX = self.x-(self.align.x==1 and self.w*.5-1 or (self.align.x==2 and self.w-1 or 0))
		tempY = self.y-(self.align.y==1 and self.h*.5-1 or (self.align.y==2 and self.h-1 or 0))


		if shadow and shadow.colors then
			shadow.offset = shadow.offset or {x=1,y=1}
			shadow_color = checkColors(self.hold,self.hover, shadow.colors[3], shadow.colors[2], shadow.colors[1])
			if shadow_color then rect(tempX+shadow.offset.x, tempY+shadow.offset.y,self.w, self.h, shadow_color) end
		end

		if colors then
			color = checkColors(self.hold,self.hover,colors[3],colors[2],colors[1])
			if color then rect(tempX, tempY, self.w, self.h, color) end
		end
		
		border_width = border and (border.width) or 0
		dbl_border_width = 2*border_width
		
		if tiled then
			tiled.scale = tiled.scale or 1
			tiled.key = tiled.key or -1
			tiled.flip = tiled.flip or 0
			tiled.rotate = tiled.rotate or 0
			tiled.w = tiled.w or 1
			tiled.h = tiled.h or 1
			tile = checkColors(self.hold,self.hover,tiled.sprites[3],tiled.sprites[2],tiled.sprites[1])
						
			if tile then 
				clip(tempX+border_width, tempY+border_width, self.w-dbl_border_width, self.h-dbl_border_width)
				for x=0,self.w+(8*tiled.w)*tiled.scale,(8*tiled.w)*tiled.scale do
					for y=0,self.h+(8*tiled.h)*tiled.scale,(8*tiled.h)*tiled.scale do
						spr(tile,tempX+x+border_width,tempY+y+border_width,tiled.key, tiled.scale, tiled.flip, tiled.rotate, tiled.w, tiled.h)
					end
				end
				clip()
			end
		end
		
		
		-- drawing element content
		if self.content and self.drawContent then
			if self.content.wrap and clip then clip(tempX+border_width, tempY+border_width, self.w-dbl_border_width, self.h-dbl_border_width) end
			self:renderContent()
			if self.content.wrap and clip then clip() end
		end

		if border and border.colors then
			border_colors = border.colors
			border_color = checkColors(self.hold, self.hover, border_colors[3],border_colors[2],border_colors[1])
	
			if border_color then
				for b=0,border.width-1 do
					rectb(tempX+b, tempY+b, self.w-2*b, self.h-2*b, border_color)
				end
			end
		end
		
		if border and border.sprites then
			border_key = border.key or -1
			border_sprites = checkColors(self.hold, self.hover,border.sprites[3],border.sprites[2],border.sprites[1])

			if border_sprites then
				clip(tempX+8,tempY,self.w-16+1,self.h)
				for x=8,self.w-9,8 do
					spr(border_sprites[2], tempX+x, tempY, border_key, 1, 0, 0)
					spr(border_sprites[2], tempX+x, tempY+self.h-8, border_key, 1, 0, 2)
				end
				clip()
				spr(border_sprites[1], tempX, tempY, border_key, 1, 0, 0)
				spr(border_sprites[1], tempX+self.w-8, tempY, border_key, 1, 0, 1)
				clip(tempX,tempY+8,self.w,self.h-16+1)
				for y=8,self.h-9,8 do
					spr(border_sprites[2], tempX, tempY+y, border_key, 1, 0, 3)
					spr(border_sprites[2], tempX+self.w-8, tempY+y, border_key, 1, 2, 1)
				end
				clip()
				spr(border_sprites[1], tempX+self.w-8, tempY+self.h-8, border_key, 1, 0, 2)
				spr(border_sprites[1], tempX, tempY+self.h-8, border_key, 1, 0, 3)
			end
		end
		
		if icon and icon.sprites and #icon.sprites > 0 then
			sprite = ((self.hold and icon.sprites[3]) and icon.sprites[3]) or ((self.hover and icon.sprites[2]) and icon.sprites[2]) or icon.sprites[1]
			sprite_offset = icon.offset or {x=0,y=0}
			icon.align = icon.align or {x=0,y=0}

			spr(sprite,
				(tempX+(icon.align.x==1 and self.w*.5-((icon.scale*8)/2) or (icon.align.x==2 and self.w-(icon.scale*8) or 0))+sprite_offset.x),
				(tempY+(icon.align.y==1 and self.h*.5-((icon.scale*8)/2) or (icon.align.y==2 and self.h-(icon.scale*8) or 0))+sprite_offset.y),
				icon.key, icon.scale,icon.flip, icon.rotate, icon.w, icon.h)
		end

		--draw text
		--set color for text
		if text and text.print then
			text_colors = text.colors or {15,15,15}
			text_colors[1] = text_colors[1] or 15
			if not text.font and type(text.colors[1]) == "table" then
				trace("If text.font is true, then text.colors has to be array of numbers!", 6)
				trace("Traceback: Element with text:\""..text.print.."\"")
				exit()
			end
			
			-- set color for text acording to mouse state
			text_color = checkColors(self.hold,self.hover,text_colors[3],text_colors[2],text_colors[1])	
			
			-- set color for text shadow
			if text.shadow then
				text_shadow = text.shadow
				text_shadow_color = checkColors(self.hold, self.hover,text_shadow.colors[3],text_shadow.colors[2],text_shadow.colors[1])
				text_shadow_offset = text_shadow.offset or {x=1, y=1}
			end
			
			-- get text size
			text_offset = text.offset or {x = 0, y = 0}
			if  text.font then
				text.space = text.space or {w=8,h=8}
				text_width, text_height = ticuare.font(text.print,0,200, -1, text.key, text.space.w, text.space.h, text.fixed, text.scale)
			else 
				text_width, text_height = ticuare.print(text.print,0,200, -1, text.fixed, text.scale)
			end
			
			
			-- align text in x axis
			text_align = text.align or {x=0,y=0}
			text_x = (text_align.x==1 and tempX+((self.w*.5)-(text_width*.5))+text_offset.x or (text_align.x==2 and tempX+((self.w)-(text_width))+text_offset.x-border_width or tempX+text_offset.x+border_width))
			text_y = (text_align.y==1 and tempY+((self.h*.5)-(text_height*.5))+text_offset.y or (text_align.y==2 and tempY+((self.h)-(text_height))+text_offset.y-border_width or tempY+text_offset.y+border_width))

			-- drawing text and text shadow
			if text.font then
				if type(text_shadow_color)=="table" then
					
					ticuare.font(text.print, text_x+text_shadow_offset.x, text_y+text_shadow_offset.y, text_shadow_color, text.key, text.space.w, text.space.h, text.fixed, text.scale)
				end
				ticuare.font(text.print, text_x, text_y, text_color, text.key, text.space.w, text.space.h, text.fixed, text.scale)
			else
				if text_shadow_color then
					ticuare.print(text.print, text_x+text_shadow_offset.x, text_y+text_shadow_offset.y, text_shadow_color, text.fixed, text.scale)
				end
				ticuare.print(text.print, text_x, text_y, text_color, text.fixed, text.scale)
			end
		end
	end
end



--
-- Content
--

function ticuare:renderContent()
	local tx, ty, border, offsetX, offsetY, align
	align = self.align
	tx = self.x-(align.x==1 and self.w*.5 or (align.x==2 and self.w or 0))
	ty = self.y-(align.y==1 and self.h*.5-1 or (align.y==2 and self.h-1 or 0))
	border = self.border and self.border.width or 1
	offsetX = tx-(self.content.scroll.x or 0)*(self.content.w-self.w) + border
	offsetY = ty-(self.content.scroll.y or 0)*(self.content.h-self.h) + border
	self.drawContent(self,offsetX,offsetY)
end

function ticuare:Content(f)
	self.drawContent = f
	return self
end

function ticuare:scroll(f)
	if f ~= nil then
		f.x = f.x or 0
		f.y = f.y or 0
		if self.content then
			f.x = (f.x < 0 and 0) or (f.x > 1 and 1) or f.x
			f.y = (f.y < 0 and 0) or (f.y > 1 and 1) or f.y
			self.content.scroll.x, self.content.scroll.y = f.x or self.content.scroll.x, f.y or self.content.scroll.y
		end
		return self
	else
		if self.content then
			return self.content.scroll
		end
	end
end

--
-- Miscellaneous
--

function ticuare.update(mouse_x, mouse_y, press)
	local me, elements = ticuare.me, ticuare.elements
	local mouse_event, focused, updateQueue, elemt = me.nothing, false, {}, nil
	
	if type(mouse_x)=="table" then press = mouse_y end
	if mouse_x then
		if ticuare.click and not press then
			ticuare.click = false
			mouse_event = me.noclick
			ticuare.draging_obj = nil
		elseif not ticuare.click and press then
			ticuare.click = true
			mouse_event = me.click
			ticuare.draging_obj = nil
		end
		--update every element/window first...
		for i = 1, #elements do table.insert(updateQueue, elements[i]) end

		table.sort(updateQueue, function(a, b) return a.z > b.z end) -- sort acording to z index

		for i = 1, #updateQueue do
			elemt = updateQueue[i]
			if elemt then
				if type(mouse_x)=="table" then
					if elemt:updateSelf{
						focused_element=mouse_x,
						press=press,
						event=(focused or not elemt.activity) and me.none or mouse_event
					} then
						focused = true
					end
					
				elseif mouse_x and mouse_y and type(mouse_x)~="table" then
					if elemt:updateSelf{
						mouse_x=mouse_x, 
						mouse_y=mouse_y,
						press=press,
						event=((focused or (ticuare.draging_obj and ticuare.draging_obj.obj ~= elemt)) or not elemt.activity) and me.none or mouse_event
					} then
						focused = true
					end
				else
					error("Wrong arguments for update()")
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
		for k,v in pairs(self.elements) do
			mergeTables(v, copyTable(style), false)
		end
	else
		mergeTables(self, copyTable(style), false)
	end
	return self
end

function ticuare:anchor(other)
	if self.type == "group" then
		for k,v in pairs(self.elements) do
			v:anchor(other)
		end
	else
		local bounds, b_x_min, b_x_max, b_y_min, b_y_max = self.drag.bounds, nil, nil, nil, nil
		if bounds and bounds.x then
			b_x_min = bounds.x[1] - other.x
			b_x_max = bounds.x[2] - other.x
		elseif bounds and bounds.y then
			b_y_min = bounds.y[1] - other.y
			b_y_max = bounds.y[2] - other.y
		end
		self.track = {ref = other, d = {x = self.x-other.x, y = self.y-other.y}, b={x={b_x_min,b_x_max},y={b_y_min,b_y_max}}}
	end
	return self
end

-- assign element to group
function ticuare:group(group,name)
	if name then
		group.elements[name] = self
	else
		table.insert(group.elements,self)
	end
	return self
end


-- Active
function ticuare:active(bool)
	if bool ~= nil then
		if self.type == "group" then
			for k,v  in pairs(self.elements) do
				v:active(bool)
			end
		else
			self.activity = bool
		end
		return self
	else
		if self.type == "group" then
			local result = {}
			for k,v in pairs(self.elements) do
				result[k] = v:active()
			end
			return result
		else
			if self.activity ~= nil then 
				return self.activity 
			end
		end
	end
end

-- Visible
function ticuare:visible(bool)
	if bool ~= nil then
		if self.type == "group" then
			for k,v  in pairs(self.elements) do
				v:visible(bool)
			end
		else
			self.visibility = bool
		end
		return self
	else
		if self.type == "group" then
			local result = {}
			for k,v in pairs(self.elements) do
				result[k] = v:visible()
			end
			return result
		else
			if self.activity ~= nil then 
				return self.visibility
			end
		end
	end
end

--Drag

function ticuare:dragBounds(bounds)
	if bounds ~= nil then
		self.drag.bounds = bounds
	else
		return self.drag.bounds
	end
end

function ticuare:horizontalRange(n)
	local bounds = self.drag.bounds
	if n ~= nil then
		self.x = bounds.x[1] + (bounds.x[2]-bounds.x[1])*n
	else
		assert(bounds and bounds.x and #bounds.x==2, "X bounds error!")
		return (self.x-bounds.x[1]) / (bounds.x[2]-bounds.x[1])
	end
end

function ticuare:verticalRange(n)
	local bounds = self.drag.bounds
	if n ~= nil then
		self.y = bounds.y[1] + (bounds.y[2]-bounds.y[1])*n
	else
		assert(bounds and bounds.y and #bounds.y==2, "Y bounds error!")
		return (self.y-bounds.y[1]) / (bounds.y[2]-bounds.y[1])
	end
end

--Z-Index

function ticuare:index(index)
	if index ~= nil then
		if self.type == "group" then
			local lowest
			for k,v in pairs(self.elements) do
				if not lowest or v.z < lowest then
					lowest = v.z
				end
			end
			for k,v in pairs(self.elements) do
				local ti = v.z-lowest+index
				v:index(ti)
			end
		else
			self.z = index
			if index > ticuare.hz then ticuare.hz = index end
		end
	else
		return self.z
	end
	return
end

function ticuare:toFront()
	if self.z < ticuare.hz or self.type == "group" then 
		return self:index(ticuare.hz + 1) 
	end
end

function ticuare:remove()
	for i = #ticuare.elements, 1, -1 do
		if ticuare.elements[i] == self then table.remove(ticuare.elements, i) self = nil end
	end
end

function ticuare.empty()
	for i = 1, #ticuare.elements do ticuare.elements[i] = nil end
end

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

ticuare={name="ticuare",elements={},z=1,hz=nil} ticuare.__index=ticuare local e={__index=ticuare} local function i(e,n,o,t,r,d) return e>o and e<r and n>t and n<d end local function r(n,d,o) for e,t in pairs(d)do if type(t)=="table"then if type(n[e]or false)=="table"then r(n[e]or{},d[e]or{},o) else if not n[e]or o then n[e]=t end end else if not n[e]or o then n[e]=t end end end return n end local function a(r) local n={} local function t(e) if type(e)~="table"then return e elseif n[e]then return n[e] end local o={} n[e]=o for e,n in pairs(e)do o[t(e)]=t(n) end return setmetatable(o,getmetatable(e)) end return t(r) end function ticuare.mlPrint(a,o,d,l,n,c,i,u,s) local t={} local e=0 local r=0 for e in a:gmatch("([^\n]+)")do table.insert(t,e) end for a,t in ipairs(t)do if i then e=font(t,o,d+((a-1)*n),u,s) else e=print(t,o,d+((a-1)*n),l,c) end if e>r then r=e end end return e,#t*n end function ticuare.element(t,n) if not n then n=t t="element"end local e=n setmetatable(e,ticuare) e.hover,e.click=false,false e.active=n.active or true e.drag=n.drag or{enabled=false} e.visible=n.visible or true if e.content then if not e.content.scroll then e.content.scroll={x=0,y=0}end e.content.w,e.content.h=e.content.w or e.w,e.content.h or e.h end e.type,e.z=t,ticuare.z ticuare.z=ticuare.z+1 ticuare.hz=ticuare.z table.insert(ticuare.elements,e) return e end function ticuare.newElement(e)return ticuare.element("element",e)end function ticuare.newStyle(e)return e end function ticuare.newGroup()local e={type="group",elements={}}setmetatable(e,ticuare)return e end function ticuare:updateSelf(t,o,e,n) local a=n~="s"and e or false local e=i(t,o,self.x,self.y,self.x+self.w,self.y+self.h) if self.center then e=i(t,o,self.x-self.w*.5,self.y-self.h*.5,self.x+self.w*.5,self.y+self.h*.5) end local e=n~="s"and e or false local r,d=self.hover,self.hold self.hover=e or(self.drag.enabled and ticuare.holdt and ticuare.holdt.obj==self) self.hold=((n=="c"and e)and true)or(a and self.hold)or((e and n~="r"and self.hold)) if n=="c"and e and self.onClick then self.onClick() elseif(n=="r"and e and d)and self.onCleanRelease then self.onCleanRelease() elseif((n=="r"and e and d)or(self.hold and not e))and self.onRelease then self.onRelease() elseif self.hold and self.onHold then self.onHold() elseif not r and self.hover and self.onStartHover then self.onStartHover() elseif self.hover and self.onHover then self.onHover() elseif r and not self.hover and self.onReleaseHover then self.onReleaseHover() end if self.hold and(not e or self.drag.enabled)and not ticuare.holdt then self.hold=self.drag.enabled ticuare.holdt={obj=self,d={x=self.x-t,y=self.y-o}} elseif not self.hold and e and(ticuare.holdt and ticuare.holdt.obj==self)then self.hold=true ticuare.holdt=nil end if ticuare.holdt and ticuare.holdt.obj==self and self.drag.enabled then self.x=(not self.drag.fixed or not self.drag.fixed[1])and t+ticuare.holdt.d.x or self.x self.y=(not self.drag.fixed or not self.drag.fixed[2])and o+ticuare.holdt.d.y or self.y if self.drag.bounds then self.drag.bounds[1].x=self.drag.bounds[1].x or self.x self.drag.bounds[1].y=self.drag.bounds[1].y or self.y self.drag.bounds[2].x=self.drag.bounds[2].x or self.x self.drag.bounds[2].y=self.drag.bounds[2].y or self.y self.x=(self.drag.bounds[1].x and self.x<self.drag.bounds[1].x)and self.drag.bounds[1].x or self.x self.y=(self.drag.bounds[1].y and self.y<self.drag.bounds[1].y)and self.drag.bounds[1].y or self.y self.x=(self.drag.bounds[2].x and self.x>self.drag.bounds[2].x)and self.drag.bounds[2].x or self.x self.y=(self.drag.bounds[2].y and self.y>self.drag.bounds[2].y)and self.drag.bounds[2].y or self.y end if self.track then self:anchor(self.track.ref) end end return e end function ticuare:updateTrack() if self.track then self.x,self.y=self.track.ref.x+self.track.d.x,self.track.ref.y+self.track.d.y end end function ticuare:drawSelf() if self.visible then local t,e=self.x,self.y if self.center then t,e=self.x-self.w*.5,self.y-self.h*.5 end if self.colors then local n=((self.hold and self.colors[3])and self.colors[3])or((self.hover and self.colors[2])and self.colors[2])or self.colors[1]or nil if n then rect(t,e,self.w,self.h,n)end end if self.border and self.border.colors and self.border.width then local o=((self.hold and self.border.colors[3])and self.border.colors[3])or((self.hover and self.border.colors[2])and self.border.colors[2])or self.border.colors[1]or nil if o then for n=0,self.border.width-1 do rectb(t+n,e+n,self.w-2*n,self.h-2*n,o) end end end if self.icon and self.icon.sprites and#self.icon.sprites>0 then local o=((self.hold and self.icon.sprites[3])and self.icon.sprites[3])or((self.hover and self.icon.sprites[2])and self.icon.sprites[2])or self.icon.sprites[1] local n=self.icon.offset or{x=0,y=0} self.icon.key=self.icon.key or-1 self.icon.scale=self.icon.scale or 1 self.icon.flip=self.icon.flip or 0 self.icon.rotate=self.icon.rotate or 0 self.icon.size=self.icon.size or 1 for d=1,self.icon.size do for r=1,self.icon.size do spr(o+(d-1)+((r-1)*16), (t+(self.center and 0 or self.w*.5)+n.x-4), (e+(self.center and 0 or self.h*.5)+n.y-4), self.icon.key, self.icon.scale, self.icon.flip, self.icon.rotate) end end end if self.text and self.text.display and self.text.colors[1]then self.text.colors[1]=self.text.colors[1]or 14 self.text.space=self.text.space or 5 self.text.key=self.text.key or-1 self.text.spacing=self.text.spacing or(self.text.font and 8 or 6) self.text.fixed=self.text.fixed or false local e if(self.hold and self.text.colors[3])then e=self.text.colors[3] elseif(self.hover and self.text.colors[2])then e=self.text.colors[2] else e=self.text.colors[1]end local n=self.text.offset or{x=0,y=0} local t,o=ticuare.mlPrint(self.text.display,300,300,-1,self.text.spacing,self.text.fixed,self.text.font,self.text.key,self.text.space) ticuare.mlPrint(self.text.display, self.x-(self.center and(self.w*.5)or 0)+(self.text.center and(self.w*.5)-(t*.5)or 0)+n.x+(self.text.center and 0 or self.border.width), self.y-(self.center and(self.h*.5)or 0)+(self.text.center and(self.h*.5)-(o*.5)or 0)+n.y+(self.text.center and 0 or self.border.width), e,self.text.spacing,self.text.fixed,self.text.font,self.text.key,self.text.space ) end if self.content and self.drawContent then self:renderContent() end end end function ticuare:renderContent() local t,e=self.x,self.y if self.center then t,e=self.x-self.w*.5,self.y-self.h*.5 end local n=self.border.width and self.border.width+1 or 1 local t=t-(self.content.scroll.x or 0)*(self.content.w-self.w)+n local e=e-(self.content.scroll.y or 0)*(self.content.h-self.h)+n self.drawContent(self,t,e) end function ticuare:setContent(e) self.drawContent=e end function ticuare:setContentDimensions(n,e) if self.content then self.content.w,self.content.h=n,e end end function ticuare:setScroll(e) e.x=e.x or 0 e.y=e.y or 0 if self.content then e.x=(e.x<0 and 0)or(e.x>1 and 1)or e.x e.y=(e.y<0 and 0)or(e.y>1 and 1)or e.y self.content.scroll.x,self.content.scroll.y=e.x or self.content.scroll.x,e.y or self.content.scroll.y end end function ticuare:getScroll() if self.content then return{x=self.content.scroll.x,y=self.content.scroll.y} end end function ticuare.update(r,d,o) if r and d then local n,e="n",o if ticuare.c and not e then ticuare.c=false n="r"ticuare.holdt=nil elseif not ticuare.c and e then ticuare.c=true n="c"ticuare.holdt=nil end local t=false local e={} for n=1,#ticuare.elements do table.insert(e,ticuare.elements[n])end table.sort(e,function(e,n)return e.z>n.z end) for a=1,#e do local e=e[a] if e then if e:updateSelf(r,d,o,((t or(ticuare.holdt and ticuare.holdt.obj~=e))or not e.active)and"s"or n)then t=true end end end for e=#ticuare.elements,1,-1 do if ticuare.elements[e]then ticuare.elements[e]:updateTrack() end end end end function ticuare.draw() local e={} for n=1,#ticuare.elements do if ticuare.elements[n].draw then table.insert(e,ticuare.elements[n])end end table.sort(e,function(n,e)return n.z<e.z end) for n=1,#e do e[n]:drawSelf()end end function ticuare:style(e) if self.type=="group"then for n=1,#self.elements do r(self.elements[n],a(e),false) end else r(self,a(e),false) end return self end function ticuare:anchor(e) if self.type=="group"then self.elements[1].track={ref=e.elements[1],d={x=self.x-e.elements[1].x,y=self.y-otherelements.other.y}} else self.track={ref=e,d={x=self.x-e.x,y=self.y-e.y}} end return self end function ticuare:group(e) table.insert(e.elements,self) return self end function ticuare:setActive(e) if self.type=="group"then for n=1,#self.elements do self.elements[n]:setActive(e) end else self.active=e end end function ticuare:enable()return self:setActive(true)end function ticuare:disable()return self:setActive(false)end function ticuare:getActive()if self.active~=nil then return self.active end end function ticuare:setVisible(e) if self.type=="group"then for n=1,#self.elements do self.elements[n]:setVisible(e) end else self.visible=e end end function ticuare:show(e)return self:setVisible(true,e)end function ticuare:hide(e)return self:setVisible(false,e)end function ticuare:getVisible()if self.visible~=nil then return self.visible end end function ticuare:setDragBounds(e) self.drag.bounds=e end function ticuare:setHorizontalRange(e) self.x=self.drag.bounds[1].x+(self.drag.bounds[2].x-self.drag.bounds[1].x)*e end function ticuare:setVerticalRange(e) self.y=self.drag.bounds[1].y+(self.drag.bounds[2].y-self.drag.bounds[1].y)*e end function ticuare:getHorizontalRange() assert(self.drag.bounds and self.drag.bounds[1]and self.drag.bounds[2]and self.drag.bounds[1].x and self.drag.bounds[2].x,"Element must have 2 horizontal boundaries") return(self.x-self.drag.bounds[1].x)/(self.drag.bounds[2].x-self.drag.bounds[1].x) end function ticuare:getVerticalRange() assert(self.drag.bounds and self.drag.bounds[1]and self.drag.bounds[2]and self.drag.bounds[1].y and self.drag.bounds[2].y,"Element must have 2 vertical boundaries") return(self.y-self.drag.bounds[1].y)/(self.drag.bounds[2].y-self.drag.bounds[1].y) end function ticuare:setIndex(e) if self.type=="group"then local n for e=1,#self.elements do if not n or self.elements[e].z<n then n=self.elements[e].z end end for t=1,#self.elements do local e=self.elements[t].z-n+e self.elements[t]:setIndex(e) end else self.z=e if e>ticuare.hz then ticuare.hz=e end end end function ticuare:toFront() if self.z<ticuare.hz or self.type=="group"then return self:setIndex(ticuare.hz+1)end end function ticuare:getIndex()return self.z end function ticuare:remove() for e=#ticuare.elements,1,-1 do if ticuare.elements[e]==self then table.remove(ticuare.elements,e)self=nil end end end function ticuare.clear() for e=1,#ticuare.elements do ticuare.elements[e]=nil end end

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

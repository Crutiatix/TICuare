### Control TICuare UI with gamepad

[![Example](/images/gamepadinput.gif)](http://tic.computer/play?cart=87)

```lua
-- title:	TICuare
-- author:	Crutiatix
-- desc:	UI library for TIC-80 v0.7.0
-- script:	lua
-- input:	gamepad

-- TICuare snipped

-- class for input more characters
function wordInput (x,y,length,la)
	-- support function
	function table.index(t, item)
		for i, v in ipairs(t) do
			if v == item then 
				return i 
			end
		end
	end

	-- class for input chars
	function letterInput (x,y,la) -- x, y - position; li - letter index in la- letters array 
		-- Element containing letter
		local letter = ticuare.element({
			x=x-2, y=y+1+8, w=12, h=11,
			colors={1,1,1},
			text={
				print=" ",
				font=true, -- use font instead print
				align={x=1,y=1}, -- center in horisontal and vertical axis
				offset={x=1,y=1}, -- shift
				colors={{6,9,14},{9,14,15},{14,15,15}}, -- colors for replace for default, hover and hold state
				key={{6,9,14},5} -- {{colors to be replaced}transparent color}
			},
			content={},
			
		})
			
		letter.onHover=function() -- set action when is focused
			local indx
			if btnp(0,1,10) then
				indx = table.index(la, letter.text.print) -- get index of actual letter
				letter.text.print=la[indx < #la and indx+1 or 1] -- next letter if not last else first
			elseif btnp(1,1,10) then
				indx = table.index(la, letter.text.print) -- get index of actual letter
				letter.text.print=la[indx > 1 and indx-1 or #la] -- previous letter if not first, else last
			elseif btnp(2,1,10) then  
				focused = focused > 1 and focused-1 or #elements_list 
			elseif btnp(3,1,10) then  
				focused = focused < #elements_list and focused+1 or 1 
			end
		end

		letter:Content(function(ref,x,y) -- draw arrows
			if ref.hover then
				if btn(0) then
					spr(4,x+1,y-9,0)
				else
					spr(3,x+1,y-9,0)
				end
				
				if btn(1) then
					spr(7,x+1,y+ref.h-1,0)
				else
					spr(6,x+1,y+ref.h-1,0)
				end
			else
				spr(2,x+1,y-9,0)
				spr(5,x+1,y+ref.h-1,0)
			end
		end)
		
		return letter
	end

	self={}
	self.inputs = {}
	for i=0, length-1 do -- create characters inputs
		table.insert(self.inputs, letterInput(x+i*12,y,la))
	end
	
	function self.get() -- function to get whole input text
		local result = ""
		for k, v in ipairs(self.inputs) do
			result = result..v.text.print
		end
		return result
	end
	
	function self.set(s) -- function to set letters of input
		t={}
		for i=1,#s do
			table.insert(t,s:sub(i,i))
		end
		for k, v in ipairs(self.inputs) do
			v.text.print = t and t[k] or " "
		end
	end
	return self
end	


-- BUTTON for geting and printing text from input
add = ticuare.element({
	x=120-25,y=50,w=40,h=11,
	align={x=1,y=1},
	colors={1,1,1},
	shadow={
		colors={1,6,9}
	},
	border={
		colors={6,9,14},
		width=1
	},
	text={
		print="ADD",
		font=true,
		align={x=1,y=1},
		offset={x=1,y=0},
		colors={{6,9,14},{9,14,15},{14,15,15}},
		key={{6,9,14},5}
	},
	onClick=function()
		list=list..input.get().."\n"
	end,
	onHover=function()
		if btnp(2,1,10) then  
			focused = focused > 1 and focused-1 or #elements_list 
		elseif btnp(3,1,10) then  
			focused = focused < #elements_list and focused+1 or 1 
		end
	end
})

--BUTTON for clear list and input letters
clear = ticuare.element({
	x=120+25,y=50,w=40,h=11,
	align={x=1,y=1},
	colors={1,1,1},
	shadow={
		colors={1,6,9}
	},
	border={
		colors={6,9,14},
		width=1
	},
	text={
		print="CLEAR",
		font=true,
		align={x=1,y=1},
		offset={x=1,y=0},
		colors={{6,9,14},{9,14,15},{14,15,15}},
		key={{6,9,14},5}
	},
	onClick=function()
		input.set("      ")
		list=""
	end,
	onHover=function()
		if btnp(2,1,10) then  
			focused = focused > 1 and focused-1 or #elements_list 
		elseif btnp(3,1,10) then  
			focused = focused < #elements_list and focused+1 or 1 
		end
	end
})

-- List Container
content_height=0
container = ticuare.element({
	x=120,y=95,w=70,h=60,
	align={x=1,y=1},
	colors={1,1,1},
	shadow={
		colors={1,6,9}
	},
	border={
		colors={6,9,14},
		width=1
	},
	content={
		w=0,h=0,
		wrap=true,  -- clip content
		scroll={x=0,y=0} -- set initial scroll to left top
	},
	onHover=function() -- scroll content proportionaly to position of cursor
		local s = container:scroll()
		if btnp(1,1,10) then
			container:scroll{x=0,y=s.y+0.05}
		elseif btnp(0,1,10) then
			container:scroll{x=0,y=s.y-0.05}
		elseif btnp(2,1,10) then  
			focused = focused > 1 and focused-1 or #elements_list 
		elseif btnp(3,1,10) then  
			focused = focused < #elements_list and focused+1 or 1 
		end
	end
})

container:Content(function(ref,x,y)
	w,h=ticuare.font(list,x+35-24,y+5,{6,9,14},8,{{6,9,14},5},1) -- print out added text
	ref.content.w=w	-- set content size acording to list size
	ref.content.h=h+26
end)


-- charset
letters = {" ","_","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"}

-- Input interface
input = wordInput(120+2-(7*12)/2,10,7,letters)
input.set("TICUARE")
list = ""

elements_list={
	input.inputs[1],
	input.inputs[2],
	input.inputs[3],
	input.inputs[4],
	input.inputs[5],
	input.inputs[6],
	input.inputs[7],
	add,clear,container
}

focused=1

-- BASIC LOOP
function TIC()
	cls(0)
	ticuare.update(elements_list[focused],btn(5)) -- use gamepad cursor instead of mouse
	ticuare.draw()
end


```

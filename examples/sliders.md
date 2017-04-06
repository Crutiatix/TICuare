## Sliders and multiline text

![Sliders example](/images/exampleSliders.gif)


[Full file](/examples/sliders.lua)
```lua
--- metadata
--- ticuare definition

ffont = false                           -- help variable for change a writing text from print() func to font() and back

function load()                         -- help function called before TIC()
  sliders={{},{},{}}                    -- variable for a slider elements
  for a=1, 3 do                         -- create sliders elements in loop; var a presents colors of element, border and text
    for s=1, 3 do                       -- var s presents colors for default, hover and hold state
      sliders[a][s]={}
      local x = (15*s)+(60*(s-1))
      local y = 50+(a*20)
      sliders[a][s].sliderBg=ticuare.element({  --creating backgroud of sliders
        x=x,y=y,w=60,h=11,
        colors={7,7,7},
        border={
          colors={3,3,3},
          width=2
        }
      })
      sliders[a][s].slider=ticuare.element({   -- creating sliders
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

  button = ticuare.element({              -- a button element
    x = 185, y = 40, w = 80, h = 40,
    colors = {},
    center = true,
    border={
      colors={},
      width=5
    },
    text = {
      display = "Example\n Button",       -- a multiline text
      center = true,                      -- in center of element
      colors = {},                        -- colors are set from sliders, not needed here
      font = false,                       -- use print() function
      key = 5,                            -- set transparent color
      space = 5,                          -- width of space (only if font is true)
      spacing = 8                         -- line heigh affect linespacing in multiline text
    },
    onCleanRelease = function ()
      if button.text.font then button.text.font = false else button.text.font = true end -- switching between print() and font() functions
      if ffont then ffont = false else ffont = true end     -- same but for text printed outside of the element 
    end
  })

end



function draw ()                -- help function called inside TIC() function after update()
  ticuare.draw()                -- needed for ticuare
  ticuare.mlPrint(              -- multiline print
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

function update()                             -- help function called inside TIC() function before draw()
  ticuare.update(mouse())
  local value
  for ia, va in ipairs(sliders) do            -- update state for every slider and apply colors on elements
    for is, vs in ipairs(va) do
      value = math.floor(vs.slider:getHorizontalRange()*15)   --get normalised value of slider
      vs.slider.text.display = tostring(value)
      vs.slider.colors = {value,value,3}
      vs.slider.border.colors = {15,0,value}
      vs.slider.text.colors = {0,15,value}
      if ia == 1 then                         -- if first column of sliders
        button.colors[is] = value
      elseif ia == 2 then                     -- if second column of sliders
        button.border.colors[is] = value
      elseif ia == 3 then                     -- if third column of sliders
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

```

# TICuare
A simple and customisable UI library for TIC-80 based on Uare


Setup
----------------

The first thing what you'll need to do is to copy TICuare library snippet to your code. A minified version (ticuare.min.lua) takes roughly 10KB. Also, it's needed to define mouse input in metadata.

Then, you'll need to update the library in order to update the status of your elements, using *ticuare.update(mouse())* and lastly, you'll want to draw your buttons using *ticuare.draw()*. Alternatively, you can draw individual buttons using *myElement:drawSelf()*.

```lua
-- input: mouse
function TIC()
  ticuare.update(mouse())
  ticuare.draw()
end
```


Usage
----------------

Everything what you create in Tincuare will be made from **element**:
```lua
myElement = ticuare.element({ 
  x = 10,                   -- position x
  y = 10,                   -- position y
  w = 400,                  -- width
  h = 60,                   -- height  
  colors = {1,2,3},         -- define a colors for default, hover and hold state (in this order)
  border = {                -- define border style
    colors = {4,5,6},       -- same as before
    width = 2               -- a thickness of border
  }
})
``` 
![Example 1](/images/example1.gif)

Sometimes you'll want to create greater number of similar elements. For this purpose TICuare uses a style system. This allows you to apply general **style**s to new elements, removing the need to write unnecessary attributes on each *ticuare.element()*.

```lua
myStyle = ticuare.newStyle({ -- define new style
	colors = {6,4,12},
	border = {
	 colors = {4,1,6},
		width = 2
 }
})

myElement = ticuare.element({ 
  x = 10,
  y = 10,
  w = 20,
  h = 20,      
}):style(myStyle) -- applying style on element, myElement:style(myStyle) works too
```
![Example 2](/images/example2.gif)

Styles are created using *ticuare.newStyle(attributes)* and applied using *ticuare.new(attributes):style(myStyle)*.
They can also be applied *after* creation, using *button:style(myStyle)*.

WORK IN PROGRESS...

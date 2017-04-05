# TICuare
A simple and customisable UI library for [TIC-80 - tiny computer by Nesbox](https://nesbox.itch.io/tic) based on library [Uare by Ulydev](https://github.com/Ulydev/Uare)

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


Usage and features
----------------

### Elements
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

### Styles
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

### Groups
TICuare also uses a group system, which can be used to set attributes of many elements more efficiently.

```lua
myGroup = ticuare.newGroup()

myElement1 = ticuare.element({ 
  x = 64, y = 64, w = 20, h = 10,
  colors = {10,10,10},
  border = {
    colors = {2,2,2},
    width = 2
  },
  onClick = function()
    if myElement1:getVisible() then
      myGroup:hide()
    else
     myGroup:show()
    end
  end
}):group(myGroup)

myElement2 = ticuare.element({
  x = 64, y = 74, w = 20, h = 20,
  colors = {10,10,10},
  border = {
    colors = {8,8,8},
    width = 2
  }
}):group(myGroup)
```
![Example 3](/images/example3.gif)

Just like regular elements, *Groups* support some **methods** as:
- group:setActive(), including
  - group:enable()
  - group:disable()
- group:setVisible(), including
  - group:show()
  - group:hide()
- group:setIndex(), including
  - group:toFront()
well as:
- group:style()
- group:anchor()
- group:group()

### Dragging
Set *enabled* to true in the *drag* attribute turn dragging on.

From there, you have many different possibilities for you to set up your own draggable element.
In case you'd like to make a simple slider, for example, just create a draggable element with a fixed movement axis and two bounds.
You can then retrieve the value of your slider/element using *element:getHorizontalRange()* and *element:getVerticalRange()*, which return normalized numbers (between 0 and 1).
Make sure you've properly set up bounds before calling these methods. Please not that you can also (re)define bounds later with *element:setDragBounds(bounds)*.

```lua
ticuare.element({
  x = 20,
  y = 60,
  w = 20,
  h = 20,
  colors={5,5,5},
  border={
    colors={11,11,11},
    width = 2
  },
  drag = {
    enabled = true,
    fixed = {
      y = true --movement is restricted on the vertical axis
    },
    bounds = { --we just set horizontal bounds
      {
        x = 20
      },
      {
        x = 60
      }
    }
  }
})

ticuare.element({
  x = 20,
  y = 20,
  w = 20,
  h = 20,
  colors={9,9,9},
  border={
    colors={14,14,14},
    width = 2
  },
  drag = {
    enabled = true,
    bounds = { --we just set horizontal bounds
      {
        x = 20,
	y = 20
      },
      {
        x = 220,
	y = 116
      }
    }
  }
})
```
![Example 4](/images/example4.gif)

It's also possible to manually set the range for a specific element using element:setHorizontalRange(n) and element:setVerticalRange(n), where *n* is a number between 0 and 1.

### Anchors
A element can be anchored to another, which means it will follow its movement (in case of a draggable element, for instance). This is useful for making windows quickly, amongst other possible uses. 
For anchor element2 to element1 use *element2:anchor(element1)*.

```lua
myElement1 = ticuare.element({
  x = 20,
  y = 20,
  w = 20,
  h = 20,
  colors={5,5,5},
  border={
    colors={11,11,11},
    width = 2
  },
  drag = {
    enabled = true,
  }
})

myElement2 = ticuare.element({
  x = 50,
  y = 20,
  w = 20,
  h = 20,
  colors={9,9,9},
  border={
    colors={14,14,14},
    width = 2
  },
}):anchor(myElement1)
```
![Example 5](/images/example5.gif)

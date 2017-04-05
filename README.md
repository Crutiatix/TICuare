# TICuare
A simple and customisable UI library for [TIC-80 - tiny computer by Nesbox](https://nesbox.itch.io/tic) based on library [Uare by Ulydev](https://github.com/Ulydev/Uare)

Setup
----------------

The first thing what you'll need to do is to copy TICuare library snippet to your code. A minified version (ticuare.min.lua) takes roughly 10KB. Also, it's needed to define mouse input in metadata.

Then, you'll need to update the library in order to update the status of your elements, using *ticuare.update(mouse())* and lastly, you'll want to draw your buttons using *ticuare.draw()*. Alternatively, you can draw individual buttons using *myElement:drawSelf()*.

```lua
-- input: mouse
function TIC()
  cls(0)
  ticuare.update(mouse())
  ticuare.draw()
end
```


Usage and features
----------------

### Elements
Everything what you create in TICuare will be made from **element**:
```lua
myElement = ticuare.element({ 
  x = 10,                   -- position x
  y = 10,                   -- position y
  w = 20,                   -- width
  h = 20,                   -- height  
  center = true,            -- this makes as default positioning point center of element instead of left-top corner
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

### Text
TICuare implements ease way to write text on elements. A text is added to element by using *text* attribute in body of element. Attributes of *text* are *display* (text to dislay), *colors*, *offset* and *font*. 
If *font* is true then text is displeyed by function font() from TIC-80 API, so it uses user defined font, else default is value false so means it uses function print() from TIC-80 API. If *font* is used it's needed to set two more attributes: *transparent* (transparent color of font) and *space* which define size of space.

```lua
myElement1 = ticuare.element({
  x=20,y=20,w=200,h=14,
  colors={3,3,3},
  border={
    colors={7,7,7},
    width = 2
  },
  text = {
    display = "TICuare - Uare for TIC-80",  -- Text to display
    colors  = {15,14,9},                    -- colors of text for default, hover and held state
    center = true,                          -- vertical and horizontal centerize 
    offset={x=0,y=0}
    fixed = false                           -- if true all characters have fixed size 
	}
})

myElement2 = ticuare.element({
  x=20,y=40,w=200,h=14,
  colors={3,3,3},
  border={
    colors={7,7,7},
    width = 2
  },
  text = {
    font = true,                  -- write text by user defined font
    display = "TICuare - Uare for TIC-80",
    colors  = {15,14,9},          -- for now it has no effect
    center = true,
    transparent = 5,             -- make specific color transparent
    space = 5                    -- size of space
  }
})
```
![Text example](/images/example8.gif)

### Icons
Icons can represent images defined as sprites.

Icon are defined in element by using attribute *icon*. It's attributes are *sprites* which define sprites for default, hover and held state and also *offset* which define local position. Next, known from TIC spr() API function: *key* (colorkey), *scale*, *flip*, *rotate*. And lastly, sprite *size* which corresponds to x\*y number of 8x8 sprites so value 2 means sprite 16x16.

```lua
myElement = ticuare.element({
  x = 20, y = 20, w = 8, h = 8,
  icon = {
    sprites = {1,2,3},  -- sprites for default, hover and held state
    offset = {
      x = 0,
      y = 0
  },
    key = 0,            -- default -1 so opaque
    scale = 1,          -- default 1
    flip = 0,           -- default 0
    rotate = 0,         -- default 0
    size = 1            -- default 1
  }
})
```
![Icon Example](/images/example7.gif)

### Groups
TICuare also uses a group system, which can be used to set attributes of many elements more efficiently.

```lua
myGroup = ticuare.newGroup()            -- create group and assign

myElement1 = ticuare.element({ 
  x = 64, y = 64, w = 20, h = 10,
  colors = {10,10,10},
  border = {
    colors = {2,2,2},
    width = 2
  },
  onClick = function()                  -- When clicked on this element
    if myElement1:getVisible() then     -- If Element in group is visible
      myGroup:hide()                    -- Hide everything in group
    else
     myGroup:show()                     -- Show everything in group
    end
  end
}):group(myGroup)                       -- add element to group

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
  x = 20, y = 60, w = 20, h = 20,
  colors={5,5,5},
  border={
    colors={11,11,11},
    width = 2
  },
  drag = {
    enabled = true,
    fixed = {
      y = true      --movement is restricted on the vertical axis
    },
    bounds = {      --we just set horizontal bounds
      {x = 20},     -- from position (global)
      {x = 60}      -- to position (global)
    }
  }
})

ticuare.element({
  x = 20, y = 20, w = 20, h = 20,
  colors={9,9,9},
  border={
    colors={14,14,14},
    width = 2
  },
  drag = {
    enabled = true,
    bounds = {
      {x = 20, y = 20},
      {x = 220, y = 116}
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
  x = 20, y = 20, w = 20, h = 20,
  colors={5,5,5},
  border={
    colors={11,11,11},
    width = 2
  },
  drag = {          -- no fixed and bounds definition make it free dragable
    enabled = true,
  }
})

myElement2 = ticuare.element({
  x = 50, y = 20, w = 20, h = 20,
  colors={9,9,9},
  border={
    colors={14,14,14},
    width = 2
  },
}):anchor(myElement1)
```
![Example 5](/images/example5.gif)


### Content and scrolling
You can draw inside an element by setting its *content*, using element:setContent(). It only takes a function as a parameter, which will be given the *ref*, *x* and *y* attributes.
It's needed to add atributes *x* and *y* to position of any element which is drawn in content for make it move together with main element.

~~Set the *wrap* attribute to true to turn wrapping on. This will prevent the function from drawing outside the element.~~
TIC-80 currently doesn't offer trim/wrap function in it's API and it's implement in lua significantly reduces a performance.

```lua
myElement = ticuare.element({
  x = 20, y = 20, w = 50, h = 50,
    colors={15,15,15},
    border={
      colors={10,10,10},
      width = 2
    },
  drag = {
    enabled = true,
  },
    content ={
      w = 50,         -- set size of content
      h = 50          -- if set with wrap attribute, so conten is drawed only in this box
    }
})

myElement:setContent(function(ref, x, y) -- ref - reference to myElement; x,y top left corner of element inside borders
  print("Content", x+1, y+8)
  print("    of", x+1, y+16)
  print("Element", x+1, y+24)
end)
```
![Example 6](/images/example6.gif)

**Scrolling** is set in the *content* atribute using *scroll* atribute like this:
```lua
-- start of the element definition
  content = {
    w = 100,
    h = 100,
    scroll = {
      x = 1 -- for horisontal scroll (optional)
      y = 1 -- for vertical scroll. Botom of content.
    }
  }
-- rest of the element definition
```

You can later set the scroll for a specific axis manually using *element:setScroll({ x, y })* and retrieve scroll using *element:getScroll()*

```lua
function TIC()
  ticuare.update(mouse())
  local scrollY = element:getScroll().y
  element:setScroll({ y = (scrollY+1)/2 }) --slowly lerp towards 1 (bottom)
end
```

Lastly, it's possible to redefine content dimensions at runtime with *element:setContentDimensions(width, height)*.

### Visibility and activity
Buttons can be enabled and disabled using *button:setActive(bool)*, or *button:enable()* and *button:disable()*.
When disabled, a button will still be updated but will ignore the mouse, making it idle.
Likewise, they can be shown and hidden using *button:setVisible(bool)*, or *button:show()* and *button:hide()*.
You can also retrieve the visibility and activity of a specific button with *button:getActive()* and *button:getVisible()*.

*Check out the example in Groups section.*

### Indexes and priority order
Sometimes, you'll need to have a button overlaying another. This can be achieved using *element:setIndex()* or *element:toFront()*.
You can also retrieve the index of a specific button with *element:getIndex()*.

```lua
elementfront = ticuare.element({}):style(elementStyle)

elementbehind = ticuare.element({}):style(elementStyle) --elementbehind is being draw on top of buttonfront

--from there, you can either do
elementfront:toFront()

--or
elementnfront:setIndex(elementbehind:getIndex() + 1)

--or
elementbehind:setIndex(1)
elementfront:setIndex(2)
```

### Callbacks - Called on specific events

```lua
onClick         --button is clicked down
onCleanRelease  --button is cleanly released (mouse is inside the button)
onRelease       --button is released (mouse _can_ be outside the button, for instance if the user tries to drag it)
onHold          --button is held (called every frame)
onStartHover    --mouse has started hovering the button
onHover         --mouse is hovering the button (called every frame)
onReleaseHover  --mouse is not hovering anymore
```

Callbacks can be set just like normal attributes.
```lua
myStyle = ticuare.newStyle({
  onClick = function() print("click!") end
})
```

### Removing elements

```lua
element:remove()
```
Removes a specific button from TICuare.

```lua
ticuare.clear()
```

Removes every button from TICuare.

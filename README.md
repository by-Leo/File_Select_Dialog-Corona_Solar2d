# File_Select_Dialog-Corona_Solar2d

Dialog box for selecting files ( Windows, Android ). The module was created for users Corona sdk and Solar2d

## Initialization
```lua
local fsd = require 'fsd'
```

## Usage
```lua
fsd.create(config, group)
```

# Config options ( Table )
-  type - Formats to be selected by the user (Table)<br>
-  new_folder - The folder into which the file will be imported (String)<br>
-  new_file - New name of the imported file (String)<br>
-  new_type - New extension for the imported file (String)<br>
-  path - Default path (String)<br>
-  listener - Listener (Function)<br>

## Group 
By hiding a group in order to correctly display the interface, all objects on the scene should be in this group, it is recommended to use the scene group (sceneGroup) and not access the module through main.lua (Optional parameter)

## Example 
```lua
local fsd = require 'fsd'

local group = display.newGroup()

local object1 = display.newImage(group, ...)
local object2 = display.newRect(group, ...)
local object3 = display.newPolygon(group, ...)

local config = {
  type = {
    '.png',
    '.jpg'
  },
  new_folder = 'Picture',
  new_file = 'Image',
  new_type = '.png',
  path = 'C:\\Users', -- /sdcard (for Android)
  listener = function( e )
    if e.import then
      native.showAlert( 'File Select Dialog', 'File successfully imported', {'Close'} )
      print(e.path) -- New path to the imported file
    else
      native.showAlert('File Select Dialog', 'Failed to import file! \nCheck if storage access is granted for the application', {'Close'})
    end
  end
}

fsd.create(config, group)
```

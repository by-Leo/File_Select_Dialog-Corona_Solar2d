# File_Select_Dialog-Corona_Solar2d

Dialog box for selecting files ( Windows, Android ). The module was created for users Corona sdk and Solar2d

# Initialization

```lua
local fsd = require 'fsd'
```

# Using

```lua
fsd.create( config )
```

# Config options ( Table )

• type - Formats to be selected by the user ( table )<br>
• new_folder - The folder into which the file will be imported ( string )<br>
• new_file - New name of the imported file ( string )<br>
• new_type - New extension for the imported file ( string )<br>
• path - Default path ( string )<br>
• listener - Listener ( function )<br>

# Example 

```lua
local fsd = require 'fsd'

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
      print( e.path ) -- New path to the imported file
    else
      native.showAlert( 'File Select Dialog', 'Failed to import file! \nCheck if storage access is granted for the application', {'Close'} )
    end
  end
}

fsd.create( config )
```

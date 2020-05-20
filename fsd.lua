local fsd = {}

local lfs = require 'lfs'
local widget = require 'widget'
local socket = require 'socket'
local json = require 'json'
local utf8 = require 'plugin.utf8'

local last_position_y = 100
local scroll_height = 0
local path
local group_self
local file_listener
local image_visible = false
local files = {}
local folders = {}
local files_and_folders_group = display.newGroup()

display.setDefault( "background", 0.15, 0.15, 0.2 )
widget.setTheme( "widget_theme_android_holo_dark" )

local seed = (socket.gettime()*10000)%10^9
math.randomseed(seed)

local config = {
  x = display.contentCenterX,
  y = display.contentCenterY + 50,
  width = display.contentWidth,
  height = display.contentHeight - 100,
  hideBackground = true,
  hideScrollBar = true,
  horizontalScrollDisabled = true,
  isBounceEnabled = true,
  listener = function(e) end
}

local scroll_view = widget.newScrollView( config )

local function onSwitchPress( event )
  image_visible = event.target.isOn
end

local textBut = display.newText( 'Показывать иллюстрации:', 250, 50, font, 30 )

local but = widget.newSwitch {
  width = 75, height = 75,
  x = 500, y = 50,
  style = "checkbox",
  onPress = onSwitchPress,
}

display.setDefault( "magTextureFilter", "nearest")

local function read_file( file_config )
  local file = io.open( path, 'rb' )

  if file then
    local data = file:read('*a')
    io.close( file )

    local path
    local path_file

    if file_config.new_folder then
      lfs.chdir( system.pathForFile( '', system.DocumentsDirectory ) )
      lfs.mkdir( file_config.new_folder )
      path = system.pathForFile( file_config.new_folder .. '/' .. file_config.new_file .. file_config.new_type, system.DocumentsDirectory )
      path_file = file_config.new_folder .. '/' .. file_config.new_file .. file_config.new_type
    else
      path = system.pathForFile( file_config.new_file .. file_config.new_type, system.DocumentsDirectory )
      path_file = file_config.new_file .. file_config.new_type
    end

    local file = io.open( path, 'wb' )

    if file then
      file:write( data )
      io.close( file )

      Runtime:removeEventListener( "key", onKeyEventFileSelectDialog )
      group_self.isVisible = true
      file_config.listener({
        import = true,
        path = path_file,
      })
    end
  else
    Runtime:removeEventListener( "key", onKeyEventFileSelectDialog )
    group_self.isVisible = true
    file_config.listener({
      import = false
    })
  end
end

local function set_interface( file_config )
  local function onTouch(e)
    if e.phase == "moved" then
      local dy = math.abs( ( e.y - e.yStart ) )
      if ( dy > 10 ) then
        scroll_view:takeFocus( e )
        e.target:setFillColor( 0.15, 0.15, 0.2 )
      end
    elseif e.phase == 'began' then
      display.getCurrentStage():setFocus( e.target )
      e.target:setFillColor( 0.5 )
    elseif e.phase == 'ended' or e.phase == 'cancelled' then
      display.getCurrentStage():setFocus( nil )
      files = {}
      folders = {}
      scroll_view:remove(files_and_folders_group)
      files_and_folders_group:removeSelf()
      files_and_folders_group = display.newGroup()
      last_position_y = 100
      scroll_height = 0
      if e.target.type == 'folder' then
        if e.target.text == '..' then
          local sim_find = utf8.find(utf8.reverse(path), '\\', 1, true)
          if sim_find then
            path = utf8.reverse(utf8.sub(utf8.reverse(path), sim_find+1, utf8.len(path)))
          end
        else
          path = path .. '\\' .. e.target.text
        end
        read_folders_and_files( file_config )
      elseif e.target.type == 'file' then
        path = path .. '\\' .. e.target.text
        read_file( file_config )
      end
    end
    return true
  end
  if #folders == 0 and #files == 0 then
    folders[1] = '..'
  end
  for i = 1, #folders do
    local picture = display.newImage( files_and_folders_group, 'folder.png' )
    picture.x = 80
    picture.y = last_position_y
    picture.width = 80
    picture.height = 80

    local target = display.newRoundedRect( files_and_folders_group, display.contentCenterX, last_position_y, 400, 100, 30 )
    target.text = folders[i]
    target.type = 'folder'
    target:addEventListener( 'touch', onTouch )
    target:setFillColor( 0.15, 0.15, 0.2 )

    display.newText({
      parent = files_and_folders_group,
      text = folders[i],
      x = display.contentCenterX,
      y = last_position_y,
      font = font,
      fontSize = 45,
      width = 360,
      height = 50
    })

    scroll_height = scroll_height + 100 + 50
    last_position_y = last_position_y + 150
  end
  for i = 1, #files do
    local picture
    local data
    local image_path = path .. '/' .. files[i]

    if image_visible then

      local image_file = io.open( image_path, 'rb' )

      if image_file then
        data = image_file:read('*a')
        io.close(image_file)
      end

      local random_name = tostring(math.random(111111111, 999999999)) .. '.jpg'
      local image_file = io.open( system.pathForFile( random_name, system.TemporaryDirectory ), 'wb' )

      if image_file then
        image_file:write(data)
        io.close(image_file)
      end

      pcall(function()
        picture = display.newImage( files_and_folders_group, random_name, system.TemporaryDirectory )
      end)
    end

    if picture then
      local image_formula = picture.width / 120
      picture.width = 120
      picture.height = picture.height / image_formula

      if picture.height > 120 then
        local image_formula = picture.height / 120
        picture.height = 120
        picture.width = picture.width / image_formula
      end
      os.remove( system.pathForFile( random_name, system.TemporaryDirectory ) )
    else
      picture = display.newImage( files_and_folders_group, 'file.png' )
      picture.width = 80
      picture.height = 80
    end

    picture.x = 80
    picture.y = last_position_y

    local target = display.newRoundedRect( files_and_folders_group, display.contentCenterX, last_position_y, 400, 100, 30 )
    target.text = files[i]
    target.type = 'file'
    target:addEventListener( 'touch', onTouch )
    target:setFillColor( 0.15, 0.15, 0.2 )

    display.newText({
      parent = files_and_folders_group,
      text = files[i],
      x = display.contentCenterX,
      y = last_position_y,
      font = font,
      fontSize = 45,
      width = 360,
      height = 50
    })

    scroll_height = scroll_height + 100 + 50
    last_position_y = last_position_y + 150
  end
  scroll_height = scroll_height + 50
  scroll_view:insert(files_and_folders_group)
  scroll_view:setScrollHeight(scroll_height)
  scroll_view:scrollTo('top', {time=0})
end

function onKeyEventFileSelectDialog( event )
  if event.keyName == 'back' then
    if event.phase == 'down' then
      files = {}
      folders = {}
      scroll_view:remove(files_and_folders_group)
      files_and_folders_group:removeSelf()
      files_and_folders_group = display.newGroup()
      last_position_y = 100
      scroll_height = 0
      Runtime:removeEventListener( "key", onKeyEventFileSelectDialog )
      group_self.isVisible = true
      file_listener({
        import = false
      })
    end
  end
end

function read_folders_and_files( file_config )
  for file in lfs.dir( path ) do
    if file ~= '.' then
      if lfs.attributes( path .. '/' .. file, "mode" ) == "directory" then
        folders[#folders+1] = file
      else
        for i = 1, #file_config.type do
          if utf8.reverse(utf8.sub(utf8.reverse(path .. '/' .. file), 1, utf8.len(file_config.type[i]))) == file_config.type[i] then
            files[#files+1] = file
          end
        end
      end
    end
  end
  set_interface( file_config )
end

function fsd.create( file_config, group )
  if not group then group = display.newRect(0,0,0,0) end
  group.isVisible = false
  group_self = group
  path = file_config.path
  file_listener = file_config.listener
  Runtime:addEventListener( "key", onKeyEventFileSelectDialog )
  read_folders_and_files( file_config )
end

return fsd

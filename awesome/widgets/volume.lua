local awful = require("awful")
local wibox = require("wibox")
local clickable_container = require("widgets.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local beautiful = require("beautiful")

local volume_manager = require("components.volume-manager")


local PATH_TO_ICONS = gears.filesystem.get_configuration_dir() .. "/icons/volume/" .. beautiful.name .. "/"


-- ===================================================================
-- Initialization
-- ===================================================================

local widget = wibox.widget {
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   layout = wibox.layout.align.horizontal
}

local widget_button = clickable_container(wibox.container.margin(widget, dpi(5), dpi(5), dpi(5), dpi(5)))
widget_button:buttons(
   gears.table.join(
      awful.button({}, 1, volume_manager.toggle_muted),
      awful.button({}, 3, function () awful.spawn(volume_manager.mixer) end),
      awful.button({}, 4, volume_manager.volume_up),
      awful.button({}, 5, volume_manager.volume_down)
   )
)

widget_button.tooltip = awful.tooltip({ objects = { widget_button },})

local volume_change = function(volume)
   local icon_name
   local msg = string.format("%d%%", volume)
   if (volume > 40) then
      icon_name = "volume"
   elseif (volume > 0) then
      icon_name = "volume-low"
   else
      icon_name = "volume-off"
      msg = "Muted"
   end
   widget.icon:set_image(PATH_TO_ICONS .. icon_name .. ".png")
   widget_button.tooltip:set_text(msg)
end

awesome.connect_signal("volume_change", volume_change, false)

function widget_button:init()
   volume_manager.check_volume(volume_change)

   return self
end


return widget_button:init()
      

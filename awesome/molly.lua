--      ██████╗  █████╗ ███████╗████████╗███████╗██╗
--      ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██║
--      ██████╔╝███████║███████╗   ██║   █████╗  ██║
--      ██╔═══╝ ██╔══██║╚════██║   ██║   ██╔══╝  ██║
--      ██║     ██║  ██║███████║   ██║   ███████╗███████╗
--      ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local gears = require("gears")

local molly = {}


-- ===================================================================
-- Molly setup
-- ===================================================================

molly.layouts = {
   awful.layout.suit.spiral,
   awful.layout.suit.floating,
   awful.layout.suit.max,
}
 

molly.initialize = function()
   -- Import components
   require("components.molly.wallpaper")
   require("components.exit-screen")
   require("components.volume-adjust")

   -- Import panels
--   local left_panel = require("components.molly.left-panel")
   local top_panel = require("components.molly.top-panel")

   -- Set up each screen (add tags & panels)
   awful.screen.connect_for_each_screen(function(s)
      for i = 1, 9, 1
      do
         awful.tag.add(i, {
            icon = gears.filesystem.get_configuration_dir() .. "/icons/tags/molly/" .. i .. ".png",
            icon_only = true,
            layout = molly.layouts[1],
            screen = s,
            selected = i == 1
         })
      end

      -- -- Only add the left panel on the primary screen
      -- if s.index == 1 then
      --    left_panel.create(s)
      -- end

      -- Add the top panel to every screen
      top_panel.create(s)
   end)
end

return molly

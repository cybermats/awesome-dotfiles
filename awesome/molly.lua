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


   local icon_dir = gears.filesystem.get_configuration_dir() .. "/icons/tags/molly/"
   
   -- Set up each screen (add tags & panels)
   awful.screen.connect_for_each_screen(function(s)
      for i = 1, 9, 1
      do
         awful.tag.add(i, {
            icon = icon_dir .. "tag.svg",
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

   -- set initally selected tag to be active
   local initial_tag = awful.screen.focused().selected_tag
   awful.tag.seticon(icon_dir .. "tag.svg", initial_tag)

      -- updates tag icons
   local function update_tag_icons()
      -- get a list of all tags
      local atags = awful.screen.focused().tags

      -- update each tag icon
      for i, t in ipairs(atags) do
         -- don't update active tag icon
         if t == awful.screen.focused().selected_tag then
            goto continue
         end
         -- if the tag has clients use busy icon
         for _ in pairs(t:clients()) do
            awful.tag.seticon(icon_dir .. "tag-busy.svg", t)
            goto continue
         end
         -- if the tag has no clients use regular inactive icon
         awful.tag.seticon(icon_dir .. "tag-inactive.svg", t)

         ::continue::
      end
   end

   -- Update tag icons when tag is switched
   tag.connect_signal("property::selected", function(t)
      -- set newly selected tag icon as active
      awful.tag.seticon(icon_dir .. "tag.svg", t)
      update_tag_icons()
   end)
   -- Update tag icons when a client is moved to a new tag
   tag.connect_signal("tagged", function(c)
      update_tag_icons()
   end)

   
end

return molly

--      ████████╗ █████╗  ██████╗     ██╗     ██╗███████╗████████╗
--      ╚══██╔══╝██╔══██╗██╔════╝     ██║     ██║██╔════╝╚══██╔══╝
--         ██║   ███████║██║  ███╗    ██║     ██║███████╗   ██║
--         ██║   ██╔══██║██║   ██║    ██║     ██║╚════██║   ██║
--         ██║   ██║  ██║╚██████╔╝    ███████╗██║███████║   ██║
--         ╚═╝   ╚═╝  ╚═╝ ╚═════╝     ╚══════╝╚═╝╚══════╝   ╚═╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local capi = {button = button}
local clickable_container = require('widgets.clickable-container')
local modkey = require('keys').modkey

-- define module table
local tag_list = {}


-- ===================================================================
-- Widget Creation Functions
-- ===================================================================


-- Create buttons
local function create_buttons(buttons, object)
   if buttons then
      local btns = {}
      for _, b in ipairs(buttons) do
         -- Create a proxy button object: it will receive the real
         -- press and release events, and will propagate them to the
         -- button object the user provided, but with the object as
         -- argument.
         local btn = capi.button {modifiers = b.modifiers, button = b.button}
         btn:connect_signal('press',
            function()
               b:emit_signal('press', object)
            end
         )
         btn:connect_signal('release',
            function()
               b:emit_signal('release', object)
            end
         )
         btns[#btns + 1] = btn
      end

      return btns
   end
end

-- Update the taglist
local function list_update(w, buttons, label, data, objects)
   -- update the widgets, creating them if needed
   w:reset()
   for i, o in ipairs(objects) do
      local cache = data[o]
      local ib, tb, bgb, tbm, ibm, l, bg_clickable
      if cache then
         ib = cache.ib
         tb = cache.tb
         bgb = cache.bgb
         tbm = cache.tbm
         ibm = cache.ibm
      else
         local icondpi = 2
         ib = wibox.widget.imagebox()
         tb = wibox.widget.textbox()
         bgb = wibox.container.background()
         tbm = wibox.container.margin(tb, dpi(4), dpi(16))
         ibm = wibox.container.margin(ib, dpi(icondpi), dpi(icondpi), dpi(icondpi), dpi(icondpi))
         l = wibox.layout.fixed.horizontal()
         bg_clickable = clickable_container()

         -- All of this is added in a fixed widget
         l:fill_space(true)
         l:add(ibm)
         bg_clickable:set_widget(l)

         -- And all of this gets a background
         bgb:set_widget(bg_clickable)

         bgb:buttons(create_buttons(buttons, o))

         data[o] = {
            ib = ib,
            tb = tb,
            bgb = bgb,
            tbm = tbm,
            ibm = ibm
         }
      end

      local text, bg, bg_image, icon, args = label(o, tb)
      args = args or {}

      bgb:set_bg(bg)
      if type(bg_image) == 'function' then
         -- TODO: Why does this pass nil as an argument?
         bg_image = bg_image(tb, o, nil, objects, i)
      end

      bgb:set_bgimage(bg_image)
      if icon then
         ib.image = icon
      else
         ibm:set_margins(0)
      end

      bgb.shape = args.shape
      bgb.shape_border_width = args.shape_border_width
      bgb.shape_border_color = args.shape_border_color

      w:add(bgb)
   end
end

-- create the tag list widget
tag_list.create = function(s)
   return awful.widget.taglist(
      s,
      awful.widget.taglist.filter.all,
      awful.util.table.join(
         awful.button({}, 1,
            function(t)
               t:view_only()
            end
         ),
         awful.button({modkey}, 1,
            function(t)
               if client.focus then
                  client.focus:move_to_tag(t)
                  t:view_only()
               end
            end
         ),
         awful.button({}, 3,
            awful.tag.viewtoggle
         ),
         awful.button({modkey}, 3,
            function(t)
               if client.focus then
                  client.focus:toggle_tag(t)
               end
            end
         ),
         awful.button({}, 4,
            function(t)
               awful.tag.viewprev(t.screen)
            end
         ),
         awful.button({}, 5,
            function(t)
               awful.tag.viewnext(t.screen)
            end
         )
      ),
      {},
      list_update,
--      wibox.layout.fixed.vertical()
      wibox.layout.fixed.horizontal()
   )
end

return tag_list

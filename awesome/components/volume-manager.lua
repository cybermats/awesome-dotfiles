local awful = require("awful")
local pulse = require("pulseaudio_dbus")

local M = {}

M.mixer = "pavucontrol"

function M.volume_up()
   awful.spawn("pamixer -u -i 5")
end

function M.volume_down()
   awful.spawn("pamixer -u -d 5")
end

function M.toggle_muted()
   awful.spawn("pamixer -t")
end


function M.check_volume(callback)
   awful.spawn.easy_async_with_shell(
      "sleep .1 && pamixer --get-mute --get-volume",
      function(stdout)
	 local vol_str = stdout
	 local vol_mute = "false"
	 local first_space = stdout:find(" ")
	 if first_space then
	    volume_mute = stdout:sub(0, first_space - 1)
	    vol_str = stdout:sub(first_space + 1):gsub('[%c%s]', '')
	 end

	 local vol = volume_mute == "false" and tonumber(vol_str) or 0
	 callback(vol)
      end,
      false
   )
end   




function M:volume_changed()
   function callback(volume)
      awesome.emit_signal("volume_change", volume)
   end
   M.check_volume(callback)
end

function M:connect_device(device)
   if not device then
      return
   end

   if device.signals.VolumeUpdated then
      device:connect_signal(
	 function (this, volume)
	    self:volume_changed()
	 end,
	 "VolumeUpdated"
      )
   end
   
   if device.signals.MuteUpdated then
      device:connect_signal(
	 function (this, volume)
	    self:volume_changed()
	 end,
	 "MuteUpdated"
      )
   end
end


function M:init()
   local status, address = pcall(pulse.get_address)
   if not status then
      naughty.notify(
	 {
	    preset = naughty.config.presets.critical,
	    title = "Error while loading the PulseAudio widget",
	    text = address
	 }
      )
      return self
   end

   self.connection = pulse.get_connection(address)
   self.core = pulse.get_core(self.connection)

   self.core:ListenForSignal("org.PulseAudio.Core1.Device.VolumeUpdated", {})
   self.core:ListenForSignal("org.PulseAudio.Core1.Device.MuteUpdated", {})

   self.core:ListenForSignal("org.PulseAudio.Core1.NewSink", {
				self.core.object_path})
   self.core:connect_signal(
      function (_, newsink)
	 self:connect_device(self.sink)
      end,
      "NewSink"
   )

   for _, sink_path in ipairs(self.core:get_sinks()) do
      local sink = pulse.get_device(self.connection, sink_path)
      self:connect_device(sink)
   end

   self.__index = self

   return self
end

return M:init()
   
   

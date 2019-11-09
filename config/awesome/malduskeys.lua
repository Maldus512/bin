require("maldus")
local awful = require("awful")
local gears = require("gears")
local malduskeys = {}

local modkey = "Mod4"
local modkeyAlt = "Mod1"
local modkeyCtrl = "Control"
local movement = 32

malduskeys.globalkeys = gears.table.join(
                            awful.key({modkeyAlt, modkeyCtrl}, "n", function()
        awful.spawn("/home/maldus/bin/change_wallpaper")
    end), awful.key({modkeyAlt, modkeyCtrl}, "m", function()
        awful.spawn("/home/maldus/bin/picture_wallpaper")
    end), awful.key({modkeyAlt, modkeyCtrl}, "l",
                    function() awful.spawn("rofi -show run -theme purple") end),
                            awful.key({modkeyAlt, modkeyCtrl}, "]", function()
        awful.screen.focus_relative(-1)
    end),

                            awful.key({modkeyCtrl, modkeyAlt}, "t",
                                      function() awful.spawn(terminal) end, {
        description = "open a terminal",
        group = "launcher"
    }))

malduskeys.clientkeys = gears.table.join(
                            awful.key({modkey, modkeyCtrl}, "Right", function(c)
        relativeMove(c, movement, 0)
    end), awful.key({modkey, modkeyCtrl}, "Left",
                    function(c) relativeMove(c, -movement, 0) end),
                            awful.key({modkey, modkeyCtrl}, "Down", function(c)
        relativeMove(c, 0, movement)
    end), awful.key({modkey, modkeyCtrl}, "Up",
                    function(c) relativeMove(c, 0, -movement) end),
                            awful.key({modkey, modkeyAlt}, "Right", function(c)
        relativeResize(c, movement, 0)
    end), awful.key({modkey, modkeyAlt}, "Left",
                    function(c) relativeResize(c, -movement, 0) end),
                            awful.key({modkey, modkeyAlt}, "Down", function(c)
        relativeResize(c, 0, movement)
    end), awful.key({modkey, modkeyAlt}, "Up",
                    function(c) relativeResize(c, 0, -movement) end),
                            awful.key({modkey}, "Right", function(c)
        horizontalSnap(c, "right")
    end),
                            awful.key({modkey}, "Left",
                                      function(c) horizontalSnap(c, "left") end),
                            awful.key({modkey}, "Down",
                                      function(c) verticalSnap(c, "down") end),
                            awful.key({modkey}, "Up",
                                      function(c) verticalSnap(c, "up") end),
                            awful.key({modkeyAlt, modkeyCtrl, "Shift"}, "[",
                                      function(c) c:move_to_screen() end, {
        description = "move to screen",
        group = "client"
    }), awful.key({modkeyAlt, modkeyCtrl, "Shift"}, "]",
                  function(c) c:move_to_screen(c.screen.index - 1) end,
                  {description = "move to screen", group = "client"}))

return malduskeys

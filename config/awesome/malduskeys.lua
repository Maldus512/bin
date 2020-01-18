require("maldus")
local awful = require("awful")
local gears = require("gears")
local mk = {}

mk.modkey = "Mod4"
mk.modkeyAlt = "Mod1"
mk.modkeyCtrl = "Control"
mk.movement = 32
mk.terminal = "mate-terminal"
mk.Right = 'Right'
mk.Left = 'Left'
mk.Up = 'Up'
mk.Down = 'Down'


function mk:configDirections(left, down, up, right)
    if left then self.Left = left end
    if right then self.Right = right end
    if down then self.Down = down end
    if up then self.Up = up end
end

function mk:globalkeys() 
    return awful.util.table.join(
                            awful.key({mk.modkeyAlt, mk.modkeyCtrl}, "n", function()
        awful.spawn("/home/maldus/bin/change_wallpaper")
    end), awful.key({mk.modkeyAlt, mk.modkeyCtrl}, "m", function()
        awful.spawn("/home/maldus/bin/picture_wallpaper")
    end), awful.key({mk.modkeyAlt, mk.modkeyCtrl}, "l",
                    function() awful.spawn("rofi -show run -theme purple") end),
                            awful.key({mk.modkeyAlt, mk.modkeyCtrl}, "]", function()
        awful.screen.focus_relative(-1)
    end),

                            awful.key({mk.modkeyCtrl, mk.modkeyAlt}, "t",
                                      function() awful.spawn(mk.terminal) end, {
        description = "open a terminal",
        group = "launcher"
    }))
end

function mk:clientkeys()
    return awful.util.table.join(
        awful.key({mk.modkeyAlt}, "F4", function(c) c:kill() end),
                            awful.key({mk.modkey, mk.modkeyCtrl}, mk.Right, function(c)
        relativeMove(c, mk.movement, 0)
    end), awful.key({mk.modkey, mk.modkeyCtrl}, mk.Left,
                    function(c) relativeMove(c, -mk.movement, 0) end),

                            awful.key({mk.modkey, mk.modkeyCtrl}, mk.Down, function(c)
        relativeMove(c, 0, mk.movement)
    end), awful.key({mk.modkey, mk.modkeyCtrl}, mk.Up,
                    function(c) relativeMove(c, 0, -mk.movement) end),
                            awful.key({mk.modkey, mk.modkeyAlt}, mk.Right, function(c)
        relativeResize(c, mk.movement, 0)
    end), awful.key({mk.modkey, mk.modkeyAlt}, mk.Left,
                    function(c) relativeResize(c, -mk.movement, 0) end),
                            awful.key({mk.modkey, mk.modkeyAlt}, mk.Down, function(c)
        relativeResize(c, 0, mk.movement)
    end), awful.key({mk.modkey, mk.modkeyAlt}, mk.Up,
                    function(c) relativeResize(c, 0, -mk.movement) end),
                            awful.key({mk.modkey}, mk.Right, function(c)
        horizontalSnap(c, "right")
    end),
                            awful.key({mk.modkey}, mk.Left,
                                      function(c) horizontalSnap(c, "left") end),
                            awful.key({mk.modkey}, mk.Down,
                                      function(c) verticalSnap(c, "down") end),
                            awful.key({mk.modkey}, mk.Up,
                                      function(c) verticalSnap(c, "up") end),
                            awful.key({mk.modkeyAlt, mk.modkeyCtrl, "Shift"}, "[",
                                      function(c) c:move_to_screen() end, {
        description = "move to screen",
        group = "client"
    }), awful.key({mk.modkeyAlt, mk.modkeyCtrl, "Shift"}, "]",
                  function(c) c:move_to_screen(c.screen.index - 1) end,
                  {description = "move to screen", group = "client"}))
end

return mk

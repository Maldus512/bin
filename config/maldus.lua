-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local switcher = require("awesome-switcher")
local common = require("awful.widget.common")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:

function relativeMove(c, x, y)
    local g = c:geometry()
    g.x = g.x + x
    g.y = g.y + y
    g.width = 0
    g.height = 0
    awful.placement.top_left(c, {honor_workarea=false, offset=g})
end

function relativeResize(c, w, h)
    local g = c:geometry()
    g.width = w
    g.height = h 
    awful.placement.top_left(c, {honor_workarea=false, offset=g})
end

function verticalSnap(c, direction)
    local axis = 'horizontally'
    local h = c.height
    local w = c.width
    local g = c:geometry()
    local wh = c.screen.workarea.height
    local ww = c.screen.workarea.width
    local ypos = {
        ["down"] = wh/2,
        ["up"] = 0,
    }
    local p = {
        ["down"] = awful.placement.bottom,
        ["up"] = awful.placement.top,
    }
    -- If it's already horizontally maximized just move it to the right
    if direction == "up" and ((w > ww-5 and w < ww+5) or c.maximized_horizontal) 
        and c.x < 5 and c.y < 5 and not c.maximized then
        c.maximized = true
    elseif (h > wh-5 and h < wh+5)
        or c.maximized_vertical or c.maximized then
        if c.maximized then
            c.maximized = false
            g.height = 0 ---wh/2
        else
            g.height = -wh/2
        end
        g.y = ypos[direction]
        g.width = 0
        local f = awful.placement.top_left
        f(client.focus, {honor_workarea=true, offset=g})
    -- Otherwise snap it to the right column
    else 
        c.maximized = false
        local f = awful.placement.scale
            + p[direction]
            + (axis and awful.placement['maximize_'..axis] or nil)
        f(client.focus, {honor_workarea=true, to_percent = 0.5})
        --c.maximized_horizontal = true
    end
end


function horizontalSnap(c, direction)
    local axis = 'vertically'
    local w = c.width
    local g = c:geometry()
    local ww = c.screen.workarea.width
    local xpos = {
        ["right"] = ww/2,
        ["left"] = 0,
    }
    local p = {
        ["right"] = awful.placement.right,
        ["left"] = awful.placement.left,
    }
    -- If it's already horizontally maximized just move it to the right
    if (w > ww-5 and w < ww+5)
        or c.maximized_horizontal then
        g.x = xpos[direction]
        g.width = -ww/2
        g.height = 0
        local f = awful.placement.top_left
        f(client.focus, {honor_workarea=true, offset=g})
    -- Otherwise snap it to the right column
    else 
        local f = awful.placement.scale
            + p[direction]
            + (axis and awful.placement['maximize_'..axis] or nil)
        f(client.focus, {honor_workarea=true, to_percent = 0.5})
        --c.maximized_vertical = true
    end
end

function gridMoveWindow(direction)
    local rows = 4
    local columns = 4
    local i = awful.tag.getidx() - 1
    action = {
        ["right"] = (i + columns) % (rows * columns) + 1,
        ["left"] = (i - columns) % (rows * columns) + 1,
        ["up"] = (math.ceil((i + 1) / columns) - 1) * columns + ((i - 1) % columns) + 1,
        ["down"] = (math.ceil((i + 1) / columns) - 1) * columns + ((i + 1) % columns) + 1,
    }
    local j = action[direction]

    local screen = mouse.screen
    local tag = awful.tag.gettags(screen)[j]
    if tag then
        awful.client.movetotag(tag)
        awful.tag.viewonly(tag)
    end
end

function grid(direction)
    local rows = 4
    local columns = 4
    local i = awful.tag.getidx() - 1
    action = {
        ["right"] = (i + columns) % (rows * columns) + 1,
        ["left"] = (i - columns) % (rows * columns) + 1,
        ["up"] = (math.ceil((i + 1) / columns) - 1) * columns + ((i - 1) % columns) + 1,
        ["down"] = (math.ceil((i + 1) / columns) - 1) * columns + ((i + 1) % columns) + 1,
    }
    local j = action[direction]

    local screen = mouse.screen
    local tag = awful.tag.gettags(screen)[j]
    if tag then
        awful.tag.viewonly(tag)
    end
end

-- Notifications

--[[naughty.config.notify_callback = function(args)
    if args.width < 128 then
        args.width = 128
    end
    return args
end
]]--

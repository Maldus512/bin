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
local tolerance = 5 
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:

function wiboxNoTags(s)
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
        },
    }
end

function deltageometry(c)
    local screeng = c.screen.geometry
    local g = c:geometry()
    g.x = g.x - screeng.x
    g.y = g.y - screeng.y
    return g
end

function relativeMove(c, x, y)
    c:relative_move(x, y, 0,0)
end

function relativeResize(c, w, h)
    c:relative_move(0,0,w,h)
end

function verticalSnap(c, direction)
    local axis = 'horizontally'
    local h = c.height
    local w = c.width
    local g = deltageometry(c)
    local wh = c.screen.workarea.height
    local ww = c.screen.workarea.width
    local basex = c.screen.workarea.x
    local basey = c.screen.workarea.y
    local ypos = {
        ["down"] = wh/2,
        ["up"] = 0,
    }
    local p = {
        ["down"] = awful.placement.bottom,
        ["up"] = awful.placement.top,
    }
    -- If it's already horizontally maximized just move it to the right
    if direction == "up" and ((w > ww-tolerance and w < ww+tolerance) or c.maximized_horizontal) 
        --and g.y < 5 and not c.maximized then
        and g.x - basex < 5 and g.y - basey < 5 and not c.maximized then
        c.maximized = true
    elseif (h > wh-tolerance and h < wh+tolerance)
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
    local g = deltageometry(c)
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
    if (w > ww-tolerance and w < ww+tolerance)
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

function gridMoveWindow(direction, rows, columns)
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

function grid(direction, rows, columns)
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

function biggest_client(clients)
    local max = 0
    local index = 0
    for k,v in pairs(clients) do
        if v.width * v.height > max then
            max = v.width*v.height
            index = k
        end
    end
    return clients[index]
end

function scale(x, max, resize)
    local res = math.floor((x*resize)/max)
    if res < 0 then
        return 0
    else
        return res
    end
end

function scaled_client(geometry, tag, container)
    local newgeom = {}
    print(geometry.x, geometry.y, geometry.width, geometry.height, tag.width, tag.height, container.width, container.height)
    newgeom.x = scale(geometry.x, tag.width, container.width)
    newgeom.y = scale(geometry.y, tag.height, container.height)
    newgeom.width = scale(geometry.width, tag.width, container.width)
    newgeom.height = scale(geometry.height, tag.height, container.height)

    return newgeom
end

-- Notifications

--[[naughty.config.notify_callback = function(args)
    if args.width < 128 then
        args.width = 128
    end
    return args
end
]]--

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
require("maldus")
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
local xrandr = require("xrandr")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local drows = 4
local dcols = 4

-- if screen.count() > 1 then
-- drows = 2;
-- dcols = 5;
-- end

switcher.settings.preview_box_delay = 10
switcher.settings.ignore_list = {"conky", "Conky", "lxpanel", "tilda", "Tilda"}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init("/home/maldus/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "konsole"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
modkeyAlt = "Mod1"
modkeyCtrl = "Control"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {awful.layout.suit.floating}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    {"hotkeys", function() return false, hotkeys_popup.show_help end},
    {"manual", terminal .. " -e man awesome"},
    {"edit config", editor_cmd .. " " .. awesome.conffile},
    {"restart", awesome.restart}, {"quit", function() awesome.quit() end}
}

gamemenu = {
    {"It Lurks Below", "steam steam://rungameid/697550"},
    {"Dota Underlords", "steam steam://rungameid/1046930"},
    {"Darkest Dungeon", "steam steam://rungameid/262060"},
}

codemenu = {
    {"code", "code"},
    {"gambas3", "gambas3"},
    {"mplabx", "mplab_ide"},
}

internet = {
    {"firefox", "firefox"},
}

mymainmenu = awful.menu({
    items = {
        {"awesome", myawesomemenu, beautiful.awesome_icon},
        {"develop", codemenu},
        {"games", gamemenu},
        {"open terminal", terminal}
    }
})

mylauncher = awful.widget.launcher({
    image = '/home/maldus/.config/awesome/pokeball.png',
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
local menugeom = menubar.geometry
menugeom.height = 50
menubar.geometry = menugeom
menubar.show_categories = false
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                            awful.button({}, 1, function(t) t:view_only() end),
                            awful.button({modkey}, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end), awful.button({}, 3, awful.tag.viewtoggle),
                            awful.button({modkey}, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
    end), awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
                            awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end))

local tasklist_buttons = gears.table.join(
                             awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end), awful.button({}, 4, function() awful.client.focus.byidx(1) end),
                             awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)
    if (screen.count() == 1 or s.index == 1) then
        awful.tag({
            "1 ", "2 ", "3 ", "4 ", "5 ", "6 ", "7 ", "8 ", "9 ", "10", "11",
            "12", "13", "14", "15", "16"
        }, 1, awful.layout.layouts[1])
        s.mysystray = wibox.widget.systray()
        s.mysystray:set_base_size(30)

        local mybatterybar = require("battery")

        s.mytaglist = awful.widget.taglist{
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = taglist_buttons,
            layout = {
                forced_num_rows = 4,
                forced_num_cols = 4,
                layout = wibox.layout.grid.horizontal
            },
            widget_template = {
                {
                    {
                        {id = 'index_role', widget = wibox.widget.textbox},
                        point = {x = 0, y = 0},
                        widget = wibox.container.background
                    },

                    {id = 'manualcanvas', layout = wibox.layout.manual},
                    layout = wibox.layout.stack
                },

                forced_width = 46,
                forced_height = 36,
                id = 'background_role',
                widget = wibox.container.background,
                -- Add support for hover colors and an index label
                create_callback = function(self, c3, index, objects) -- luacheck: no unused args
                    -- self:get_children_by_id('index_role')[1].markup = '<b> '..c3.index..' </b>'
                    self:connect_signal('mouse::enter', function()
                        if self.bg ~= '#8800aa' then
                            self.backup = self.bg
                            self.has_backup = true
                        end
                        self.bg = '#8800aa'
                    end)
                    self:connect_signal('mouse::leave', function()
                        if self.has_backup then
                            self.bg = self.backup
                        end
                    end)
                end,
                update_callback = function(self, c3, index, objects) -- luacheck: no unused args
                    self:get_children_by_id('index_role')[1].markup =
                        '<b> ' .. c3.index .. ' </b>'
                    local clients = c3:clients()
                    local canvas = self:get_children_by_id('manualcanvas')[1]
                    canvas:reset()

                    for k, c in pairs(clients) do
                        if c.class ~= 'Conky' then
                            local cg = deltageometry(c)
                            cg.height = cg.height > 100 and cg.height or 100
                            cg.width = cg.width > 130 and cg.width or 130
                            local g = scaled_client(cg, c.screen.geometry,
                                                    {width = 46, height = 36})
                            local w = wibox.container.margin()
                            w:setup{
                                bottom = 1,
                                top = 1,
                                left = 2,
                                right = 2,
                                color = beautiful.border_focus, -- '#222288',
                                id = 'iconborder',
                                widget = wibox.container.margin,
                                {
                                    widget = wibox.container.background,
                                    bg = "#00000030",
                                    {
                                        id = 'clienticon',
                                        widget = awful.widget.clienticon
                                        -- layout = wibox.layout.manual,
                                    }

                                }
                            }
                            local clienticon =
                                w:get_children_by_id('clienticon')[1]
                            clienticon.client = c
                            w.forced_width = g.width
                            w.forced_height = g.height
                            print(w.forced_width, w.forced_height)
                            canvas:add_at(w, g)
                        end
                    end
                    canvas:emit_signal("widget::updated")
                end
            }
        }

        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist{
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons,
            layout = {
                spacing = 2,
                forced_num_cols = 6,
                layout = wibox.layout.grid.vertical
            },
            widget_template = {
                {
                    {id = 'clienticon', widget = awful.widget.clienticon},
                    margins = 2,
                    widget = wibox.container.margin
                },
                id = 'background_role',
                forced_width = 30,
                forced_height = 30,
                widget = wibox.container.background,
                create_callback = function(self, c, index, objects) -- luacheck: no unused
                    self:get_children_by_id('clienticon')[1].client = c
                end
            }
        }

        -- Create the wibox
        s.mywibox = awful.wibar({
            position = "right",
            height = 337,
            width = 184,
            stretch = false,
            bg = beautiful.bg_normal .. "70",
            screen = s
        })
        awful.placement.bottom_right(s.mywibox)

        -- Add widgets to the wibox
        s.mywibox:setup{
            layout = wibox.layout.align.vertical,
            {
                s.mysystray,
                -- wibox.widget.separator(),
                s.mytasklist,
                layout = wibox.layout.fixed.vertical
            },
            wibox.widget.separator(),
            {s.mytaglist, mybatterybar, layout = wibox.layout.fixed.vertical}
            -- mylauncher,
        }
    else
        awful.tag({"extra"..s.index}, s.index, awful.layout.layouts[1])
        wiboxNoTags(s)
    end
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3,
                                           function() mymainmenu:toggle() end),
                              awful.button({}, 4, awful.tag.viewnext),
                              awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(awful.key({modkey, modkeyAlt}, "x",
                                        function() xrandr.xrandr() end),
                              awful.key({modkeyAlt, modkeyCtrl}, "n", function()
    awful.spawn("/home/maldus/bin/change_wallpaper")
end), awful.key({modkeyAlt, modkeyCtrl}, "m", function()
    awful.spawn("/home/maldus/bin/picture_wallpaper")
end), awful.key({modkeyAlt, modkeyCtrl}, "l",
                function() awful.spawn("rofi -show run -theme purple") end),
                              awful.key({}, "Scroll_Lock", function()
    awful.util.spawn("physlock -d")
end), awful.key({modkeyAlt, modkeyCtrl}, "Up",
                function() grid("up", drows, dcols) end),
                              awful.key({modkeyAlt, modkeyCtrl}, "Down",
                                        function() grid("down", drows, dcols) end),
                              awful.key({modkeyAlt, modkeyCtrl}, "Left",
                                        function() grid("left", drows, dcols) end),
                              awful.key({modkeyAlt, modkeyCtrl}, "Right",
                                        function() grid("right", drows, dcols) end),
                              awful.key({modkeyAlt, modkeyCtrl}, "[", function()
    awful.screen.focus_relative(1)
end), awful.key({modkeyAlt, modkeyCtrl}, "]",
                function() awful.screen.focus_relative(-1) end),

                              awful.key({modkeyAlt, modkeyCtrl, "Shift"}, "Up",
                                        function()
    gridMoveWindow("up", drows, dcols)
end), awful.key({modkeyAlt, modkeyCtrl, "Shift"}, "Down",
                function() gridMoveWindow("down", drows, dcols) end),
                              awful.key({modkeyAlt, modkeyCtrl, "Shift"},
                                        "Left", function()
    gridMoveWindow("left", drows, dcols)
end), awful.key({modkeyAlt, modkeyCtrl, "Shift"}, "Right",
                function() gridMoveWindow("right", drows, dcols) end),
                              awful.key({modkey}, "h", hotkeys_popup.show_help,
                                        {
    description = "show help",
    group = "awesome"
}), awful.key({}, "XF86AudioRaiseVolume",
              function() awful.util.spawn("amixer set Master 4%+") end),
                              awful.key({}, "XF86AudioLowerVolume", function()
    awful.util.spawn("amixer set Master 4%-")
end), awful.key({}, "XF86AudioMute", function()
    awful.util.spawn("amixer -D pulse set Master toggle")
end), awful.key({}, "XF86MonBrightnessDown",
                function() awful.util.spawn("xbacklight -8") end),
                              awful.key({}, "XF86MonBrightnessUp", function()
    awful.util.spawn("xbacklight +8")
end),
-- awful.key({ modkeyAlt, modkeyCtrl          }, "Left",   awful.tag.viewprev,
--         {description = "view previous", group = "tag"}),
-- awful.key({ modkeyAlt, modkeyCtrl          }, "Right",  awful.tag.viewnext,
-- {description = "view next", group = "tag"}),
                              awful.key({modkey}, "Escape",
                                        awful.tag.history.restore, {
    description = "go back",
    group = "tag"
}), awful.key({"Mod1"}, "Tab", function()
    switcher.switch(1, "Mod1", "Alt_L", "Shift", "Tab")
end), awful.key({"Mod1", "Shift"}, "Tab", function()
    switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
end), awful.key({modkey}, "w", function() mymainmenu:show() end,
                {description = "show main menu", group = "awesome"}),

-- Layout manipulation
                              awful.key({modkey, "Shift"}, "j", function()
    awful.client.swap.byidx(1)
end, {description = "swap with next client by index", group = "client"}),
                              awful.key({modkey, "Shift"}, "k", function()
    awful.client.swap.byidx(-1)
end, {description = "swap with previous client by index", group = "client"}),
                              awful.key({modkey, "Control"}, "j", function()
    awful.screen.focus_relative(1)
end, {description = "focus the next screen", group = "screen"}),
                              awful.key({modkey, "Control"}, "k", function()
    awful.screen.focus_relative(-1)
end, {description = "focus the previous screen", group = "screen"}),
                              awful.key({modkey}, "u",
                                        awful.client.urgent.jumpto, {
    description = "jump to urgent client",
    group = "client"
}), -- Standard program
awful.key({modkeyCtrl, modkeyAlt}, "t", function() awful.spawn(terminal) end,
          {description = "open a terminal", group = "launcher"}),
                              awful.key({modkey, "Control"}, "r",
                                        awesome.restart, {
    description = "reload awesome",
    group = "awesome"
}), awful.key({modkey, "Shift"}, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

                              awful.key({modkey, "Control"}, "n", function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
        client.focus = c
        c:raise()
    end
end, {description = "restore minimized", group = "client"}), -- Prompt
awful.key({modkey}, "r",
          function() awful.spawn("rofi -show run -theme purple") end,
          {description = "run prompt", group = "launcher"}),
                              awful.key({modkey}, "p", function()
    awful.spawn("rofi -show run -theme purple")
end, {description = "run prompt", group = "launcher"}) -- Menubar
-- awful.key({ modkey }, "p", function() menubar.show() end, {description = "show the menubar", group = "launcher"})
)

local movement = 32

clientkeys = gears.table.join(
                 awful.key({modkey, modkeyCtrl}, "Right",
                           function(c) relativeMove(c, movement, 0) end),
                 awful.key({modkey, modkeyCtrl}, "Left",
                           function(c) relativeMove(c, -movement, 0) end),
                 awful.key({modkey, modkeyCtrl}, "Down",
                           function(c) relativeMove(c, 0, movement) end),
                 awful.key({modkey, modkeyCtrl}, "Up",
                           function(c) relativeMove(c, 0, -movement) end),
                 awful.key({modkey, modkeyAlt}, "Right",
                           function(c) relativeResize(c, movement, 0) end),
                 awful.key({modkey, modkeyAlt}, "Left",
                           function(c) relativeResize(c, -movement, 0) end),
                 awful.key({modkey, modkeyAlt}, "Down",
                           function(c) relativeResize(c, 0, movement) end),
                 awful.key({modkey, modkeyAlt}, "Up",
                           function(c) relativeResize(c, 0, -movement) end),
    -- awful.key({ }, "F11", function(c) c.maximized = not c.maximized end),
                 awful.key({modkey}, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, {description = "toggle fullscreen", group = "client"}),
                 awful.key({modkeyAlt}, "F4", function(c) c:kill() end,
                           {description = "close", group = "client"}),
                 awful.key({modkey, "Control"}, "space",
                           awful.client.floating.toggle,
                           {description = "toggle floating", group = "client"}),
                 awful.key({modkey, "Control"}, "Return",
                           function(c) c:swap(awful.client.getmaster()) end,
                           {description = "move to master", group = "client"}),
                 awful.key({modkey}, "t", function(c) c.ontop = not c.ontop end,
                           {
        description = "toggle keep on top",
        group = "client"
    }), awful.key({modkey}, "s", function(c) c.sticky = not c.sticky end),
                 awful.key({modkey}, "Right",
                           function(c) horizontalSnap(c, "right") end),
                 awful.key({modkey}, "Left",
                           function(c) horizontalSnap(c, "left") end),
                 awful.key({modkey}, "Down",
                           function(c) verticalSnap(c, "down") end), awful.key(
                     {modkey}, "Up", function(c) verticalSnap(c, "up") end),
                 awful.key({modkey}, "n", function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
    end, {description = "minimize", group = "client"}),
                 awful.key({modkey}, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, {description = "(un)maximize vertically", group = "client"}),
                 awful.key({modkey, "Shift"}, "m", function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, {description = "(un)maximize horizontally", group = "client"}),
                 awful.key({modkeyAlt, modkeyCtrl, "Shift"}, "[",
                           function(c) c:move_to_screen() end,
                           {description = "move to screen", group = "client"}),
                 awful.key({modkeyAlt, modkeyCtrl, "Shift"}, "]",
                           function(c) c:move_to_screen( c.screen.index-1) end,
                           {description = "move to screen", group = "client"}))

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
    client.focus = c
    c:raise()
end), awful.button({modkey}, 1, awful.mouse.client.move), awful.button({modkey},
                                                                       3,
                                                                       awful.mouse
                                                                           .client
                                                                           .resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    {
        rule_any = {{class = {"sun-awt-X11-XWindowPeer", "MPLAB X IDE v5.05"}}},
        properties = {
            titlebars_enabled = false,
            placement = awful.placement.next_to_mouse
        },
        callback = function(c) print("trovato mplab window") end
    }, -- All clients will match this rule.
    {
        rule = {},
        -- except_any = { { class = {"sun-awt-X11-XWindowPeer"},} },
        except_any = {
            type = {"dialog"},
            role = {"AlarmWindow", "pop-up"},
            class = {"Dialog"}
        },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            titlebars_enabled = false,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap, -- +awful.placement.centered,
            floating = true,

            callback = function(c)
                if (c.class ~= nil and string.find(c.class, "MPLAB") and
                    string.find(c.type, "dialog")) then
                    local f = awful.placement.top_left
                    local g = c:geometry()
                    if (c.size_hints == nil or c.size_hints.program_position ==
                        nil) then return end
                    g.x = c.size_hints.program_position.x
                    g.y = c.size_hints.program_position.y
                    g.width = 0
                    g.height = 0
                    f(c, {offset = g})
                end
            end
        }
    }, {
        rule = {type = "dialog"},
        properties = {
            focus = awful.client.focus.filter,
            keys = clientkeys,
            titlebars_enabled = false,
            buttons = clientbuttons,
            screen = awful.screen.preferred
        }
    }, -- konsole
    {
        rule_any = {class = {"konsole", "Konsole"}},
        properties = {
            placement = -- awful.placement.no_offscreen+
            awful.placement.no_overlap
        }
    }, {
        rule_any = {class = {"panel", "lxpanel"}},
        properties = {border_width = 0, sticky = true, focusable = false}
    }, {
        rule_any = {class = {"conky", "Conky"}},
        properties = {sticky = true, focusable = false}
    }, {
        rule_any = {class = {"tilda", "Tilda"}, name = {"tilda"}},
        properties = {maximized_vertical = true, maximized_horizontal = true}
    }, -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA", -- Firefox addon DownThemAll.
                "copyq" -- Includes session name in class.
            },
            class = {
                "Arandr", "Gpick", "Kruler", "MessageWin", -- kalarm.
                "Sxiv", "Wpa_gui", "pinentry", "veromix", "xtightvncviewer"
            },

            name = {
                "Event Tester" -- xev.
            },
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        except_any = {{class = {"sun-awt-X11-XWindowPeer"}}},
        properties = {floating = true}
    }

    -- Add titlebars to normal clients and dialogs
    -- { rule_any = {
    --    type = {"dialog" },
    --    role = {"AlarmWindow","pop-up"},
    --    class = {"Dialog"}
    --  }, 
    -- except_any = { { class = {"sun-awt-X11-XWindowPeer"}, },},
    -- properties = { titlebars_enabled = true,}
    -- placement=awful.placement.centered, }
    -- },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and
        not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    c.border_width = 1
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    c.border_width = 1
end)
-- }}}
do
    local cmds = {
        "conky", "nm-applet", -- "ibus-daemon -d",
        -- "lxpanel",
        "syndaemon -i 2.0 -t -K -R -d",
        -- "systemctl --user start wallpaper.timer",
        -- "udiskie",
        -- "cbatticon", 
        "pnmixer", "firefox https://stackoverflow.com/users/4862613/maldus",
        "/home/maldus/bin/change_wallpaper"
    }

    for _, i in pairs(cmds) do awful.util.spawn(i) end
end

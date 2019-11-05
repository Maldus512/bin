local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")

local HOME = os.getenv("HOME")

local battery = wibox.widget{
    {
        max_value = 100,
        value = 100,
        forced_height = 32,
        --forced_width = 100,
        paddings = 4,
        border_width = 4,
        border_color = beautiful.border_color,
        widget = wibox.widget.progressbar,
        id = 'bar',

    },
    {text = '50%', widget = wibox.widget.textbox, id='text', color="#111111"},
    layout = wibox.layout.stack
}

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
--battery_popup = awful.tooltip({objects = {battery_widget}})

-- To use colors from beautiful theme put
-- following lines in rc.lua before require("battery"):
-- beautiful.tooltip_fg = beautiful.fg_normal
-- beautiful.tooltip_bg = beautiful.bg_normal

local function show_battery_warning()
    naughty.notify{
        icon = HOME .. "/.config/awesome/danger.png",
        icon_size=100,
        text = "Huston, we have a problem",
        title = "Battery is dying",
        timeout = 5, hover_timeout = 0.5,
        position = "bottom_right",
        bg = "#FF3030",
        fg = "#EEE9EF",
        width = 300,
    }
end

-- Popup with battery info
-- One way of creating a pop-up notification - naughty.notify
local notification
local function show_battery_status()
    awful.spawn.easy_async([[bash -c 'acpi']],
        function(stdout, _, _, _)
            naughty.destroy(notification)
            notification = naughty.notify{
                text =  stdout,
                title = "Battery status",
                position = "bottom_right",
                timeout = 5, hover_timeout = 0.5,
                width = 300,
            }
        end
    )
end

local last_battery_check = os.time()
local last_status = 'Full'

watch("acpi -i", 5, function(widget, stdout, stderr, exitreason, exitcode)
    local batteryType
    local battery_info = {}
    local capacities = {}
    for s in stdout:gmatch("[^\r\n]+") do
        local status, charge_str, time =
            string.match(s, '.+: (%a+), (%d?%d?%d)%%,?.*')
        if string.match(s, 'rate information') then
            -- ignore such line
        elseif status ~= nil then
            table.insert(battery_info,
                         {status = status, charge = tonumber(charge_str)})
        else
            local cap_str = string.match(s, '.+:.+last full capacity (%d+)')
            table.insert(capacities, tonumber(cap_str))
        end
    end

    local capacity = 0
    for i, cap in ipairs(capacities) do capacity = capacity + cap end

    local charge = 0
    local status
    for i, batt in ipairs(battery_info) do
        if batt.charge >= charge then
            status = batt.status -- use most charged battery status
            -- this is arbitrary, and maybe another metric should be used
        end

        charge = charge + batt.charge * capacities[i]
    end
    charge = charge / capacity
    if status == 'Unknown' then
        status = last_status
    else
        last_status = status
    end

    if (charge >= 0 and charge < 15) then
        if status ~= 'Charging' and os.difftime(os.time(), last_battery_check) >
            180 then
            -- if 5 minutes have elapsed since the last warning
            last_battery_check = os.time()

            show_battery_warning()
        end
    end

    local children = widget:get_all_children()
    local batterywidget = children[1]
    local textwidget = children[2]

    batterywidget.value = charge
    textwidget.markup = [[<span foreground="black"><b> ]] .. charge .. "%</b></span>"

    if status == 'Charging' or status == 'Full' then
        batterywidget.color = "#00dd00"
        batterywidget.background_color = "#118811"
    else
        if charge < 30 then
            batterywidget.color = "#dd0000"
            batterywidget.background_color = "#882211"
        else
            batterywidget.color = "#dddd00"
            batterywidget.background_color = "#888811"
        end
    end
end, battery)

battery:connect_signal("mouse::enter", function() show_battery_status() end)
battery:connect_signal("mouse::leave", function() naughty.destroy(notification) end)

return battery

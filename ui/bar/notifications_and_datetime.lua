local button = require("awful.button")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local naughty = require("naughty")
local wibox = require("wibox")

local helpers = require("helpers")

local border_container = require("ui.widgets.border-container")
local clickable_container = require("ui.widgets.clickable-container")
local text_icon = require("ui.widgets.text-icon")

local function colorize_by_time_of_day(text)
    local hour = tonumber(os.date("%H"))
    local minute = tonumber(os.date("%M"))
    local color

    if (hour > 4 and hour < 8) or (hour >= 17 and hour < 18) then
        color = beautiful.red
    elseif hour >= 8 and hour < 17 then
        color = beautiful.yellow
    elseif hour >= 12 and hour < 14 then
        color = beautiful.moon
    else
        color = beautiful.accent
    end

    return helpers.colorize_text(text, color)
end

local bell = text_icon {
    markup = helpers.colorize_text("\u{e7f4}", beautiful.moon),
    size = 14,
    widget = wibox.widget.textbox
}

naughty.connect_signal(
    "property::suspended", function(_, suspended)
        if suspended then
            bell.markup = helpers.colorize_text("\u{e7f6}", beautiful.accent)
        else
            bell.markup = helpers.colorize_text("\u{e7f4}", beautiful.moon)
        end
    end
)

local datetime = wibox.widget {
    font = beautiful.font_name .. "13",
    format = "%a. %d <b>%I" .. colorize_by_time_of_day(":") .. "%M</b>",
    refresh = 2,
    -- forced_width = dpi(60),
    ellipsize = "none",
    widget = wibox.widget.textclock
}

datetime:connect_signal(
    "widget::redraw_needed", function()
        datetime.format = "%a. %d <b>%I" .. colorize_by_time_of_day(":") .. "%M</b>"
    end
)

local notifs_datetime = clickable_container {
    widget = {
        {
            bell,
            datetime,
            spacing = dpi(4),
            widget = wibox.layout.fixed.horizontal
        },
        left = dpi(4),
        right = dpi(4),
        widget = wibox.container.margin
    },
    shape = helpers.rrect(beautiful.border_radius),
    action = function()
        awesome.emit_signal("notification_center::toggle")
    end
}

awesome.connect_signal(
    "notification_center::visible", function(visible)
        notifs_datetime.bg = visible and beautiful.focus or beautiful.wibar_bg
        notifs_datetime.focused = visible
    end
)

return border_container {
    widget = notifs_datetime
}

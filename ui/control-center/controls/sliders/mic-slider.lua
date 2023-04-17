local spawn = require("awful.spawn")
local beautiful = require("beautiful")
local gears_string = require("gears.string")
local wibox = require("wibox")

local helpers = require("helpers")
local system_controls = require("helpers.system-controls")

local slider = require("ui.widgets.slider")
local text_icon = require("ui.widgets.text-icon")

local value_text = require("ui.control-center.widgets.value-text")
local setting_slider = require("ui.control-center.widgets.setting-slider")

local mic_icon = text_icon {
    text = "\u{e029}"
}

local mic_value = value_text {
    text = "0%"
}

local mic_device_name = wibox.widget {
    text = "",
    font = beautiful.font_name .. " Medium 10",
    valign = "center",
    align = "right",
    forced_height = dpi(12),
    widget = wibox.widget.textbox
}

local mic_device = wibox.widget {
    {
        mic_device_name,
        margins = {
            left = dpi(6),
            right = dpi(6)
        },
        widget = wibox.container.margin
    },
    shape = helpers.rrect(beautiful.border_radius),
    widget = wibox.container.background
}

local mic_slider = slider {
    bar_bg_color = beautiful.accent .. '60',
    bar_color = beautiful.accent,
    handle_color = beautiful.accent
}

local function set_muted_style(muted)
    if muted then
        mic_icon.text = "\u{e02b}"
        mic_slider.bar_active_color = beautiful.accent .. '60'
        mic_slider.handle_color = beautiful.focus
    else
        mic_icon.text = "\u{e029}"
        mic_slider.bar_active_color = beautiful.accent
        mic_slider.handle_color = beautiful.accent
    end
end

mic_slider:connect_signal(
    "property::value", function(_, new_value)
        spawn("pactl set-source-volume @DEFAULT_SOURCE@ " .. new_value .. '%')
        mic_value.text = new_value .. "%"
    end
)

local function check_volume_and_mute()
    spawn.easy_async_with_shell(
        "pamixer --default-source --get-mute --get-volume", function(stdout)
            local muted, volume = table.unpack(gears_string.split(stdout, " "))

            mic_slider:set_value(tonumber(volume))

            set_muted_style(muted == "true")
        end
    )
end

awesome.connect_signal(
    "microphone::state", function(state)
        mic_device.bg = state and beautiful.green or beautiful.transparent
        mic_device.fg = state and beautiful.xbackground or beautiful.xforeground
    end
)

awesome.connect_signal(
    "microphone::device", function(name)
        mic_device_name.text = name
    end
)

awesome.connect_signal("microphone::mute", set_muted_style)

check_volume_and_mute()

return setting_slider {
    name = "Microphone",
    device_widget = mic_device,
    icon = mic_icon,
    action_button = system_controls.mic_toggle,
    slider = mic_slider,
    action_up = function()
        mic_slider:set_value(mic_slider:get_value() + 5)
    end,
    action_down = function()
        mic_slider:set_value(mic_slider:get_value() - 5)
    end,
    value_text = mic_value
}

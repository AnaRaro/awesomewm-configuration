local wibox_widget = require("wibox.widget")
local wibox_layout = require("wibox.layout")

local brightness_slider = require("ui.control-center.controls.sliders.brightness-slider")
local mic_slider = require("ui.control-center.controls.sliders.mic-slider")
local volume_slider = require("ui.control-center.controls.sliders.volume-slider")

local controls_container = require("ui.control-center.widgets.controls-container")
local grouped_toggle_buttons = require("ui.control-center.controls.grouped-toggle-buttons")

local control_sliders = wibox_widget {
    controls_container {
        widget = brightness_slider
    },
    controls_container {
        widget = {
            volume_slider,
            mic_slider,
            spacing = dpi(12),
            layout = wibox_layout.fixed.vertical
        }

    },
    layout = wibox_layout.fixed.vertical,
    spacing = dpi(12)
}

local controls = wibox_widget {
    grouped_toggle_buttons,
    control_sliders,
    visible = true,
    layout = wibox_layout.fixed.vertical,
    spacing = dpi(12)
}

awesome.connect_signal(
    "control_center::monitor_mode", function(monitor_mode)
        controls.visible = not monitor_mode
    end
)

return controls

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
-- local naughty = require("naughty")
local helpers = {}

-- Create rounded rectangle shape (in one line)
function helpers.rrect(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

function helpers.vertical_pad(height)
    return wibox.widget {
        forced_height = height,
        layout = wibox.layout.fixed.vertical
    }
end

function helpers.horizontal_pad(width)
    return wibox.widget {
        forced_width = width,
        layout = wibox.layout.fixed.horizontal
    }
end

local double_tap_timer = nil
function helpers.single_double_tap(single_tap_function, double_tap_function)
    if double_tap_timer then
        double_tap_timer:stop()
        double_tap_timer = nil
        double_tap_function()
        -- naughty.notify({text = "We got a double tap"})
        return
    end

    double_tap_timer = gears.timer.start_new(
        0.20, function()
            double_tap_timer = nil
            -- naughty.notify({text = "We got a single tap"})
            if single_tap_function then
                single_tap_function()
            end
            return false
        end
    )
end

-- Add a hover cursor to a widget by changing the cursor on
-- mouse::enter and mouse::leave
-- You can find the names of the available cursors by opening any
-- cursor theme and looking in the "cursors folder"
-- For example: "hand1" is the cursor that appears when hovering over
-- links
function helpers.add_hover_cursor(w, hover_cursor)
    local original_cursor = "left_ptr"

    w:connect_signal(
        "mouse::enter", function()
            local w = mouse.current_wibox
            if w then
                w.cursor = hover_cursor or "hand1"
            end
        end
    )

    w:connect_signal(
        "mouse::leave", function()
            local w = mouse.current_wibox
            if w then
                w.cursor = original_cursor
            end
        end
    )
end

function helpers.float_and_resize(c, width, height)
    c.width = width
    c.height = height
    awful.placement.centered(
        c, {
            honor_workarea = true,
            honor_padding = true
        }
    )
    awful.client.property.set(c, "floating_geometry", c:geometry())
    c.floating = true
    c:raise()
end

function helpers.add_action(widget, action)
    helpers.add_hover_cursor(widget)
    widget:buttons(gears.table.join(awful.button({}, 1, action)))
end

function helpers.add_list_scrolling(widget)
    local function scroll_down(widget)
        if #widget.children == 1 then
            return
        end
        widget:insert(1, widget.children[#widget.children])
        widget:remove(#widget.children)
    end

    local function scroll_up(widget)
        if #widget.children == 1 then
            return
        end
        widget:insert(#widget.children + 1, widget.children[1])
        widget:remove(1)
    end

    widget:buttons(
        gears.table.join(
            awful.button(
                {}, 4, nil, function()
                    scroll_down(widget)
                end
            ), awful.button(
                {}, 5, nil, function()
                    scroll_up(widget)
                end
            )
        )
    )
end

function helpers.get_next_screen(direction)
    -- If there's a screen in the given direction, return it
    local screen = awful.screen.focused()

    if screen:get_next_in_direction(direction) then
        return screen:get_next_in_direction(direction)
    end

    -- Alternatively, search for the farthest screen in the opposite direction
    -- to create a circular navigation
    local oposite_direction = (direction == "right" and "left") or "right"
    while screen:get_next_in_direction(oposite_direction) ~= nil do
        screen = screen:get_next_in_direction(oposite_direction)
    end

    return screen
end

return helpers

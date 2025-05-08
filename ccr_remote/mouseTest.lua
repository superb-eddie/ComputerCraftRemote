while true do
    local event = table.pack(os.pullEvent())
    local eventName = event[1]

    local bxy = function(s, n)
        return function(b, x, y)
            return ("%s %s (%d, %d)"):format(s[b], n, x, y)
        end
    end

    local button = { "Left", "Right", "Middle" }
    local direction = { [-1] = "Up", [1] = "Down" }

    local h = {}
    h.mouse_click = bxy(button, "Click")
    h.mouse_drag = bxy(button, "Drag")
    h.mouse_scroll = bxy(direction, "Scroll")
    h.mouse_up = bxy(button, "Release")
    h = h[event[1]]
    if h ~= nil then
        print(h(table.unpack(event, 2)))
    end
end
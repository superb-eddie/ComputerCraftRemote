-- Connect to a ccrshell client
-- Use: ./ccrshell.lua <ip_address:port>

local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

-- begin packets

---@class Packet
---@field name string
---@field payload any

---@param name string
---@param payload any
---@return Packet
local function mkPacket(name, payload)
    expect(1, name, "string")
    expect(2, payload, "table", "nil")

    return { name = name, payload = payload, }
end

local messageTypes = {
    {"clear"},
    {"clear-line"},
    {"write",
        {{"text", "string"}}},
    {"blit",
        {{"text", "string"},
         {"foreground", "string"},
         {"background", "string"}}},
    {"scroll",
        {{"y", "number"}}},
    {"set-cursor-position",
        {{"x", "number"},
         {"y", "number"}}},
    {"set-cursor-blink",
        {{"blink", "boolean"}}},
    {"set-foreground-color",
        {{"color", "number"}}},
    {"set-background-color",
        {{"color", "number"}}},
    {"set-palette-color",
        {{"color", "number"},
         {"r", "number"},
         {"g", "number"},
         {"b", "number"}}},
    {"set-console-name",
        {{"name", "string"}}}
}

local function iterTypeDesc(types, f)
    for _, typeDesc in ipairs(types) do
        f(typeDesc[1], function(ff)
            if typeDesc[2] ~= nil then
                for i, typeField in ipairs(typeDesc[2]) do
                    ff(i, typeField[1], typeField[2])
                end
            end
        end)
    end
end

local function kebabToCamelCase(text)
    local camel = ""
    for part in string.gmatch(text, "([^-]+)") do
        camel = camel .. part:sub(1, 1):upper() .. part:sub(2):lower()
    end
    return camel
end

local mkMessage = (function()
    local mkFunctions = {}
    iterTypeDesc(messageTypes, function(name, fieldIter)
        mkFunctions[kebabToCamelCase(name)] = function(...)
            local payload = {}
            local args = table.pack(...)
            fieldIter(function(i, fieldName, fieldType)
                payload[fieldName] = expect(i, args[i], fieldType)
            end)
            return mkPacket(("%s-message"):format(name), payload)
        end
    end)
    return mkFunctions
end)()

local eventTypes = {
    {"resize", {{"width", "number"},
                {"height", "number"}}},
    {"key-down", {{"key", "number"},
                  {"held", "boolean"},
                  {"char", "string"}}},
    {"key-up", {{"key", "number"}}},
    {"clipboard", {{"text", "string"}}},
    {"terminate"}
}

local dispatchEvent = (function()
    local dispatchFunctions = {}
    iterTypeDesc(eventTypes, function(name, fieldIter)
        local eventName = ("%s-event"):format(name)
        local handlerName = kebabToCamelCase(eventName)
        dispatchFunctions[eventName] = function(handler, payload)
            local args = {}
            fieldIter(function(i, fieldName, fieldType)
                table.insert(args, field(payload, fieldName, fieldType))
            end)

            field(handler, handlerName, "function")(table.unpack(args))
        end
    end)

    return function(handler, name, payload)
        local dispatch = dispatchFunctions[name]
        if dispatch ~= nil then
            dispatch(handler, payload)
        end
    end
end)()

-- end packets

-- begin packet_io

---@param host string
---@return Websocket
local function connectWs(host)
    local url = string.format("ws://%s/.well-known/ccremote", host)

    if http.checkURLAsync(url) then
        local event, event_url, ok, failure_reason
        while (event ~= "http_check") and (event_url ~= url) do
            event, event_url, ok, failure_reason = os.pullEvent("http_check")
        end
        if ok ~= true then
            error(string.format("Can't request '%s', %s", url, tostring(failure_reason)), 2)
        end
    end

    print(string.format("Connecting to '%s'", url))
    local ws, err = http.websocket({
        url = url,
        timeout = 10
    })
    if ws == false then
        error(err, 2)
    end

    return ws
end

---@param ws Websocket
---@param packet Packet
-----@return Packet
local function sendMessage(ws, packet)
    expect(1, ws, "table")
    expect(2, packet, "table")

    field(packet, "name", "string")
    field(packet, "payload", "table", "nil")

    ws.send(textutils.serialiseJSON(packet))
end

---@param ws Websocket
---@param eventHandler table<string, function>
local function pollEvent(ws, eventHandler)
    expect(1, ws, "table")
    expect(2, eventHandler, "table")

    while true do
        local rawPacket = ws.receive()
        if rawPacket == nil then
            error("websocket closed", 2)
        end

        packet = textutils.unserializeJSON(rawPacket)
        dispatchEvent(
                eventHandler,
                field(packet, "name", "string"),
                field(packet, "payload", "table")
        )
    end
end

-- end packet_io

-- begin display_redirect

local function round(n)
    return math.floor(tonumber(n)+0.5)
end

local function nativePalette()
    local allColors = {
        colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.gray,
        colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black,
    }

    local palette = {}
    for _, color in ipairs(allColors) do
        palette[color] = table.pack(term.nativePaletteColor(color))
    end
end

---@param ws Websocket
---@param name string
---@return Redirect
local function ccrRedirect(ws, name)
    local ccr = {
        sizeX = 50, sizeY = 50,
        cursorX = 1, cursorY = 1,
        cursorBlink = true,
        foregroundColor = colors.white,
        backgroundColor = colors.black,
        palette = nativePalette(),
    }

    ---@param packet Packet
    local function send(packet)
        sendMessage(ws, packet)
    end

    send(mkMessage.SetConsoleName(name))

    -- begin Redirect

    local function cursorInBounds()
        return ((ccr.cursorX > 0) and (ccr.cursorX <= ccr.sizeX)) and
                ((ccr.cursorY > 0) and (ccr.cursorY <= ccr.sizeY))
    end

    local function updateCursor(text)
        ccr.cursorX = math.min(ccr.cursorX+text:len(), ccr.sizeX)
    end

    function ccr.write(text)
        if not cursorInBounds() then
            return
        end

        local text = tostring(text)
        updateCursor(text)
        send(mkMessage.Write(text))
    end
    function ccr.scroll(y)
        expect(1, y, "number")
        send(mkMessage.Scroll(round(y)))
    end
    function ccr.getCursorPos()
        return ccr.cursorX, ccr.cursorY
    end
    function ccr.setCursorPos(x, y)
        ccr.cursorX = round(x)
        ccr.cursorY = round(y)
        send(mkMessage.SetCursorPosition(ccr.cursorX-1, ccr.cursorY-1))
    end
    function ccr.getCursorBlink()
        return ccr.cursorBlink
    end
    function ccr.setCursorBlink(blink)
        expect(1, blink, "boolean")
        ccr.cursorBlink = blink == true
        send(mkMessage.SetCursorBlink(ccr.cursorBlink))
    end
    function ccr.getSize()
        return ccr.sizeX, ccr.sizeY
    end
    function ccr.clear()
        send(mkMessage.Clear())
    end
    function ccr.clearLine()
        send(mkMessage.ClearLine())
    end
    function ccr.getTextColor()
        return ccr.foregroundColor
    end
    ccr.getTextColour = ccr.getTextColor

    function ccr.setTextColor(color)
        expect(1, color, "number")
        ccr.foregroundColor = round(color)
        send(mkMessage.SetForegroundColor(ccr.foregroundColor))
    end
    ccr.setTextColour = ccr.setTextColor

    function ccr.getBackgroundColor()
        return ccr.backgroundColor
    end
    ccr.getBackgroundColour = ccr.getBackgroundColor

    function ccr.setBackgroundColor(color)
        expect(1, color, "number")
        ccr.backgroundColor = round(color)
        send(mkMessage.SetBackgroundColor(ccr.backgroundColor))
    end
    ccr.setBackgroundColour = ccr.setBackgroundColor

    function ccr.isColor()
        return true
    end
    ccr.isColour = ccr.isColor

    function ccr.blit(text, textColor, backgroundColor)
        if not cursorInBounds() then
            return
        end

        local text = tostring(text)
        updateCursor(text)
        send(mkMessage.Blit(
                text,
                tostring(textColor),
                tostring(backgroundColor)
        ))
    end

    function ccr.setPaletteColor(index, r, g, b)
        expect(1, index, "number")
        expect(2, r, "number")
        expect(3, g, "number")
        expect(4, b, "number")
        local r, g, b = tonumber(r), tonumber(g), tonumber(b)
        ccr.palette[index] = table.pack(r, g, b)
        send(mkSetPaletteColor(index, r, g, b))
    end
    ccr.setPaletteColour = ccr.setPaletteColor

    function ccr.getPaletteColor(color)
        expect(1, color, "number")
        return table.unpack(ccr.palette[color])
    end
    ccr.getPaletteColour = ccr.setPaletteColor

    --- end Redirect

    --- begin EventHandler

    function ccr.ResizeEvent(width, height)
        ccr.sizeX = width
        ccr.sizeY = height
        os.queueEvent("term_resize")
    end

    function ccr.KeyDownEvent(key, held, char)
        os.queueEvent("key", key, held)
        if (not held) and (char ~= "") then
            os.queueEvent("char", char)
        end
    end

    function ccr.KeyUpEvent(key)
        os.queueEvent("key_up", key)
    end

    function ccr.ClipboardEvent(text)
        os.queueEvent("paste", text)
    end

    function ccr.TerminateEvent()
        -- TODO: Deliver this only to the shell we're running
        os.queueEvent("terminate")
    end

    --- end EventHandler

    return ccr
end

-- end display_redirect

local function main(host)
    expect(1, host, "string")

    local ws = connectWs(host)

    local name = os.getComputerLabel()
    if name == nil then
        name = ("#%d"):format(os.getComputerID())
    end

    local redirect = ccrRedirect(ws, name)
    local originalRedirect = term.redirect(redirect)
    local ok, err = pcall(
            parallel.waitForAny,
            function()
                shell.run("shell")
            end,
            function()
                pollEvent(ws, redirect)
            end
    )
    term.redirect(originalRedirect)
    ws.close()
    if ok ~= true and err ~= "Terminated" then
        error(err, 2)
    end
end

main(...)
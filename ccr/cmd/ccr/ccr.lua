-- Connect to a ccrshell client
-- Use: ./ccrshell.lua <ip_address:port>

local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

local ccrConfig = {
    bufferSize = {
        description = "How many messages to buffer before flushing to server",
        type = "number",
        default = 50,
    },
    bufferFlushPeriod = {
        description = "Time in milliseconds to wait before sending message buffer, regardless of how many messages are queued.",
        type = "number",
        default = 4,
    },
}

for id,def in pairs(ccrConfig) do
    local ccrId = "ccr." .. id
    settings.define(ccrId, def)
    ccrConfig[id] = function()
        return settings.get(ccrId)
    end
end

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
---@param buffer list<Packet>
local function sendPacketBuffer(ws, buffer)
    expect(1, ws, "table")
    expect(2, buffer, "table")

    ws.send(textutils.serialiseJSON(buffer))
end

---@param ws Websocket
---@param redirect table
local function pollEvent(ws, redirect)
    expect(1, ws, "table")
    expect(2, redirect, "table")

    local rawPacket = ws.receive()
    if rawPacket == nil then
        error("websocket closed", 2)
    end

    packet = textutils.unserializeJSON(rawPacket)

    local name = field(packet, "name", "string")
    local payload = field(packet, "payload", "table")
    if name == "cc-event-bundle" then
        local events = field(payload, "events", "table")
        for _,e in ipairs(events) do
            local eventName = field(e, "name", "string")
            local eventArgs = field(e, "args", "table", "nil")
            if eventArgs == nil then
                eventArgs = {}
            end

            local typedArgs = {}
            if (eventName == "char") then
                typedArgs = eventArgs
            else
                for _,v in ipairs(eventArgs) do
                    local tv
                    if (v == "true") or (v == "false") then
                        tv = (v == "true")
                    elseif v:match("^[0-9]+\.?[0-9]*$") then
                        tv = tonumber(v, 10)
                    else
                        tv = v
                    end

                    table.insert(typedArgs, tv)
                end
            end

            if eventName == "term_resize" then
                local width, height = table.unpack(typedArgs)
                redirect.sizeX = width
                redirect.sizeY = height
            elseif eventName == "terminate" then
            --    TODO: Deliver this only to the shell
            end

            os.queueEvent(eventName, table.unpack(typedArgs))
        end
    end
end

-- end packet_io

-- begin display_redirect

local function round(n)
    return math.floor((tonumber(n, 10) or 0)+0.5)
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

    return palette
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
        packetBuffer = {},
        lastFlushTime = 0,
    }

    function ccr.updateConfig()
        for name, f in pairs(ccrConfig) do
            ccr[name] = f()
        end
    end
    ccr.updateConfig()

    function ccr.flushPacketBuffer()
        -- Send packet queue when full or after a small amount of time
        local now = os.epoch("utc")
        local elapsed = now - ccr.lastFlushTime

        local isFlushPeriodOver = (now - ccr.lastFlushTime) > ccr.bufferFlushPeriod
        local isBufferFull = #ccr.packetBuffer > ccr.bufferSize
        local isBufferEmpty = #ccr.packetBuffer == 0

        if isFlushPeriodOver then
            ccr.updateConfig()
        end

        if (isFlushPeriodOver and not isBufferEmpty) or isBufferFull then
            ccr.lastFlushTime = now
            sendPacketBuffer(ws, ccr.packetBuffer)
            ccr.packetBuffer = {}
        end

    end

    ---@param packet Packet
    local function send(packet)
        table.insert(ccr.packetBuffer, packet)
    end

    send(mkMessage.SetConsoleName(name))

    -- begin Redirect

    local function canWriteText(charCount)
        return (((ccr.cursorX+charCount) > 0) and (ccr.cursorX <= ccr.sizeX)) and
                ((ccr.cursorY > 0) and (ccr.cursorY <= ccr.sizeY))
    end

    local function updateCursor(text)
        ccr.cursorX = math.min(ccr.cursorX+text:len(), ccr.sizeX)
    end

    function ccr.write(text)
        local text = tostring(text)
        if not canWriteText(#text) then
            return
        end

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
        local text = tostring(text)
        if not canWriteText(#text) then
            return
        end

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
        expect(3, g, "number", "nil")
        expect(4, b, "number", "nil")

        if (g ~= nil) and (b ~= nil) then
            r, g, b = tonumber(r), tonumber(g), tonumber(b)
        else
            r, g, b = colors.unpackRGB(tonumber(r))
        end

        ccr.palette[index] = table.pack(r, g, b)
        send(mkMessage.SetPaletteColor(index, r, g, b))
    end
    ccr.setPaletteColour = ccr.setPaletteColor

    function ccr.getPaletteColor(color)
        expect(1, color, "number")
        return table.unpack(ccr.palette[color])
    end
    ccr.getPaletteColour = ccr.getPaletteColor

    --- end Redirect

    return ccr
end

-- end display_redirect

local function main(host)
    expect(1, host, "string")

    if not host:match(".+\:%d+$") then
        host = host .. ":338"
    end

    local ws = connectWs(host)

    local name = os.getComputerLabel()
    if name == nil then
        name = ("#%d"):format(os.getComputerID())
    end

    local shellCmd = "shell"
    if term.native().isColor() then
       shellCmd = "multishell"
    end

    local redirect = ccrRedirect(ws, name)
    local originalRedirect = term.redirect(redirect)
    local ok, err = pcall(
            parallel.waitForAny,
            function()
                shell.run(shellCmd)
            end,
            function()
                while true do
                    pollEvent(ws, redirect)
                end
            end,
            function()
                while true do
                    os.sleep(0.05)
                    redirect.flushPacketBuffer()
                end
            end
    )
    term.redirect(originalRedirect)
    ws.close()
    if ok ~= true and err ~= "Terminated" then
        error(err, 2)
    end
end

main(...)
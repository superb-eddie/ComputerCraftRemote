local deflate = require("LibDeflate")

local expect = require("cc.expect")
local field, range = expect.field, expect.range

local function mkRow(chars, fg, bg)
    local chars = expect(1, chars, "string")
    local fg = expect(2, fg, "string")
    local bg = expect(3, bg, "string")

    if #fg ~= #chars then
        error("fg length does not match chars", 2)
    end

    if #bg ~= #chars then
        error("bg length does not match chars", 2)
    end

    return { chars = chars, fg = fg, bg = bg }
end

local function spliceText(text, splice, sStart, sEnd)
    -- Insert sub into text from subStart to subEnd
    return text:sub(1, sStart) .. splice .. text:sub(sEnd)
end

local blankChar = "\0"
local screenBuffer = {}
function screenBuffer.new()
    local self = {
        size = { x = 0, y = 0 },
        rows = {}
    }

    return setmetatable(self, {
        __index = screenBuffer,
    })
end

function screenBuffer:resize(newSize, fg, bg)
    expect(1, self, "table")
    expect(2, newSize, "table")
    expect(3, fg, "string")
    expect(4, bg, "string")

    self:debugAssertScreenSize()

    local oldSize = self.size
    self.size = {
        x = field(newSize, "x", "number"),
        y = field(newSize, "y", "number")
    }

    -- Every row between 1 and minY is only being modified
    local minY = math.min(self.size.y, oldSize.y)
    local maxY = math.max(self.size.y, oldSize.y)

    for y = 1,maxY do
        if (y <= minY) and (self.size.x ~= oldSize.x) then
            local oldRow = self.rows[y]
            if self.size.x > oldSize.x then
                -- Extending an old row
                local delta = self.size.x - oldSize.x
                self.rows[y] = mkRow(
                    oldRow.chars .. blankChar:rep(delta),
                    oldRow.fg .. fg:rep(delta),
                    oldRow.bg .. bg:rep(delta)
                )
            elseif oldSize.x > self.size.x then
                -- Shortening an old row
                self.rows[y] = mkRow(
                    oldRow.chars:sub(1, self.size.x),
                    oldRow.fg:sub(1, self.size.x),
                    oldRow.bg:sub(1, self.size.x)
                )
            end
        elseif y <= self.size.y then
            -- Adding a new row
            self.rows[y] = mkRow(
                blankChar:rep(self.size.x),
                fg:rep(self.size.x),
                bg:rep(self.size.x)
            )
        else
            -- Removing an old row
            self.rows[y] = nil
        end
    end

    self:debugAssertScreenSize()
end

function screenBuffer:debugAssertScreenSize()
    if (#self.rows) ~= self.size.y then
        error("y borked", 2)
    end

    for y = 1,self.size.y do
        r = self.rows[y]
        if (#r.chars) ~= self.size.x then
            error(tostring(y) .. " x borked", 2)
        end
    end
end

function screenBuffer:scroll(y, fg, bg)
    expect(1, self, "table")
    expect(2, y, "number")
    expect(3, fg, "string")
    expect(4, bg, "string")

    self:debugAssertScreenSize()

    if n == 0 then
        return
    end

    local doScroll = function(newY)
        local y = newY + n
        if (y >= 1) and (y <= self.size.y) then
            local oldRow = self.rows[y]
            self.rows[newY] = mkRow(
                oldRow.chars, oldRow.fg, oldRow.bg
            )
        else
            self.rows[newY] = mkRow(
                blankChar:rep(self.size.x),
                fg:rep(self.size.x),
                bg:rep(self.size.x)
            )
        end
    end

    if n > 0 then
        for newY = 1,self.size.y do
            doScroll(newY)
        end
    else
        -- Iterate backward to avoid clobbering rows
        for newY = self.size.y,1,-1 do
            doScroll(newY)
        end
    end

    self:debugAssertScreenSize()
end

function screenBuffer:blit(cursorX, cursorY, text, fg, bg)
    expect(1, self, "table")
    expect(2, cursorX, "number")
    expect(3, cursorY, "number")
    expect(4, text, "string")
    expect(5, fg, "string")
    expect(6, bg, "string")

    self:debugAssertScreenSize()

    local startX = cursorX
    local endX = startX + #text - 1
    if (cursorY < 1 or cursorY > self.size.y)
    or (endX < 1 or startX > self.size.x) then
       return
    end

    if (#self.rows[cursorY].chars ~= self.size.x) then
        error("before blit borked")
    end

    -- Clip the strings + start/end position to what is visible
    startX = math.max(startX, 1)
    startClipLen = startX - cursorX
    endClipLen = endX - self.size.x
    endX = math.min(endX, self.size.x)

    -- Insert the substrings into the line
    local oldRow = self.rows[cursorY]
    self.rows[cursorY] = mkRow(
        oldRow.chars:sub(1, startX) .. text:sub(startClipLen, -endClipLen) .. oldRow.chars:sub(endX),
        oldRow.fg:sub(1, startX) .. fg:sub(startClipLen, -endClipLen) .. oldRow.fg:sub(endX),
        oldRow.bg:sub(1, startX) .. bg:sub(startClipLen, -endClipLen) .. oldRow.bg:sub(endX)
    )

    self:debugAssertScreenSize()
end

function screenBuffer:clear()
    expect(1, self, "table")

    self:debugAssertScreenSize()
end

function screenBuffer:clearLine(n)
    expect(1, self, "table")
    expect(2, n, "number")

    self:debugAssertScreenSize()
end

local headlessRedirect = {}
function headlessRedirect.new()
    local self = {
        buffer = screenBuffer.new(),
        cursor = { x = 1, y = 1, blink = false },
        fgColor = colors.toBlit(colors.white),
        bgColor = colors.toBlit(colors.black),
        palette = {}
    }

    for i = 0,15 do
        local c = 2 ^ i
        self.palette[colors.toBlit(c)] = { term.nativePaletteColor(c) }
    end

    self.buffer:resize({ x = 51, y = 19 }, self.fgColor, self.bgColor)

    local fenv = setmetatable(
        { self = self },
        { __index = _ENV }
    )

    return setmetatable(self, {
        __index = function(_, idx)
            if type(idx) == "string" then
                idx = idx:gsub("Colour", "Color")
            end

            local v = headlessRedirect[idx]
            if type(v) == "function" and _ENV["self"] ~= self then
                v = setfenv(v, fenv)
            end

            return v
        end,
        __newIndex = function()
            error("Refusing to set value on headlessRedirect")
        end
    })
end

function headlessRedirect.resize(x, y)
    self.buffer:resize({ x = x, y = y }, self.fgColor, self.bgColor)
end

function headlessRedirect.blit(text, fgColor, bgColor)
    if #fgColor ~= #text or #bgColor ~= #text then
        error("Arguments must be the same length", 2)
    end

    self.buffer:blit(self.cursor.x, self.cursor.y, text, fgColor:lower(), bgColor:lower())
    self.cursor.x = self.cursor.x + #text
end

function headlessRedirect.write(text)
    text = tostring(text)
    self.buffer:blit(self.cursor.x, self.cursor.y, text, self.fgColor:rep(#text), self.bgColor:rep(#text))
    self.cursor.x = self.cursor.x + #text
end

function headlessRedirect.scroll(n)
    self.buffer:scroll(n, self.fgColor, self.bgColor)
end

function headlessRedirect.clearLine()
    self.buffer:clearLine(self.cursor.y)
end

function headlessRedirect.clear()
    self.buffer:clear()
end

function headlessRedirect.getCursorPos()
    return self.cursor.x, self.cursor.y
end

function headlessRedirect.setCursorPos(x, y)
    self.cursor.x = math.floor(x)
    self.cursor.y = math.floor(y)
end

function headlessRedirect.getCursorBlink()
    return self.cursor.blink
end

function headlessRedirect.setCursorBlink(blink)
    expect(1, blink, "boolean")
    self.cursor.blink = (blink == true)
end

function headlessRedirect.getSize()
    return self.buffer.size.x, self.buffer.size.y
end

function headlessRedirect.getTextColor()
    return colors.fromBlit(self.fgColor)
end

function headlessRedirect.setTextColor(color)
    expect(1, color, "number")
    self.fgColor = colors.toBlit(color)
end

function headlessRedirect.getBackgroundColor()
    return colors.fromBlit(self.bgColor)
end

function headlessRedirect.setBackgroundColor(color)
    expect(1, color, "number")
    self.bgColor = colors.toBlit(color)
end

function headlessRedirect.isColor()
    return true
end

function headlessRedirect.setPaletteColor(index, r, g, b)
    expect(1, index, "number")
    expect(2, r, "number")
    expect(3, g, "number", "nil")
    expect(4, b, "number", "nil")

    if (g ~= nil) and (b ~= nil) then
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
    else
        r, g, b = colors.unpackRGB(tonumber(r))
    end

    self.palette[colors.toBlit(index)] = { r, g, b }
end

function headlessRedirect.getPaletteColor(color)
    expect(1, color, "number")
    return table.unpack(self.palette[colors.toBlit(color)])
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

    events = textutils.unserializeJSON(rawPacket)
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
            redirect.resize(width, height)
        elseif eventName == "terminate" then
        --    TODO: Somehow deliver this only to the shell
        end

        os.queueEvent(eventName, table.unpack(typedArgs))
    end
end

local function getCfg()
    local defaultShell = "shell"
    if term.native().isColor() then
        defaultShell = "multishell"
    end

    local defaultTabName = os.getComputerLabel()
    if defaultTabName == nil then
        defaultTabName = ("#%d"):format(os.getComputerID())
    end

    local spec = {
        shell = {
            description = "Shell binary that ccr starts when connecting",
            default = defaultShell,
            type = "string"
        },
        updateRate = {
            description = "Amount of screen updates sent in a second",
            default = 30,
            type = "number"
        },
        tabName = {
            description = "The name displayed on the ccr tab when connected",
            default = defaultTabName,
            type = "string"
        },
        defaultHost = {
            description = "Connect to this host if one isn't provided",
            type = "string"
        }
    }

    local values = {}
    for n,s in pairs(spec) do
        local key = "ccr." .. n
        settings.define(key, s)
        values[n] = settings.get(key)
    end

    return values
end

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

local function main(host)
    expect(1, host, "string", "nil")

    local cfg = getCfg()
    if (host == nil) then
        if (cfg.defaultHost ~= nil) then
            host = cfg.defaultHost
        else
            error("No host given")
        end
    end

    if not host:match(".+\:%d+$") then
        host = host .. ":338"
    end

    local ws = connectWs(host)
    local redirect = headlessRedirect.new()
    local originalRedirect = term.redirect(redirect)
    local ok, err = pcall(
            parallel.waitForAny,
            function()
                shell.run(cfg.shell)
            end,
            function()
                while true do
                    pollEvent(ws, redirect)
                end
            end,
            function()
                local sleepTime = 1.0 / cfg.updateRate
                while true do
                    os.sleep(sleepTime)
                    redirect.buffer:debugAssertScreenSize()
                    local packet = deflate:CompressZlib(textutils.serialiseJSON(redirect))
                    if packet == nil then
                        error("Something went wrong.", 2)
                    end

                    ws.send(packet, true)
                end
            end
    )
    term.redirect(originalRedirect)
    ws.close()
    if ok ~= true and err ~= "Terminated" then
        error(err, 2)
    else
        print("Goodbye!")
    end
end

main(...)
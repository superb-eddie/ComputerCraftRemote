local t = term.current()

local foregroundColor = ""
local backgroundColor = ""

local foregroundBW = ""
local backgroundBW = ""

for i = 0,15 do
    foregroundColor = foregroundColor .. colors.toBlit(bit32.lshift(1, i))
    backgroundColor = backgroundColor .. colors.toBlit(bit32.lshift(1, 15 - i))

    foregroundBW = foregroundBW .. colors.toBlit(colors.white)
    backgroundBW = backgroundBW .. colors.toBlit(colors.black)
end

local lines = {}

for y = 0,15 do
    local line = ""
    for x = 0,15 do
        local c = string.char((y*16)+x)
        if c == "\n" then
            c = " "
        end

        line = line .. c
    end

    table.insert(lines, line)
end

function writeChars(foreground, background)
    t.setCursorPos(1, select(2, t.getCursorPos()))
    local _, ty = t.getSize()

    for _, line in ipairs(lines) do
        t.blit(line, foreground, background)

        local _, cy = t.getCursorPos()
        if cy >= ty then
            t.scroll(1)
            t.setCursorPos(1, cy)
        else
            t.setCursorPos(1, cy + 1)
        end
    end
end

writeChars(foregroundColor, backgroundColor)
writeChars(foregroundBW, backgroundBW)
print()

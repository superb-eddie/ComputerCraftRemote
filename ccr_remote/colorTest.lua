local allColors = {
    colors.white,
    colors.orange,
    colors.magenta,
    colors.lightBlue,
    colors.yellow,
    colors.lime,
    colors.pink,
    colors.gray,
    colors.lightGray,
    colors.cyan,
    colors.purple,
    colors.blue,
    colors.brown,
    colors.green,
    colors.red,
    colors.black
}

local ofc = term.getTextColor()
local obc = term.getBackgroundColor()

for i, c in ipairs(allColors) do
    term.setTextColor(c)
    term.setBackgroundColor(allColors[((i + 1) % #allColors)])
    print("Hello world!")
    term.setTextColor(ofc)
    term.setBackgroundColor(obc)
end

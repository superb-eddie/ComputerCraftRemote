
--term.setBackgroundColor(colors.white)
--term.setTextColor(colors.black)

for y = 0,15 do
    local line = ""
    for x = 0,15 do
        local c = string.char((y*16)+x)

        if c == "\n" then
            c = " "
        end

        line = line .. c
    end
    print(line)
end

--term.setBackgroundColor(colors.black)
--term.setTextColor(colors.white)

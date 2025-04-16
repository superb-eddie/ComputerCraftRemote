while true do
    local event = table.pack(os.pullEvent())
    local eventName = event[1]

    if eventName == "char" then
        local character = table.unpack(event, 2)
        print(("char  : %s"):format(character))
    elseif eventName == "key" then
        local key, is_held = table.unpack(event, 2)
        print(("key   : %s(%d) %s"):format(keys.getName(key), key, tostring(is_held)))
    elseif eventName == "key_up" then
        local key = table.unpack(event, 2)
        print(("key_up: %s(%d)"):format(keys.getName(key), key))
    end
end
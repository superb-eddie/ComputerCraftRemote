---@meta

rednet = {}

---@alias rednetMessage number | boolean | string | table

---@param recipient number
---@param message rednetMessage
---@param protocol string?
---@return boolean
function rednet.send(recipient, message, protocol)
    return false
end

---@param protocol_filter string?
---@param timeout number?
---@return number        # The computer which sent this message
---@return rednetMessage # The received message
---@return string | nil  # The protocol this message was sent under.
function rednet.receive(protocol_filter, timeout)
    return 0, 0, nil
end
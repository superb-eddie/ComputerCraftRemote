---@meta

-- TODO: CC does not provide all of the expect os functions. Mark the missing ones as "deprecated"

os = {}

---Returns the label of the computer, or nil if none is set.
---@return string | nil # The label of the computer.
function os.getComputerLabel() end

---Returns the label of the computer, or nil if none is set.
---@return string | nil # The label of the computer.
function os.computerLabel() end

---Returns the ID of the computer.
---@return number # The ID of the computer.
function os.getComputerID() end

---Returns the ID of the computer.
---@return number # The ID of the computer.
function os.computerID() end

---Adds an event to the event queue. This event can later be pulled with os.pullEvent.
---@param name string # The name of the event to queue.
---@param ... any # The parameters of the event. These can be any primitive type (boolean, number, string) as well as tables. Other types (like functions), as well as metatables, will not be preserved.
function os.queueEvent(name, ...) end

--- Pause execution of the current thread and waits for any events matching filter.
---
--- This function yields the current process and waits for it to be resumed with a vararg list where the first element matches filter. If no filter is supplied, this will match all events.
---
--- Unlike os.pullEventRaw, it will stop the application upon a "terminate" event, printing the error "Terminated".
---@param filter string? # Event to filter for.
---@return string # The name of the event that fired. Followed by some number of parameters.
function os.pullEvent(filter) end
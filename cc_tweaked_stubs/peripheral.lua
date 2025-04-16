---@meta

---@type table
peripheral = {}

--- Provides a list of all peripherals available.
---
--- If a device is located directly next to the system, then its name will be
---  listed as the side it is attached to. If a device is attached via a Wired
---  Modem, then it'll be reported according to its name on the wired network.
---@return string[] # A list of the names of all attached peripherals.
function peripheral.getNames() end

--- Determines if a peripheral is present with the given name.
---@param name string # The side or network name that you want to check.
---@return boolean # If a peripheral is present with the given name.
function peripheral.isPresent(name) end

--- Get the types of a named or wrapped peripheral.
---@param peripheral string | table # The name of the peripheral to find, or a wrapped peripheral instance.
---@return string ... # The peripheral's types, or nil if it is not present.
function peripheral.getType(peripheral) end

--- Check if a peripheral is of a particular type.
---@param peripheral string | table # The name of the peripheral or a wrapped peripheral instance.
---@param peripheral_type string # The type to check.
---@return boolean | nil # If a peripheral has a particular type, or nil if it is not present.
function peripheral.hasType(peripheral, peripheral_type) end

--- Get all available methods for the peripheral with the given name.
---@param name string # The name of the peripheral to find.
---@return string[] | nil # A list of methods provided by this peripheral, or nil if it is not present.
function peripheral.getMethods(name) end

--- Get the name of a peripheral wrapped with `peripheral.wrap`.
---@param peripheral table # The peripheral to get the name of.
---@return string # The name of the given peripheral
function peripheral.getName(peripheral) end

--- Call a method on the peripheral with the given name.
---@param name string # The name of the peripheral to invoke the method on.
---@param method string # The name of the method
---@param ... any # Additional arguments to pass to the method
---@return any ... # The return values of the peripheral method.
function peripheral.call(name, method, ...) end

--- Get a table containing all functions available on a peripheral.
---  These can then be called instead of using peripheral.call every time.
---@param name string # The name of the peripheral to wrap
---@return table | nil # The table containing the peripheral's methods, or nil if there is no peripheral present with the given name.
function peripheral.wrap(name) end

--- Find all peripherals of a specific type, and return the wrapped peripherals.
---@param ty string # The type of peripheral to look for.
---@param filter fun(name: string, wrapped: table)? # A filter function, which takes the peripheral's name and wrapped table and returns if it should be included in the result.
function peripheral.find(ty, filter) end

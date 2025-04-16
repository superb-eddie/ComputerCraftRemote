---@meta

---@class ModemPeripheral
ModemPeripheral = {}

--- Open a channel on a modem. A channel must be open in order to receive
---  messages. Modems can have up to 128 channels open at one time.
---@param channel number # The channel to open. This must be a number between 0 and 65535.
function ModemPeripheral.open(channel) end

--- Check if a channel is open.
---@param channel number # The channel to check.
function ModemPeripheral.isOpen(channel) end

--- Close an open channel, meaning it will no longer receive messages.
---@param channel number # The channel to close
function ModemPeripheral.close(channel) end

--- Close all open channels.
function ModemPeripheral.closeAll() end

--- Sends a modem message on a certain channel.
---  Modems listening on the channel will queue a modem_message event on adjacent computers.
---@param channel number # The channel to send messages on.
---@param replyChannel number # The channel that responses to this message should be sent on. This can be the same as channel or entirely different. The channel must have been opened on the sending computer in order to receive the replies.
---@param payload any # The object to send. This can be any primitive type (boolean, number, string) as well as tables. Other types (like functions), as well as metatables, will not be transmitted.
function ModemPeripheral.transmit(channel, replyChannel, payload) end

--- Determine if this is a wired or wireless modem.
---
--- Some methods (namely those dealing with wired networks and remote
---  peripherals) are only available on wired modems.
---@return boolean # true if this is a wireless modem.
function ModemPeripheral.isWireless() end

--- List all remote peripherals on the wired network.
---
--- If this computer is attached to the network, it will not be included in this list.
---@return string[] # Remote peripheral names on the network.
function ModemPeripheral.getNamesRemote() end

--- Determine if a peripheral is available on this wired network.
---@param name string # The side or network name that you want to check.
---@return boolean # If a peripheral is present with the given name.
function ModemPeripheral.isPresentRemote(name) end

--- Get the type of a peripheral is available on this wired network.
---@param peripheral string | table # The name of the peripheral to find, or a wrapped peripheral instance.
---@return string ... # The peripheral's types, or nil if it is not present.
function ModemPeripheral.getTypeRemote(peripheral) end

--- Check a peripheral is of a particular type.
---@param peripheral string | table # The name of the peripheral or a wrapped peripheral instance.
---@param peripheral_type string # The type to check.
---@return boolean | nil # If a peripheral has a particular type, or nil if it is not present.
function ModemPeripheral.hasTypeRemote(peripheral, peripheral_type) end

--- Get all available methods for the remote peripheral with the given name.
---@param name string # The name of the peripheral to find.
---@return string[] | nil # A list of methods provided by this peripheral, or nil if it is not present.
function ModemPeripheral.getMethodsRemote(name) end

--- Call a method on a peripheral on this wired network.
---@param name string # The name of the peripheral to invoke the method on.
---@param method string # The name of the method
---@param ... any # Additional arguments to pass to the method
---@return any ... # The return values of the peripheral method.
function ModemPeripheral.callRemote(name, method, ...) end

--- Returns the network name of the current computer, if the modem is on.
---  This may be used by other computers on the network to wrap this computer as a peripheral.
---@return string | nil # The current computer's name on the wired network.
function ModemPeripheral.getNameLocal() end

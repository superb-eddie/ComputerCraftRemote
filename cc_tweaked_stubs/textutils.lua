---@meta

textutils = {}

---@class TextutilsSerializeOptions
---@field compact boolean? # Do not emit indentation and other whitespace between terms.
---@field allow_repetitions boolean? # Relax the check for recursive tables, allowing them to appear multiple times (as long as tables do not appear inside themselves).

--- Convert a Lua object into a textual representation, suitable for saving in a file or pretty-printing.
---@param t any # The object to serialise
---@param opts TextutilsSerializeOptions? # Options for serialisation.
---@return string # The serialised representation
function textutils.serialise(t, opts) end

--- Converts a serialised string back into a reassembled Lua object.
---
--- This is mainly used together with textutils.serialise.
---@param s string # The serialised string to deserialise.
---@return any? # The deserialised object, or nil if the object could not be deserialised.
function textutils.unserialize(s) end

function textutils.serialiseJSON(t, opts) end

function textutils.unserializeJSON(s, opts) end
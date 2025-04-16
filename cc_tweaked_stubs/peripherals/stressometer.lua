---@meta

---@class StressometerPeripheral
StressometerPeripheral = {}

--- Gets the connected network's current stress level.
---@return number # The current stress level in SU.
function StressometerPeripheral.getStress() end

--- Gets the connected network's total stress capacity.
---@return number # The total stress capacity in SU.
function StressometerPeripheral.getStressCapacity() end

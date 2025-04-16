---@meta


---@class RotationSpeedControlPeripheral
RotationSpeedControlPeripheral = {}

--- Gets the rotation speed controller's current target speed.
---@return number # The current target rotation speed in RPM.
function RotationSpeedControlPeripheral.getTargetSpeed()
end

--- Sets the rotation speed controller's target speed.
---@param speed number # The target speed in RPM. Must be an integer within the range of [-256..256]. Values outside of this range will be clamped.
function RotationSpeedControlPeripheral.setTargetSpeed(speed)
end

---@meta

turtle = {}

--- Craft a recipe based on the turtle's inventory.
---
--- The turtle's inventory should set up like a crafting grid. For instance, to craft sticks, slots 1 and 5 should contain planks. All other slots should be empty, including those outside the crafting "grid".
---@param limit number? # The maximum number of crafting steps to run.
---@return boolean # If crafting succeeds
---@return string? # Why crafting failed
function turtle.craft(limit) end

--- Move the turtle forward one block.
---@return boolean # Whether the turtle could successfully move.
---@return string? # The reason the turtle could not move.
function turtle.forward() end

--- Move the turtle backwards one block.
---@return boolean # Whether the turtle could successfully move.
---@return string? # The reason the turtle could not move.
function turtle.back() end

--- Move the turtle up one block.
---@return boolean # Whether the turtle could successfully move.
---@return string? # The reason the turtle could not move.
function turtle.up() end

--- Move the turtle down one block.
---@return boolean # Whether the turtle could successfully move.
---@return string? # The reason the turtle could not move.
function turtle.down() end

--- Rotate the turtle 90 degrees to the left.
---@return boolean # Whether the turtle could successfully move.
---@return string? # The reason the turtle could not move.
function turtle.turnLeft() end

--- Rotate the turtle 90 degrees to the right.
---@return boolean # Whether the turtle could successfully move.
---@return string? # The reason the turtle could not move.
function turtle.turnRight() end

--- Attempt to break the block in front of the turtle.
---
--- This requires a turtle tool capable of breaking the block. Diamond pickaxes (mining turtles) can break any vanilla block, but other tools (such as axes) are more limited.
---@param side string? # The specific tool to use.
---@return boolean # Whether a block was broken.
---@return string? # The reason no block was broken.
function turtle.dig(side) end

--- Attempt to break the block above the turtle.
---@param side string? # The specific tool to use.
---@return boolean # Whether a block was broken.
---@return string? # The reason no block was broken.
function turtle.digUp(side) end

--- Attempt to break the block below the turtle.
---@param side string? # The specific tool to use.
---@return boolean # Whether a block was broken.
---@return string? # The reason no block was broken.
function turtle.digDown(side) end

--- Place a block or item into the world in front of the turtle.
---
--- "Placing" an item allows it to interact with blocks and entities in front of the turtle. For instance, buckets can pick up and place down fluids, and wheat can be used to breed cows. However, you cannot use place to perform arbitrary block interactions, such as clicking buttons or flipping levers.
---@param text string? # When placing a sign, set its contents to this text.
---@return boolean # Whether the block could be placed.
---@return string? # The reason the block was not placed.
function turtle.place(text) end

--- Place a block or item into the world above the turtle.
---@param text string? # When placing a sign, set its contents to this text.
---@return boolean # Whether the block could be placed.
---@return string? # The reason the block was not placed.
function turtle.placeUp(text) end

--- Place a block or item into the world below the turtle.
---@param text string? # When placing a sign, set its contents to this text.
---@return boolean # Whether the block could be placed.
---@return string? # The reason the block was not placed.
function turtle.placeDown(text) end

--- Drop the currently selected stack into the inventory in front of the turtle, or as an item into the world if there is no inventory.
---@param count number? # The number of items to drop. If not given, the entire stack will be dropped.
---@return boolean # Whether items were dropped.
---@return string? # The reason the no items were dropped.
function turtle.drop(count) end

--- Drop the currently selected stack into the inventory above the turtle, or as an item into the world if there is no inventory.
---@param count number? # The number of items to drop. If not given, the entire stack will be dropped.
---@return boolean # Whether items were dropped.
---@return string? # The reason the no items were dropped.
function turtle.dropUp(count) end

--- Drop the currently selected stack into the inventory below the turtle, or as an item into the world if there is no inventory.
---@param count number? # The number of items to drop. If not given, the entire stack will be dropped.
---@return boolean # Whether items were dropped.
---@return string? # The reason the no items were dropped.
function turtle.dropDown(count) end

--- Change the currently selected slot.
---
--- The selected slot is determines what slot actions like drop or getItemCount act on.
---@param slot number # The slot to select
---@return boolean # Whether the slot has been selected
function turtle.select(slot) end

--- Get the number of items in the given slot.
---@param slot number? # The slot we wish to check. Defaults to the selected slot.
---@return number # The number of items in this slot.
function turtle.getItemCount(slot) end

--- Get the remaining number of items which may be stored in this stack.
---@param slot number? # The slot we wish to check. Defaults to the selected slot.
---@return number # The space left in in this slot.
function turtle.getItemSpace(slot) end

--- Check if there is a solid block in front of the turtle.
---@return boolean # If there is a solid block in front.
function turtle.detect() end

--- Check if there is a solid block above the turtle.
---@return boolean # If there is a solid block above.
function turtle.detectUp() end

--- Check if there is a solid block below the turtle.
---@return boolean # If there is a solid block below.
function turtle.detectDown() end

--- Check if the block in front of the turtle is equal to the item in the currently selected slot.
---@return boolean # If the block and item are equal.
function turtle.compare() end

--- Check if the block above the turtle is equal to the item in the currently selected slot.
---@return boolean # If the block and item are equal.
function turtle.compareUp() end

--- Check if the block below the turtle is equal to the item in the currently selected slot.
---@return boolean # If the block and item are equal.
function turtle.compareDown() end

--- Attack the entity in front of the turtle.
---@param side string? # The specific tool to use
---@return boolean # Whether an entity was attacked.
---@return string? # The reason nothing was attacked.
function turtle.attack(side) end

--- Attack the entity above the turtle.
---@param side string? # The specific tool to use
---@return boolean # Whether an entity was attacked.
---@return string? # The reason nothing was attacked.
function turtle.attackUp(side) end

--- Attack the entity below the turtle.
---@param side string? # The specific tool to use
---@return boolean # Whether an entity was attacked.
---@return string? # The reason nothing was attacked.
function turtle.attackDown(side) end

--- Suck an item from the inventory in front of the turtle, or from an item floating in the world.
---
--- This will pull items into the first acceptable slot, starting at the currently selected one.
---@param count number? # The number of items to suck. If not given, up to a stack of items will be picked up.
---@return boolean # Whether items were picked up.
---@return string? # The reason the no items were picked up.
function turtle.suck(count) end

--- Suck an item from the inventory above the turtle, or from an item floating in the world.
---@param count number? # The number of items to suck. If not given, up to a stack of items will be picked up.
---@return boolean # Whether items were picked up.
---@return string? # The reason the no items were picked up.
function turtle.suckUp(count) end

--- Suck an item from the inventory below the turtle, or from an item floating in the world.
---@param count number? # The number of items to suck. If not given, up to a stack of items will be picked up.
---@return boolean # Whether items were picked up.
---@return string? # The reason the no items were picked up.
function turtle.suckDown(count) end

--- Get the maximum amount of fuel this turtle currently holds.
---@return number # The current amount of fuel a turtle this turtle has.
function turtle.getFuelLevel() end

--- Refuel this turtle.
---
--- While most actions a turtle can perform (such as digging or placing blocks) are free, moving consumes fuel from the turtle's internal buffer. If a turtle has no fuel, it will not move.
---
--- refuel refuels the turtle, consuming fuel items (such as coal or lava buckets) from the currently selected slot and converting them into energy. This finishes once the turtle is fully refuelled or all items have been consumed.
---@param count number? # The maximum number of items to consume. One can pass 0 to check if an item is combustable or not.
---@return boolean # If the turtle was refuelled.
---@return string? # The reason the turtle was not refuelled.
function turtle.refuel(count) end

--- Compare the item in the currently selected slot to the item in another slot.
---@param slot  number # The slot to compare to.
---@return boolean # If the two items are equal.
function turtle.compareTo(slot) end

--- Move an item from the selected slot to another one.
---@param slot number # The slot to move this item to.
---@param count number? # The maximum number of items to move.
---@return boolean # If some items were successfully moved.
function turtle.transferTo(slot, count) end

--- Get the currently selected slot.
---@return number # The current slot.
function turtle.getSelectedSlot() end

--- Get the maximum amount of fuel this turtle can hold.
---
--- By default, normal turtles have a limit of 20,000 and advanced turtles of 100,000.
---@return number # The maximum amount of fuel a turtle can hold.
function turtle.getFuelLimit() end

--- Equip (or unequip) an item on the left side of this turtle.
---
--- This finds the item in the currently selected slot and attempts to equip it to the left side of the turtle. The previous upgrade is removed and placed into the turtle's inventory. If there is no item in the slot, the previous upgrade is removed, but no new one is equipped.
---@return boolean # If the item was equipped.
---@return string? # The reason equipping this item failed.
function turtle.equipLeft() end

--- Equip (or unequip) an item on the right side of this turtle.
---
--- This finds the item in the currently selected slot and attempts to equip it to the right side of the turtle. The previous upgrade is removed and placed into the turtle's inventory. If there is no item in the slot, the previous upgrade is removed, but no new one is equipped.
---@return boolean # If the item was equipped.
---@return string? # The reason equipping this item failed.
function turtle.equipRight() end

---@alias BlockDetail { name: string, state: table, tags: table<string, boolean>}

--- Get information about the block in front of the turtle.
---@return boolean # Whether there is a block in front of the turtle.
---@return BlockDetail | string # Information about the block in front, or a message explaining that there is no block.
function turtle.inspect() end

--- Get information about the block above the turtle.
---@return boolean # Whether there is a block above the turtle.
---@return BlockDetail | string # Information about the block above, or a message explaining that there is no block.
function turtle.inspectUp() end

--- Get information about the block below the turtle.
---@return boolean # Whether there is a block below the turtle.
---@return BlockDetail | string # Information about the block below, or a message explaining that there is no block.
function turtle.inspectDown() end

--- Get detailed information about the items in the given slot.
---@param slot number? # The slot to get information about. Defaults to the selected slot.
---@param detailed boolean? # Whether to include "detailed" information. When true the method will contain much more information about the item at the cost of taking longer to run.
---@return Item | ItemDetail | nil # Information about the given slot, or nil if it is empty.
function turtle.getItemDetail(slot, detailed) end

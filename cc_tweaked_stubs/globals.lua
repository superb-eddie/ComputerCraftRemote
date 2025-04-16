---@meta

--- Pauses execution for the specified number of seconds.
---
--- As it waits for a fixed amount of world ticks, time will automatically be rounded up to the nearest multiple of 0.05 seconds. If you are using coroutines or the parallel API, it will only pause execution of the current thread, not the whole program.
---@param time number # The number of seconds to sleep for, rounded up to the nearest multiple of 0.05.
function sleep(time) end

--- Writes a line of text to the screen without a newline at the end, wrapping text if necessary.
---@param text string # The text to write to the string
---@return number # The number of lines written
function write(text) end

--- Prints the specified values to the screen separated by spaces, wrapping if necessary.
---@param ... any # The values to print on the screen
---@return number # The number of lines written
function print(...) end

--- Prints the specified values to the screen in red, separated by spaces, wrapping if necessary.
---@param ... any # The values to print on the screen
function printError(...) end

--- Reads user input from the terminal. This automatically handles arrow keys, pasting, character replacement, history scrollback, auto-completion, and default values.
---@param replaceChar string? # A character to replace each typed character with. This can be used for hiding passwords, for example.
---@param history table? # A table holding history items that can be scrolled back to with the up/down arrow keys. The oldest item is at index 1, while the newest item is at the highest index.
---@param completeFn (fun(partial: string): string[])? # A function to be used for completion. This function should take the partial text typed so far, and returns a list of possible completion options.
---@param default string? # Default text which should already be entered into the prompt.
---@return string # The text typed in.
function read(replaceChar, history, completeFn, default) end

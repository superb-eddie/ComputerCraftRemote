---@meta

fs = {}

---@class FsCompleteOptions
---@field include_dirs boolean? # When false, "raw" directories will not be included in the returned list.
---@field include_files boolean? # When false, only directories will be included in the returned list.
---@field include_hidden boolean? # Whether to include hidden files (those starting with '.') by default. They will still be shown when typing a '.'.

--- Provides completion for a file or directory name, suitable for use with _G.read.
---
--- When a directory is a possible candidate for completion, two entries are included - one with a trailing slash (indicating that entries within this directory exist) and one without it (meaning this entry is an immediate completion candidate). include_dirs can be set to false to only include those with a trailing slash.
---@param path string # The path to complete.
---@param location string # The location where paths are resolved from.
---@param opts FsCompleteOptions
---@return string[] # A list of possible completion candidates.
function fs.complete(path, location, opts) end

--- Searches for files matching a string with wildcards.
---
--- This string looks like a normal path string, but can include wildcards, which can match multiple paths:
---
---  - "?" matches any single character in a file name.
---  - "*" matches any number of characters.
---
--- For example, rom/*/command* will look for any path starting with command inside any subdirectory of /rom.
--- Note that these wildcards match a single segment of the path. For instance rom/*.lua will include rom/startup.lua but not include rom/programs/list.lua.
---@param path string # The wildcard-qualified path to search for.
---@return string[] # A list of paths that match the search string.
function fs.find(path) end

--- Returns true if a path is mounted to the parent filesystem.
---
--- The root filesystem "/" is considered a mount, along with disk folders and the rom folder. Other programs (such as network shares) can exstend this to make other mount types by correctly assigning their return value for getDrive.
---@param path string # The path to check
---@return boolean # If the path is mounted, rather than a normal file/folder.
function fs.isDriveRoot(path) end

--- Returns a list of files in a directory.
---@param path string # The path to list.
---@return string[] # A list of files in the directory.
function fs.list(path) end

--- Combines several parts of a path into one full path, adding separators as needed.
---@param path string # The first part of the path.
---@param ... string # Additional parts to combine.
---@return string
function fs.combine(path, ...) end

--- Returns the file name portion of a path.
---@param path string # The path to get the name from.
---@return string # The final part of the path (the file name).
function fs.getName(path) end

--- Returns the parent directory portion of a path.
---@param path string # The path to get the directory from.
---@return string # The path with the final part removed (the parent directory).
function fs.getDir(path) end

--- Returns the size of the specified file.
---@param path string # The file to get thee size of.
---@return number # The size of the file, in bytes.
function fs.getSize(path) end

--- Returns whether the specified path exists.
---@param path string # The path to check the existence of.
---@return boolean # Whether the path exists.
function fs.exists(path) end

--- Returns whether the specified path is a directory.
---@param path string # The path to check.
---@return boolean # Whether the path is a directory.
function fs.isDir(path) end

--- Returns whether a path is read-only.
---@param path string # The path to check.
---@return boolean # Whether the path cannot be written to.
function fs.isReadOnly(path) end

--- Creates a directory, and any missing parents, at the specified path.
---@param path string # The path to the directory to create.
function fs.makeDir(path) end

--- Moves a file or directory from one path to another.
---
--- Any parent directories are created as needed.
---@param path string # The current file or directory to move from.
---@param dest string # The destination path for the file or directory.
function fs.move(path, dest) end

--- Copies a file or directory to a new path.
---
--- Any parent directories are created as needed.
---@param path string The file or directory to copy.
---@param dest string The path to the destination file or directory.
function fs.copy(path, dest) end

--- Deletes a file or directory.
---
--- If the path points to a directory, all of the enclosed files and subdirectories are also deleted.
---@param path string # The path to the file or directory to delete.
function fs.delete(path) end

--- Opens a file for reading or writing at a path.
---
--- The mode string can be any of the following:
---
---  - "r": Read mode
---  - "w": Write mode
---  - "a": Append mode
---  - "r+": Update mode (allows reading and writing), all data is preserved
---  - "w+": Update mode, all data is erased.
---
--- The mode may also have a "b" at the end, which opens the file in "binary mode". This changes fs.ReadHandle.read and fs.WriteHandle.write to read/write single bytes as numbers rather than strings.
---@param path string The path to the file to open.
---@param mode string The mode to open the file with.
---@return ReadHandle | WriteHandle | ReadWriteHandle | ReadBytesHandle | WriteBytesHandle | ReadWriteBytesHandle
function fs.open(path, mode) end

--- Returns the name of the mount that the specified path is located on.
---@param path string # The path to get the drive of.
---@return string | nil # The name of the drive that the file is on; e.g. hdd for local files, or rom for ROM files.
function fs.getDrive(path) end

--- Returns the amount of free space available on the drive the path is located on.
---@param path string # The path to check the free space for.
---@return number # The amount of free space available, in bytes, or "unlimited".
function fs.getFreeSpace(path) end

--- Returns the capacity of the drive the path is located on.
---@param path string The path of the drive to get.
---@return number | nil # This drive's capacity. This will be nil for "read-only" drives, such as the ROM or treasure disks.
function fs.getCapacity(path) end

---@class FsAttributes
---@field size number
---@field isDir boolean
---@field isReadOnly boolean
---@field created number
---@field modified number

--- Get attributes about a specific file or folder.
---
--- The returned attributes table contains information about the size of the file, whether it is a directory, when it was created and last modified, and whether it is read only.
---
--- The creation and modification times are given as the number of milliseconds since the UNIX epoch. This may be given to os.date in order to convert it to more usable form.
---@param path string The path to get attributes for.
---@return FsAttributes
function fs.attributes(path) end

---@class FlushSeekClose
local FlushSeekClose = {}

--- Save the current file without closing it.
function FlushSeekClose.flush() end

--- Seek to a new position within the file, changing where bytes are written to. The new position is an offset given by offset, relative to a start position determined by whence:
---
---  - "set": offset is relative to the beginning of the file.
---  - "cur": Relative to the current position. This is the default.
---  - "end": Relative to the end of the file.
---
--- In case of success, seek returns the new file position from the beginning of the file.
---@param whence string? # Where the offset is relative to.
---@param offset number? # The offset to seek to.
---@return number? # The new position, or nil if seeking failed.
---@return string? # The reason seeking failed.
function FlushSeekClose.seek(whence, offset) end

--- Close this file, freeing any resources it uses.
---
--- Once a file is closed it may no longer be read or written to.
function FlushSeekClose.close() end

--- A file handle opened for reading with fs.open.
---@class ReadHandle: FlushSeekClose
local ReadHandle = {}

--- Read a number of bytes from this file.
---@param count number? # The number of bytes to read. This may be 0 to determine we are at the end of the file. When absent, a single byte will be read.
---@return string | nil # The bytes read as a string, or 'nil' if we are at the end of the file.
function ReadHandle.read(count) end

--- Read the remainder of the file.
---@return string | nil # The remaining contents of the file, or nil if we are at the end.
function ReadHandle.readAll() end

--- Read a line from the file.
---@param withTrailing boolean? # Whether to include the newline characters with the returned string. Defaults to false.
---@return string | nil # The read line or nil if at the end of the file.
function ReadHandle.readLine(withTrailing) end

--- A file handle opened for writing by fs.open.
---@class WriteHandle: FlushSeekClose
local WriteHandle = {}

--- Write string to the file.
---@param contents string # The string to write
function WriteHandle.write(contents) end

--- Write a string of characters to the file, following them with a new line character.
---@param text string # The text to write to the file.
function WriteHandle.writeLine(text) end

--- A file handle opened for writing by fs.open.
---@class ReadWriteHandle: ReadHandle, WriteHandle
local ReadWriteHandle = {}

---@class ReadBytesHandle: FlushSeekClose
local ReadBytesHandle = {}

--- Read a number of bytes from this file.
---@param count number? # The number of bytes to read. This may be 0 to determine we are at the end of the file. When absent, a single byte will be read.
---@return number | string | nil # The value of the byte read. number for a single byte, string for multiple bytes
function ReadBytesHandle.read(count) end

--- Read the remainder of the file.
---@return string | nil # The remaining contents of the file, or nil if we are at the end.
function ReadBytesHandle.readAll() end

---@class WriteBytesHandle: FlushSeekClose
local WriteBytesHandle = {}

--- Write a byte to the file
---@param charcode number|string # The byte (or bytes) to write.
function WriteBytesHandle.write(charcode) end

---@class ReadWriteBytesHandle: ReadHandle, WriteHandle
local ReadWriteBytesHandle = {}

---@meta

http = {}

---@class Response : ReadHandle
local Response = {}

--- Returns the response code and response message returned by the server.
---@return number # The response code
---@return string # The response message
function Response.getResponseCode() end

--- Get a table containing the response's headers, in a format similar to that required by http.request. If multiple headers are sent with the same name, they will be combined with a comma.
---@return table<string, string> # The response's headers
function Response.getResponseHeaders() end

---@class ResponseBytes : ReadBytesHandle
local ResponseBytes = {}

--- Returns the response code and response message returned by the server.
---@return number # The response code
---@return string # The response message
function ResponseBytes.getResponseCode() end

--- Get a table containing the response's headers, in a format similar to that required by http.request. If multiple headers are sent with the same name, they will be combined with a comma.
---@return table<string, string> # The response's headers
function ResponseBytes.getResponseHeaders() end

---@class Request
---@field url string # The url to request
---@field body string? # The body of a post request.
---@field headers table<string, string>? # Additional headers to send as part of this request.
---@field binary boolean? # Whether the response handle should be opened in binary mode.
---@field method string? # Which HTTP method to use, for instance "PATCH" or "DELETE".
---@field redirect boolean? # Whether to follow HTTP redirects. Defaults to true.
---@field timeout number? # The connection timeout, in seconds.

--- Make a HTTP GET request to the given url.
---@param request Request # Options for this request.
---@return Response? # The resulting http response, which can be read from. Or nil if the http request failed, such as in the event of a 404 error or connection timeout.
---@return string? # A detailed error message.
---@return Response? # The failing http response, if available.
function http.get(request) end

--- Make a HTTP POST request to the given url.
---@param request Request # Options for this request.
---@return Response? # The resulting http response, which can be read from. Or nil if the http request failed, such as in the event of a 404 error or connection timeout.
---@return string? # A detailed error message.
---@return Response? # The failing http response, if available.
function http.post(request) end

--- Asynchronously make a HTTP request to the given url.
---
--- This returns immediately, a http_success or http_failure will be queued once the request has completed.
---@param request Request # Options for this request.
function http.request(request) end

--- Asynchronously determine whether a URL can be requested.
---
--- If this returns true, one should also listen for http_check which will container further information about whether the URL is allowed or not.
---@param url string # The URL to check
---@return boolean # Whether the URL is not invalid
---@return string? # A reason why this URL is not valid (for instance, if it is malformed, or blocked).
function http.checkURLAsync(url) end

--- Determine whether a URL can be requested.
---
--- If this returns true, one should also listen for http_check which will container further information about whether the URL is allowed or not.
---@param url string # The URL to check
---@return boolean # Whether the URL is not invalid
---@return string? # A reason why this URL is not valid (for instance, if it is malformed, or blocked).
function http.checkURL(url) end

---@class Websocket
local Websocket = {}

--- Wait for a message from the server.
---@param timeout number? # The number of seconds to wait if no message is received.
---@return string? # The received message, or nil if the websocket was closed.
---@return boolean? # If this was a binary message.
function Websocket.receive(timeout) end

--- Send a websocket message to the connected server.
---@param message string # The message to send.
---@param binary boolean? # Whether this message should be treated as a binary message.
function Websocket.send(message, binary) end

--- Close this websocket. This will terminate the connection, meaning messages can no longer be sent or received along it.
function Websocket.close() end

--- Asynchronously open a websocket.
---
--- This returns immediately, a websocket_success or websocket_failure will be queued once the request has completed.
---@param request Request # Options for this websocket.
function http.websocketAsync(request) end

--- Open a websocket.
---@param request Request # Options for this websocket.
---@return Websocket | boolean # The websocket connection, or false if the connection failed.
---@return string? # An error message describing why the connection failed
function http.websocket(request) end
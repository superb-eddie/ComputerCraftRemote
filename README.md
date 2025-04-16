# Computer Craft Remote
A remote terminal for Computer Craft!

## How it works
Computer Craft computers are not able to host a server and accept incoming connections.
To get around this, the remote client hosts a websocket endpoint and the CC computer initiates the connection.

## Structure
`ccr/` - The client code, this has the UI and websocket server.
`ccr_host/` - The host code, this runs on the CC computer to initiate a connection

##
Ideas
- Lua bundler
- Multiple computer connections
  - pull name from computer label
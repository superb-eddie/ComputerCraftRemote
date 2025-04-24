# Computer Craft Remote
A remote console for Computer Craft!

## Recommended Font
For the best results, you should install the Farifax HD font from Kreative Korp.
https://www.kreativekorp.com/software/fonts/fairfaxhd/

Computer craft's characters are translated into corresponding ascii characters.
You'll need a monospaced font with Latin-1, Sextant blocks, and the following Codepage 47 icons:
☺ ☻ ♥ ♦ ♣ ♠ • ◘ ♂ ♀ ♪ ♫ ► ◄ ↕ ‼ ¶ § ▬ ↨ ↑ ↓ → ← ∟ ↔ ▲ ▼

The monospace rendering code is not very intelligent and will trip up on fancier font's like Cascadia Mono.

## How it works
Computer Craft computers are not able to host a server and accept incoming connections.
To get around this, the remote client hosts a websocket endpoint and the CC computer initiates the connection.

## Structure

`ccr/` - The client code, this has the UI and websocket server.

`ccr_remote/` - The host code, this runs on the CC computer to initiate a connection
package console

import (
	"image"
	"image/color"
	"unicode/utf8"

	"gioui.org/io/key"
	"gioui.org/io/pointer"
	"gioui.org/text"
)

func popRune(buf []byte) ([]byte, rune) {
	r, rSize := utf8.DecodeRune(buf)
	return buf[rSize:], r
}

type cursor struct {
	position image.Point
	blink    bool

	// The color used when the cursor write
	foreground, background Color
}

type Console struct {
	Name string

	palette palette
	buffer  buffer
	cursor  cursor

	// Rendering things below this line
	glyphBuffer []text.Glyph
	glyphSize   image.Point
	screenSize  image.Point

	heldKeys          map[key.Name]struct{}
	prevMouseButtons  pointer.Buttons
	prevMousePosition image.Point
}

func NewConsole(name string) *Console {
	startingSize := image.Pt(50, 50)

	console := &Console{
		Name:    name,
		palette: defaultPalette(),
		buffer:  newBuffer(),
		cursor: cursor{
			position:   image.Pt(0, 0),
			blink:      true,
			foreground: ColorWhite,
			background: ColorBlack,
		},
		glyphBuffer:      make([]text.Glyph, 0, startingSize.X),
		heldKeys:         map[key.Name]struct{}{},
		prevMouseButtons: 0,
	}
	console.buffer.resize(startingSize)

	return console
}

func (c *Console) SetConsoleName(name string) {
	c.Name = name
}

func (c *Console) UpdateFromRemote(remote ScreenUpdatePacket) {
	c.buffer.updateFromRemote(remote.Buffer)

	for b, parts := range remote.Palette {
		c.palette.set(colorFromHexByte(b[0]), color.NRGBA{
			R: uint8(parts[0] * 255.0),
			G: uint8(parts[1] * 255.0),
			B: uint8(parts[2] * 255.0),
			A: 0xFF,
		})
	}

	c.cursor.position = image.Pt(
		remote.Cursor.X-1,
		remote.Cursor.Y-1,
	)
	c.cursor.blink = remote.Cursor.Blink
}

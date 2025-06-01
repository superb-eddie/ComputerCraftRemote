package console

import (
	"image"
	"image/color"
	"unicode/utf8"

	"gioui.org/io/key"
	"gioui.org/io/pointer"
	"gioui.org/text"
)

// cp437 contains the characters that cc borrows from codepage 437 in the order that cc uses them (spacers included for unused chars)
var cp437 = []rune{' ', '☺', '☻', '♥', '♦', '♣', '♠', '•', '◘', ' ', ' ', '♂', '♀', ' ', '♪', '♫', '►', '◄', '↕', '‼', '¶', '§', '▬', '↨', '↑', '↓', '→', '←', '∟', '↔', '▲', '▼'}

// fromCCCharset maps Computer Craft's character set to Unicode
func fromCCCharset(char rune) rune {
	if (char < 0x00) || (char > 0xFF) {
		return '�' // Not in range
	}

	// Get the easy cases out of the way
	switch char {
	case '\t', '\n', '\r':
		// These characters aren't rendered
		return ' '
	case 0x7F:
		// DEL in the ascii range. cc renders a shading character
		return '░'
	case 0xAD:
		// Soft hyphen in the latin1 range.
		// Most fonts don't render it but cc renders it like a typical hyphen
		return '-'
	case 0x80:
		// In the teletext range, but not rendered
		return ' '
	case 0x95:
		// In the teletext range, but it's replaced with a character outside Unicode's sextant blocks
		return '▌'
	}

	// Chars borrowed from IBM's code page 437
	isCP437 := char < 0x20
	if isCP437 {
		return cp437[uint(char)]
	}

	// Chars borrow from teletext
	isTeletext := (char >= 0x80) && (char < 0xA0)
	if isTeletext {
		// We use sextant blocks to emulate these characters.
		// The blocks are used in the same order they appear in utf8, except for two holes at 0x80 and 0x95
		// https://www.unicode.org/charts/PDF/U1FB00.pdf
		offset := 1
		if char >= 0x95 {
			offset += 1
		}

		return '\U0001FB00' + (char - rune(0x80+offset))
	}

	// If we haven't matched the character by this point, then it should be an
	//  ascii or latin1 character which uses that same codepoint as Unicode.
	return char
}

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

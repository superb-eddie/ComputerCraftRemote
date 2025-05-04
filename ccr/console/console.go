package console

import (
	"image"
	"image/color"
	"unicode/utf8"

	"gioui.org/io/key"
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
	glyphBuffer  []text.Glyph
	glyphSize    image.Point
	screenSize   image.Point
	invertColors bool

	heldKeys map[key.Name]struct{}
}

func NewConsole(name string, invertColors bool) *Console {
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
		glyphBuffer:  make([]text.Glyph, 0, startingSize.X),
		invertColors: invertColors,
		heldKeys:     map[key.Name]struct{}{},
	}
	console.buffer.resize(startingSize)

	return console
}

func (c *Console) SetConsoleName(name string) {
	c.Name = name
}

func (c *Console) Clear() {
	c.buffer.clear()
}

func (c *Console) ClearLine() {
	c.buffer.clearLine(c.cursor.position.Y)
}

func (c *Console) Write(text string) {
	if !utf8.ValidString(text) {
		panic("text is not valid utf8")
	}
	textBuf := []byte(text)
	runeCount := utf8.RuneCount(textBuf)

	// Most writes are treated as a no-op if the cursor is off the screen, except when
	//  the cursor is off the left edge and the string is long enough to reach the screen
	bufferSize := c.buffer.size()
	cursorPos := c.cursor.position

	inYBounds := cursorPos.Y >= 0 && cursorPos.Y < bufferSize.Y
	inXBounds := (cursorPos.X+runeCount) >= 0 && cursorPos.X < bufferSize.X
	if !(inYBounds && inXBounds) {
		return
	}

	var r rune
	for cursorPos.X < bufferSize.X {

		textBuf, r = popRune(textBuf)
		if r == utf8.RuneError {
			// String ended or isn't valid utf8
			break
		}

		if cursorPos.X >= 0 {
			c.buffer.setCell(
				cursorPos,
				fromCCCharset(r),
				c.cursor.foreground,
				c.cursor.background,
			)
		}

		cursorPos.X += 1
	}

	c.cursor.position = cursorPos
}

func (c *Console) Blit(text, foreground, background string) {
	for _, s := range []string{text, foreground, background} {
		if !utf8.ValidString(s) {
			panic("text is not valid utf8")
		}
	}

	foregroundBuf := []byte(foreground)
	backgroundBuf := []byte(background)
	textBuf := []byte(text)
	runeCount := utf8.RuneCount(textBuf)

	// Most writes are treated as a no-op if the cursor is off the screen, except when
	//  the cursor is off the left edge and the string is long enough to reach the screen
	bufferSize := c.buffer.size()
	cursorPos := c.cursor.position

	inYBounds := cursorPos.Y >= 0 && cursorPos.Y < bufferSize.Y
	inXBounds := (cursorPos.X+runeCount) >= 0 && cursorPos.X < bufferSize.X
	if !(inYBounds && inXBounds) {
		return
	}

	var r, fr, br rune
	for cursorPos.X < bufferSize.X {

		textBuf, r = popRune(textBuf)
		if r == utf8.RuneError {
			break
		}

		foregroundBuf, fr = popRune(foregroundBuf)
		if fr == utf8.RuneError {
			break
		}

		backgroundBuf, br = popRune(backgroundBuf)
		if br == utf8.RuneError {
			break
		}

		if cursorPos.X >= 0 {
			c.buffer.setCell(
				cursorPos,
				fromCCCharset(r),
				colorFromHexDigit(fr),
				colorFromHexDigit(br),
			)
		}

		cursorPos.X += 1
	}

	c.cursor.position = cursorPos
}

func (c *Console) Scroll(y int) {
	c.buffer.scroll(y)
}

func (c *Console) SetCursorPosition(x, y int) {
	c.cursor.position.X = x
	c.cursor.position.Y = y
}

func (c *Console) SetCursorBlink(blink bool) {
	c.cursor.blink = blink
	//c.cursorOn = blink
}

func (c *Console) SetForegroundColor(index Color) {
	c.cursor.foreground = index
}

func (c *Console) SetBackgroundColor(index Color) {
	c.cursor.background = index
}

func (c *Console) SetPaletteColor(index Color, r, g, b float32) {
	c.palette.set(index, color.NRGBA{
		R: uint8(r * 255.0),
		G: uint8(g * 255.0),
		B: uint8(b * 255.0),
		A: 0xFF,
	})
}

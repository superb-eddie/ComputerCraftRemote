package console

import (
	"image"
	"image/color"
	"unicode/utf8"

	"gioui.org/io/key"
	"gioui.org/text"
)

func isPrintableChar(char rune) bool {
	return (char >= 0x00) && (char <= 0xFF)
}

// The characters that cc's charset borrows from codepage 437 in the order they appear in cc
var cp437 = []rune{' ', '☺', '☻', '♥', '♦', '♣', '♠', '•', '◘', ' ', ' ', '♂', '♀', ' ', '♪', '♫', '►', '◄', '↕', '‼', '¶', '§', '▬', '↨', '↑', '↓', '→', '←', '∟', '↔', '▲', '▼'}

func fromCCCharset(char rune) rune {
	if !isPrintableChar(char) {
		return '�'
	}

	// Computer craft's charset borrow from a couple different places
	if char == 0x7F {
		return '░'
	}

	isSpecial := char == '\t' || char == '\n' || char == '\r'
	isAscii := (char >= 0x20) && (char <= 0x7F)
	isLatin1 := (char >= 0xA0) && (char <= 0xFF)
	if isSpecial || isAscii || isLatin1 {
		return char
	}

	// characters borrowed from cp437
	isCP437 := (char >= 0x00) && (char <= 0x1f)
	if isCP437 {
		return cp437[uint(char)]
	}

	// characters borrow from teletext
	isTeletext := (char >= 0x80) && (char <= 0x9f)
	if isTeletext {
		// Block Sextant-1
		// https://www.unicode.org/charts/PDF/U1FB00.pdf
		return '\U0001FB00' + (char - 0x80)
	}

	return '�'
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
	//cursorOn    bool

	heldKeys map[key.Name]struct{}
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
		glyphBuffer: make([]text.Glyph, 0, startingSize.X),
		//cursorOn:    true,
		heldKeys: map[key.Name]struct{}{},
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

	pos := c.cursor.position
	if !c.buffer.inBounds(c.cursor.position) {
		return
	}
	bufferWidth := c.buffer.size().X

	textBuf := []byte(text)

	var r rune
	for pos.X < bufferWidth {
		textBuf, r = popRune(textBuf)
		if r == utf8.RuneError {
			// String ended or isn't valid utf8
			break
		}

		c.buffer.setCell(
			pos,
			fromCCCharset(r),
			c.cursor.foreground,
			c.cursor.background,
		)

		pos.X += 1
	}

	c.cursor.position = pos
}

func (c *Console) Blit(text, foreground, background string) {
	for _, s := range []string{text, foreground, background} {
		if !utf8.ValidString(s) {
			panic("text is not valid utf8")
		}
	}

	pos := c.cursor.position
	if !c.buffer.inBounds(c.cursor.position) {
		return
	}
	bufferWidth := c.buffer.size().X

	textBuf := []byte(text)
	foregroundBuf := []byte(foreground)
	backgroundBuf := []byte(background)

	var r, fr, br rune
	for pos.X < bufferWidth {
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

		c.buffer.setCell(
			pos,
			fromCCCharset(r),
			colorFromHexDigit(fr),
			colorFromHexDigit(br),
		)

		pos.X += 1
	}

	c.cursor.position = pos
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

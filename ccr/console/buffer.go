package console

import (
	"fmt"
	"image"
	"unicode/utf8"
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

type buffer struct {
	_size image.Point // console size in characters

	chars                  []rune
	foreground, background []Color
}

func newBuffer() buffer {
	return buffer{}
}

func (b *buffer) getLine(y int) (text []rune, foreground, background []Color) {
	if y >= b._size.Y {
		panic(fmt.Sprintf("Line %d/%d is out of bounds", y, b._size.Y))
	}

	i, j := index2DBufferLine(b._size, y)

	return b.chars[i:j], b.foreground[i:j], b.background[i:j]
}

func (b *buffer) inBounds(cell image.Point) bool {
	return (cell.X >= 0 && cell.X < b._size.X) &&
		(cell.Y >= 0 && cell.Y < b._size.Y)
}

func (b *buffer) setCell(cell image.Point, char rune, foreground, background Color) {
	if !b.inBounds(cell) {
		panic("Out of bounds!")
	}

	i := index2DBuffer(b._size, cell)
	b.chars[i] = char
	b.foreground[i] = foreground
	b.background[i] = background
}

func (b *buffer) getCell(cell image.Point) (char rune, foreground, background Color) {
	if !b.inBounds(cell) {
		panic("Out of bounds!")
	}

	i := index2DBuffer(b._size, cell)
	return b.chars[i], b.foreground[i], b.background[i]
}

func (b *buffer) size() image.Point {
	return b._size
}
func (b *buffer) resize(newSize image.Point) {
	oldLength := b._size.X * b._size.Y
	newLength := newSize.X * newSize.Y

	if oldLength == newLength {
		return
	}

	b.chars = resize2DBuffer(b.chars, newLength)
	b.foreground = resize2DBuffer(b.foreground, newLength)
	b.background = resize2DBuffer(b.background, newLength)
	b._size = newSize
}

func toAsciiBytes(txt string) []byte {
	utf8Bytes := []byte(txt)
	asciiBytes := make([]byte, utf8.RuneCount(utf8Bytes))

	for i := 0; i < len(asciiBytes); i++ {
		r, size := utf8.DecodeRune(utf8Bytes)
		utf8Bytes = utf8Bytes[size:]

		if r > 0xFF {
			panic("Rune too large")
		}
		asciiBytes[i] = byte(r)
	}

	return asciiBytes
}

func (b *buffer) updateFromRemote(remoteBuffer ScreenBuffer) {
	b.resize(image.Pt(
		remoteBuffer.Size.X,
		remoteBuffer.Size.Y,
	))

	for y, row := range remoteBuffer.Rows {
		// These are encoded with cc's own ascii compatible encoding
		chars := toAsciiBytes(row.Chars)
		fg := toAsciiBytes(row.Fg)
		bg := toAsciiBytes(row.Bg)

		length := len(chars)
		if length != b._size.X {
			println(fmt.Sprintf("y = %d, remote x = %d, buffer x = %d", y, length, b._size.X))
			panic("Rows must have the same width as buffer")
		}

		if len(fg) != length || len(bg) != length {
			panic("Rows parts must have the same length")
		}

		starti, _ := index2DBufferLine(b._size, y)
		for i := 0; i < length; i++ {
			b.chars[starti+i] = fromCCCharset(rune(chars[i]))
			b.foreground[starti+i] = colorFromHexByte(fg[i])
			b.background[starti+i] = colorFromHexByte(bg[i])
		}
	}
}

func index2DBufferLine(size image.Point, y int) (int, int) {
	start := size.X * y
	return start, start + size.X
}

func index2DBuffer(size, cell image.Point) int {
	return (size.X * cell.Y) + cell.X
}

func resize2DBuffer[T any](buf []T, newLength int) []T {
	if newLength <= cap(buf) {
		return buf[:newLength]
	}

	return make([]T, newLength)
}

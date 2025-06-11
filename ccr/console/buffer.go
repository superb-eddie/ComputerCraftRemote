package console

import (
	"fmt"
	"image"
)

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

func (b *buffer) updateFromRemote(remoteBuffer ScreenBuffer) {
	b.resize(image.Pt(
		remoteBuffer.Size.X,
		remoteBuffer.Size.Y,
	))

	for y, row := range remoteBuffer.Rows {
		// These are encoded with cc's own ascii compatible encoding
		chars := []byte(row.Chars)
		fg := []byte(row.Fg)
		bg := []byte(row.Bg)

		length := len(chars)
		if length != b._size.X {
			println(length)
			println(b._size.X)
			panic("Rows must have the same width as buffer")
		}

		if len(fg) != length || len(bg) != length {
			panic("Rows parts must have the same length")
		}

		starti, _ := index2DBufferLine(b._size, y)
		for i := 0; i < length; i++ {
			b.chars[starti+i] = rune(chars[i])
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

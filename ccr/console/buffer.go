package console

import (
	"fmt"
	"image"
)

const clearChar = ' '
const clearForeground = ColorWhite
const clearBackground = ColorBlack

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
	b.chars = resize2DBuffer(b.chars, b._size, newSize, clearChar)
	b.foreground = resize2DBuffer(b.foreground, b._size, newSize, clearForeground)
	b.background = resize2DBuffer(b.background, b._size, newSize, clearBackground)
	b._size = newSize
}

func (b *buffer) clear() {
	for y := 0; y < b._size.Y; y++ {
		b.clearLine(y)
	}
}

func (b *buffer) clearLine(y int) {
	if y >= b._size.Y {
		return
	}

	for x := 0; x < b._size.X; x++ {
		i := index2DBuffer(b._size, image.Pt(x, y))
		b.chars[i] = clearChar
		b.foreground[i] = clearForeground
		b.background[i] = clearBackground
	}
}

func (b *buffer) scroll(offset int) {
	scrollLine := func(y int) {
		var lineContent func(x int) (rune, Color, Color)
		ny := y + offset
		if ny < 0 || ny >= b._size.Y {
			// Clear line y, no contents to take
			lineContent = func(_ int) (rune, Color, Color) {
				return clearChar, clearForeground, clearBackground
			}
		} else {
			// Take contents from line ny
			lineContent = func(x int) (rune, Color, Color) {
				i := index2DBuffer(b._size, image.Pt(x, ny))
				return b.chars[i], b.foreground[i], b.background[i]
			}
		}

		// Copy contents from line ny to line y
		for x := 0; x < b._size.X; x++ {
			i := index2DBuffer(b._size, image.Pt(x, y))
			b.chars[i], b.foreground[i], b.background[i] = lineContent(x)
		}
	}

	//	Call scroll line for each line in either forward or reverse order depending on scroll direction
	if offset > 0 {
		// moving lines up
		for y := 0; y < b._size.Y; y++ {
			scrollLine(y)
		}
	} else {
		// moving lines down
		for y := b._size.Y - 1; y >= 0; y-- {
			scrollLine(y)
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

func resize2DBuffer[T any](buf []T, oldSize, newSize image.Point, filler T) []T {
	// Try to do as little as possible while resizing the buffer
	if oldSize == newSize {
		return buf
	}

	oldLength := oldSize.X * oldSize.Y
	newLength := newSize.X * newSize.Y
	if newLength <= cap(buf) {
		if newLength > oldLength {
			// Buffer is growing, make room for new rows
			buf = buf[:newLength]
		}

		// Rearrange rows in place to fit new layout
		if oldSize.X > newSize.X {
			width := newSize.X
			for y := 1; y < min(oldSize.Y, newSize.Y); y++ {
				oldi := oldSize.X * y
				newi := newSize.X * y
				copy(buf[newi:newi+width], buf[oldi:oldi+width])
			}
		} else if oldSize.X < newSize.X {
			// We go in reverse here to avoid clobbering data we need
			width := oldSize.X
			for y := newSize.Y - 1; y > 0; y-- {
				oldi := oldSize.X * y
				newi := newSize.X * y
				copy(buf[newi:newi+width], buf[oldi:oldi+width])

				// Fill extra columns
				for x := width; x < newSize.X; x++ {
					buf[newi+x] = filler
				}
			}
			// Fill extra columns on the first row
			for x := width; x < newSize.X; x++ {
				buf[x] = filler
			}
		}

		// Fill any new rows
		if newSize.Y > oldSize.Y {
			for y := oldSize.Y; y < newSize.Y; y++ {
				for x := 0; x < newSize.X; x++ {
					buf[(newSize.X*y)+x] = filler
				}
			}
		}

		if newLength <= oldLength {
			// Buffer is shrinking, remove old rows
			buf = buf[:newLength]
		}
		return buf
	} else {
		// Buffer is growing and it doesn't have enough capacity
		newBuf := make([]T, newLength)
		width := min(oldSize.X, newSize.X)
		for y := 0; y < newSize.Y; y++ {
			oldi := oldSize.X * y
			newi := newSize.X * y

			if y < oldSize.Y {
				copy(newBuf[newi:newi+width], buf[oldi:oldi+width])
				for x := width; x < newSize.X; x++ {
					newBuf[newi+x] = filler
				}
			} else {
				for x := 0; x < newSize.X; x++ {
					newBuf[newi+x] = filler
				}
			}
		}

		return newBuf
	}
}

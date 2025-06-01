package console

import "image/color"

type Color uint

const (
	ColorWhite Color = 1 << iota
	ColorOrange
	ColorMagenta
	ColorLightBlue
	ColorYellow
	ColorLime
	ColorPink
	ColorGray
	ColorLightGray
	ColorCyan
	ColorPurple
	ColorBlue
	ColorBrown
	ColorGreen
	ColorRed
	ColorBlack
)

func colorFromHexByte(b byte) Color {
	c := uint(b % 16)
	if b >= '0' && b <= '9' {
		c = uint(b - '0')
	} else if b >= 'A' && b <= 'F' {
		c = uint(10 + (b - 'A'))
	} else if b >= 'a' && b <= 'f' {
		c = uint(10 + (b - 'a'))
	}
	return Color(1 << c)
}

func colorFromHexDigit(d rune) Color {
	return colorFromHexByte(byte(d))
}

func colorIndex(c Color) uint {
	if c <= 0 {
		return 0
	}
	for i := 0; i < 16; i++ {
		if c>>i == 1 {
			return uint(i)
		}
	}
	return 15
}

type palette struct {
	p [16]color.NRGBA
}

func (p *palette) get(c Color) color.NRGBA {
	return p.p[colorIndex(c)]
}

func (p *palette) set(c Color, cc color.NRGBA) {
	p.p[colorIndex(c)] = cc
}

func defaultPalette() palette {
	return palette{
		p: [16]color.NRGBA{
			{R: 0xf0, G: 0xf0, B: 0xf0, A: 0xFF}, // White
			{R: 0xf2, G: 0xb2, B: 0x33, A: 0xFF}, // Orange
			{R: 0xe5, G: 0x7f, B: 0xd8, A: 0xFF}, // Magenta
			{R: 0x99, G: 0xb2, B: 0xf2, A: 0xFF}, // Light Blue
			{R: 0xde, G: 0xde, B: 0x6c, A: 0xFF}, // Yellow
			{R: 0x7f, G: 0xcc, B: 0x19, A: 0xFF}, // Lime
			{R: 0xf2, G: 0xb2, B: 0xcc, A: 0xFF}, // Pink
			{R: 0x4c, G: 0x4c, B: 0x4c, A: 0xFF}, // Gray
			{R: 0x99, G: 0x99, B: 0x99, A: 0xFF}, // Light Gray
			{R: 0x4c, G: 0x99, B: 0xb2, A: 0xFF}, // Cyan
			{R: 0xb2, G: 0x66, B: 0xe5, A: 0xFF}, // Purple
			{R: 0x33, G: 0x66, B: 0xcc, A: 0xFF}, // Blue
			{R: 0x7f, G: 0x66, B: 0x4c, A: 0xFF}, // Brown
			{R: 0x57, G: 0xa6, B: 0x4e, A: 0xFF}, // Green
			{R: 0xcc, G: 0x4c, B: 0x4c, A: 0xFF}, // Red
			{R: 0x11, G: 0x11, B: 0x11, A: 0xFF}, // Black
		},
	}
}

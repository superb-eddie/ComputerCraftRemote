package widgets

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	"math"

	"gioui.org/font"
	"gioui.org/layout"
	"gioui.org/text"
	"gioui.org/unit"
	"golang.org/x/image/math/fixed"
)

var fontFace string

func init() {
	flag.StringVar(&fontFace, "font", "Fairfax SM HD", "Default font")
}

type UIColors struct {
	TextColor color.NRGBA

	Background    color.NRGBA
	BackgroundAlt color.NRGBA // for modals, hover, etc

	Outline    color.NRGBA
	OutlineAlt color.NRGBA
}

func (uc *UIColors) BackgroundColor(alt bool) color.NRGBA {
	if alt {
		return uc.BackgroundAlt
	} else {
		return uc.Background
	}
}
func (uc *UIColors) OutlineColor(alt bool) color.NRGBA {
	if alt {
		return uc.OutlineAlt
	} else {
		return uc.Outline
	}
}

// Style holds global style options for the console
type Style struct {
	Shaper        *text.Shaper
	TextSize      unit.Sp
	Typeface      font.Typeface
	fontSizeCache map[font.Typeface]image.Point // Assumes a monospace font
	PanelPadding  unit.Dp
	OutlineWidth  unit.Dp
	UI            UIColors
}

func DefaultStyle(shaper *text.Shaper) Style {
	// Choose a single font from the Typeface

	return Style{
		Shaper:       shaper,
		TextSize:     20,
		Typeface:     font.Typeface(fmt.Sprintf("\"%s\", monospace", fontFace)),
		PanelPadding: unit.Dp(2),
		OutlineWidth: unit.Dp(2),
		UI: UIColors{
			TextColor:     color.NRGBA{R: 0xF4, G: 0xF4, B: 0xF4, A: 0xFF},
			Background:    color.NRGBA{R: 0x16, G: 0x16, B: 0x16, A: 0xFF},
			BackgroundAlt: color.NRGBA{R: 0x26, G: 0x26, B: 0x26, A: 0xFF},
			Outline:       color.NRGBA{R: 0x6F, G: 0x6F, B: 0x6F, A: 0x6F},
			OutlineAlt:    color.NRGBA{R: 0x45, G: 0x89, B: 0xFF, A: 0xFF},
		},
	}
}

func (s *Style) LayoutParameters(gtx layout.Context) text.Parameters {
	return text.Parameters{
		Font: font.Font{
			Typeface: s.Typeface,
		},
		Alignment:        text.Start,
		PxPerEm:          fixed.I(gtx.Sp(s.TextSize)),
		MaxLines:         1,
		WrapPolicy:       text.WrapGraphemes,
		MinWidth:         0,
		MaxWidth:         math.MaxInt,
		Locale:           gtx.Locale,
		DisableSpaceTrim: true,
	}
}

func (s *Style) MeasureGlyph(gtx layout.Context, char rune) image.Point {
	if s.fontSizeCache == nil {
		s.fontSizeCache = map[font.Typeface]image.Point{}
	} else if size, ok := s.fontSizeCache[s.Typeface]; ok {
		return size
	}

	size := measureGlyph(gtx, s, char)
	s.fontSizeCache[s.Typeface] = size
	return size
}

func measureGlyph(gtx layout.Context, style *Style, char rune) image.Point {
	style.Shaper.LayoutString(style.LayoutParameters(gtx), string(char))

	var glyphs []text.Glyph
	for {
		glyph, ok := style.Shaper.NextGlyph()
		if !ok {
			break
		}

		glyphs = append(glyphs, glyph)
	}

	if len(glyphs) != 1 {
		panic("Expected only one glyph")
	}

	glyph := glyphs[0]

	return image.Pt(
		glyph.Advance.Floor(),
		(glyph.Ascent + glyph.Descent).Ceil(),
	)
}

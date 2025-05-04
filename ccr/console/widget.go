package console

import (
	"image"
	"io"

	"gioui.org/io/clipboard"
	"gioui.org/io/event"
	"gioui.org/io/key"
	"gioui.org/io/semantic"
	"gioui.org/io/transfer"
	"gioui.org/layout"
	"gioui.org/op"
	"gioui.org/op/clip"
	"gioui.org/op/paint"
	"gioui.org/text"

	"ccr/ccr/widgets"
)

// The rendering methods on the console

func (c *Console) FocusTag() event.Tag {
	return c
}

func (c *Console) Update(gtx layout.Context, style *widgets.Style) (events []CCEvent) {
	c.glyphSize = style.MeasureGlyph(gtx, 'A') // Measure any old character, this font should be monospaced
	var rowColSize image.Point
	rowColSize, c.screenSize = calcScreenSize(gtx.Constraints, c.glyphSize)

	if c.buffer.size() != rowColSize {
		c.buffer.resize(rowColSize)
		events = append(events, mkTermResize(rowColSize.X, rowColSize.Y))
	}

	if !gtx.Focused(c.FocusTag()) {
		return
	}

	for {
		e, ok := gtx.Event(
			key.Filter{
				Name:     "V",
				Required: key.ModCommand | key.ModCtrl,
			},
			key.Filter{
				Optional: key.ModShift | key.ModCommand | key.ModCtrl | key.ModAlt | key.ModSuper,
			},
			key.Filter{
				Name:     key.NameTab,
				Optional: key.ModShift | key.ModCommand | key.ModCtrl | key.ModAlt | key.ModSuper,
			},
			transfer.TargetFilter{
				Target: c.FocusTag(),
				Type:   "application/text",
			},
		)

		if !ok {
			break
		}
		switch e := e.(type) {
		case transfer.DataEvent:
			raw, _ := io.ReadAll(e.Open())
			events = append(events, mkPaste(string(raw)))
		case key.Event:
			keycode, char, ok := translateKey(e.Name, e.Modifiers)
			if !ok {
				continue
			}

			if e.State == key.Press {
				_, held := c.heldKeys[e.Name]
				if !held {
					c.heldKeys[e.Name] = struct{}{}
				}

				if e.Name == "V" && (e.Modifiers.Contain(key.ModCommand) || e.Modifiers.Contain(key.ModCtrl)) {
					gtx.Execute(clipboard.ReadCmd{
						Tag: c.FocusTag(),
					})
					continue
				}

				if held && e.Name == "T" && (e.Modifiers.Contain(key.ModCommand) || e.Modifiers.Contain(key.ModCtrl)) {
					events = append(events, mkTerminate())
					continue
				}

				events = append(events, mkKeyDownEvent(keycode, held))

				if char != "" {
					events = append(events, mkCharEvent(char))
				}

			} else {
				delete(c.heldKeys, e.Name)
				events = append(events, mkKeyUpEvent(keycode))
			}

		}
	}

	return
}

func (c *Console) Layout(gtx layout.Context, style *widgets.Style) (dimensions layout.Dimensions) {
	clipStack := clip.Rect(image.Rect(0, 0, c.screenSize.X, c.screenSize.Y)).Push(gtx.Ops)
	defer clipStack.Pop()

	event.Op(gtx.Ops, c.FocusTag())
	key.InputHintOp{
		Tag:  c.FocusTag(),
		Hint: key.HintAny,
	}.Add(gtx.Ops)

	lineSize := image.Pt(c.screenSize.X, c.glyphSize.Y)

	// Paint text
	for line := 0; line < c.buffer.size().Y; line++ {
		lineText, lineForeground, lineBackground := c.buffer.getLine(line)

		lineOffsetStack := op.Offset(image.Pt(0, line*c.glyphSize.Y)).Push(gtx.Ops)
		clipStack := clip.Rect(image.Rectangle{Max: lineSize}).Push(gtx.Ops)

		paintLineBackground(gtx, c.glyphSize, lineBackground, c.palette, c.invertColors)
		paintLineForeground(gtx, c.glyphBuffer, lineText, lineForeground, c.palette, style, c.invertColors)

		clipStack.Pop()
		lineOffsetStack.Pop()
	}

	// Paint cursor
	if c.cursor.blink {
		// TODO: This causes cursor to blink every time screen is redrawn
		//gtx.Execute(op.InvalidateCmd{At: time.Now().Add(time.Second / 2)})
		//c.cursorOn = !c.cursorOn
		//if c.cursorOn {
		cursorHeight := c.glyphSize.X / 10
		cursorLocation := image.Pt(
			c.cursor.position.X*c.glyphSize.X,
			((c.cursor.position.Y+1)*c.glyphSize.Y)-cursorHeight,
		)

		offsetStack := op.Offset(cursorLocation).Push(gtx.Ops)

		paint.FillShape(gtx.Ops,
			c.palette.get(c.cursor.foreground, c.invertColors),
			clip.Rect(image.Rect(
				0, 0,
				c.glyphSize.X, cursorHeight,
			)).Op(),
		)

		offsetStack.Pop()
		//}
	}

	return layout.Dimensions{
		Size: c.screenSize,
	}
}

// calcScreenSize calculate the max size that can fit in the constraints given this glyph size
func calcScreenSize(cs layout.Constraints, glyphSize image.Point) (charSize, realSize image.Point) {
	charSize = image.Pt(
		cs.Max.X/glyphSize.X,
		cs.Max.Y/glyphSize.Y,
	)

	// Real size
	return charSize, image.Pt(
		charSize.X*glyphSize.X,
		charSize.Y*glyphSize.Y,
	)
}

func paintLineForeground(gtx layout.Context, glyphBuffer []text.Glyph, line []rune, foreground []Color, pal palette, style *widgets.Style, invertedColors bool) {
	lineText := string(line)

	style.Shaper.LayoutString(style.LayoutParameters(gtx), lineText)

	semantic.DescriptionOp(lineText).Add(gtx.Ops)

	var glyphBufferColor Color
	var glyphBufferDot image.Point
	glyphBuffer = glyphBuffer[:0]
	paintBuffer := func() {
		if len(glyphBuffer) == 0 {
			return
		}

		offsetOpStack := op.Offset(glyphBufferDot).Push(gtx.Ops)

		// Paint vector glyphs
		path := style.Shaper.Shape(glyphBuffer)
		outlineOpStack := clip.Outline{Path: path}.Op().Push(gtx.Ops)
		paint.ColorOp{Color: pal.get(glyphBufferColor, invertedColors)}.Add(gtx.Ops)
		paint.PaintOp{}.Add(gtx.Ops)
		outlineOpStack.Pop()

		// Paint bitmap glyphs (if any)
		if bitmapOp := style.Shaper.Bitmaps(glyphBuffer); bitmapOp != (op.CallOp{}) {
			// TODO: How do these glyphs get their color?
			bitmapOp.Add(gtx.Ops)
		}

		offsetOpStack.Pop()
	}

	runeI := 0
	nextGlyph := func() (glyph text.Glyph, col Color, ok bool) {
		glyph, ok = style.Shaper.NextGlyph()
		if !ok {
			return
		}
		col = foreground[runeI]
		runeI += int(glyph.Runes)

		return
	}

	// Glyphs are painted in batches split by color
	for {
		glyph, glyphColor, ok := nextGlyph()
		if !ok {
			break
		}

		isFirstGlyphInLine := len(glyphBuffer) == 0
		isGlyphColorChanging := glyphBufferColor != glyphColor

		isStartOfChunk := isFirstGlyphInLine || isGlyphColorChanging
		if !isStartOfChunk {
			glyphBuffer = append(glyphBuffer, glyph)
			continue
		}

		if !isFirstGlyphInLine {
			// Paint the old block before starting a new block
			paintBuffer()
			glyphBuffer = glyphBuffer[:0]
		}

		glyphBufferDot = image.Pt(glyph.X.Floor(), int(glyph.Y))
		glyphBufferColor = glyphColor
		glyphBuffer = append(glyphBuffer, glyph)
	}

	// Paint any remaining characters
	paintBuffer()
}

func paintLineBackground(gtx layout.Context, glyphSize image.Point, background []Color, pal palette, invertColors bool) {
	var currentColor Color
	var currentBounds image.Rectangle
	paintBlock := func() {
		paint.FillShape(gtx.Ops, pal.get(currentColor, invertColors), clip.Rect(currentBounds).Op())
	}

	for i := range background {
		isFirstCell := i == 0
		isColorChanging := currentColor != background[i]

		isStartOfNewBlock := isFirstCell || isColorChanging

		if !isStartOfNewBlock {
			currentBounds.Max.X += glyphSize.X
			continue
		}

		if !isFirstCell {
			paintBlock()
		}

		currentColor = background[i]
		currentBounds = image.Rectangle{
			Max: glyphSize,
		}.Add(image.Pt(i*glyphSize.X, 0))

	}
	paintBlock()
}

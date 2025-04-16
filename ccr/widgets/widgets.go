package widgets

import (
	"image"

	"gioui.org/layout"
	"gioui.org/op"
	"gioui.org/op/clip"
	"gioui.org/op/paint"
	"gioui.org/widget"
)

func Label(style *Style, text string) layout.Widget {
	return func(gtx layout.Context) layout.Dimensions {
		txtParams := style.LayoutParameters(gtx)

		macro := op.Record(gtx.Ops)
		paint.ColorOp{Color: style.UI.TextColor}.Add(gtx.Ops)
		txtMaterial := macro.Stop()

		return widget.Label{}.Layout(gtx, style.Shaper, txtParams.Font, style.TextSize, text, txtMaterial)
	}
}

func Rect(size image.Point) image.Rectangle {
	return image.Rectangle{Max: size}
}

func ClipRect(size image.Point) clip.Rect {
	return clip.Rect(Rect(size))
}

type ClipOpper interface {
	Op() clip.Op
}

type ClipPather interface {
	Path() clip.PathSpec
}

func ClipOutline(p ClipPather) clip.Outline {
	return clip.Outline{Path: p.Path()}
}

func ClipStroke(p ClipPather, width float32) clip.Stroke {
	return clip.Stroke{Path: p.Path(), Width: width}
}

func PaintOutline(gtx layout.Context, style *Style, alt bool, p ClipPather) {
	paint.FillShape(gtx.Ops, style.UI.OutlineColor(alt), ClipStroke(p, float32(gtx.Dp(style.OutlineWidth))).Op())
}

func WithOutline(style *Style, alt bool, w layout.Widget) layout.Widget {
	return func(gtx layout.Context) layout.Dimensions {
		dimensions := w(gtx)

		PaintOutline(gtx, style, alt, ClipRect(dimensions.Size))
		return dimensions
	}
}

func PaintBackground(gtx layout.Context, style *Style, alt bool, o ClipOpper) {
	paint.FillShape(gtx.Ops, style.UI.BackgroundColor(alt), o.Op())
}

func WithBackground(style *Style, alt bool, w layout.Widget) layout.Widget {
	return func(gtx layout.Context) layout.Dimensions {
		macro := op.Record(gtx.Ops)
		dimensions := w(gtx)
		paintOp := macro.Stop()

		PaintBackground(gtx, style, alt, ClipRect(dimensions.Size))
		paintOp.Add(gtx.Ops)

		return dimensions
	}
}

type PanelFlair int

const (
	NoFlair    PanelFlair = 0
	OutlineAlt            = 1 << (iota - 1)
	BackgroundAlt
)

func Flair(outlineAlt, backgroundAlt bool) PanelFlair {
	flair := NoFlair
	if outlineAlt {
		flair |= OutlineAlt
	}
	if backgroundAlt {
		flair |= BackgroundAlt
	}
	return flair
}

func Panel(style *Style, flairs PanelFlair, w layout.Widget) layout.Widget {
	backgroundAlt := (flairs & BackgroundAlt) != 0
	outlineAlt := (flairs & OutlineAlt) != 0

	return func(gtx layout.Context) layout.Dimensions {
		macro := op.Record(gtx.Ops)
		dimensions := layout.UniformInset(style.PanelPadding).Layout(gtx, w)
		paintOp := macro.Stop()

		backgroundClip := ClipRect(dimensions.Size)
		PaintBackground(gtx, style, backgroundAlt, backgroundClip)
		paintOp.Add(gtx.Ops)
		PaintOutline(gtx, style, outlineAlt, backgroundClip)

		return dimensions
	}
}

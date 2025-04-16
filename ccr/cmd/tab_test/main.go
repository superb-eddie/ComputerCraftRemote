package main

import (
	"fmt"
	"log"
	"math/rand"
	"os"

	"gioui.org/app"
	"gioui.org/io/event"
	"gioui.org/layout"
	"gioui.org/op"
	"gioui.org/text"
	"gioui.org/widget"
	"gioui.org/widget/material"

	"ccr/ccr/widgets"
)

type Tab struct {
	Style  *widgets.Style
	Name   string
	Number int
}

func (t *Tab) FocusTag() event.Tag {
	return t
}

func (t *Tab) DisplayName() string {
	return t.Name
}

func (t *Tab) Layout(gtx layout.Context) layout.Dimensions {
	return layout.Flex{
		Axis: layout.Vertical,
	}.Layout(gtx,
		layout.Flexed(1.0, widgets.Label(t.Style, "This is a tab!!")),
		layout.Flexed(1.0, widgets.Label(t.Style, fmt.Sprintf("'%s' %d", t.Name, t.Number))),
	)
}

func main() {
	go func() {
		err := windowMain(new(app.Window))
		if err != nil {
			log.Fatal(err)
		}
		os.Exit(0)
	}()

	app.Main()
}

func windowMain(window *app.Window) error {
	shaper := &text.Shaper{}
	style := widgets.DefaultStyle(shaper)

	addTabBtn := widget.Clickable{}
	tabs := map[event.Tag]widgets.Tab{}

	tv := widgets.TabbedView{}

	var ops op.Ops
	for {
		switch e := window.Event().(type) {
		case app.DestroyEvent:
			return e.Err
		case app.FrameEvent:
			gtx := app.NewContext(&ops, e)

			if addTabBtn.Clicked(gtx) {
				newTab := new(Tab)
				newTab.Style = &style
				newTab.Name = "New tab!"
				newTab.Number = rand.Intn(999)
				tabs[newTab.FocusTag()] = newTab
				fmt.Printf("%v == %v", newTab.FocusTag(), tabs[newTab.FocusTag()].FocusTag())
			}

			layout.Flex{
				Axis: layout.Vertical,
			}.Layout(gtx,
				layout.Flexed(0.1, func(gtx layout.Context) layout.Dimensions {
					return material.Clickable(gtx, &addTabBtn, widgets.Label(&style, "add tab"))
				}),
				layout.Flexed(1.0, func(gtx layout.Context) layout.Dimensions {
					return tv.Layout(gtx, &style, tabs)
				}),
			)

			e.Frame(gtx.Ops)
		}
	}
}

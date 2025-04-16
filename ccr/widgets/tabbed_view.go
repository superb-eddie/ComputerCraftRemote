package widgets

import (
	"slices"

	"gioui.org/io/event"
	"gioui.org/io/key"
	"gioui.org/layout"
	"gioui.org/op"
	"gioui.org/widget"
)

type Tab interface {
	FocusTag() event.Tag
	DisplayName() string
	Layout(gtx layout.Context) layout.Dimensions
}

type tabButton struct {
	widget.Clickable
	name string
}

type TabbedView struct {
	tabButtons map[event.Tag]*tabButton
	tabOrder   []event.Tag
	list       layout.List
	selected   event.Tag
}

type TabSet map[event.Tag]Tab

func (tv *TabbedView) reconcileTabs(tabs TabSet) {
	// Reconcile our internal tab tabButtons with the tabs given
	if tv.tabButtons != nil {
		var tabsRemoved []event.Tag
		for tag := range tv.tabButtons {
			if _, ok := tabs[tag]; !ok {
				//	This tab button no longer exists
				delete(tv.tabButtons, tag)
				if tv.selected == tag {
					// The selected tab was removed
					tv.selected = nil
				}
				tabsRemoved = append(tabsRemoved, tag)
			}
		}
		tv.tabOrder = slices.DeleteFunc(tv.tabOrder, func(tag event.Tag) bool {
			return slices.Contains(tabsRemoved, tag)
		})
	} else {
		tv.tabButtons = map[event.Tag]*tabButton{}
	}

	for tag, tab := range tabs {
		if tv.selected == nil {
			// If nothing is selected, then select the first tab
			tv.selected = tag
		}
		if _, ok := tv.tabButtons[tag]; !ok {
			//	This tab doesn't have a button yet
			tv.tabButtons[tag] = &tabButton{
				name: tab.DisplayName(),
			}
			tv.tabOrder = append(tv.tabOrder, tag)
		}
	}
}

func (tv *TabbedView) Layout(gtx layout.Context, style *Style, tabs map[event.Tag]Tab) layout.Dimensions {
	tv.reconcileTabs(tabs)

	if len(tabs) == 0 {
		return layout.Dimensions{
			Size: gtx.Constraints.Min,
		}
	}
	gtx.Execute(key.FocusCmd{Tag: tv.selected})

	// Vertical layout
	return layout.Flex{Axis: layout.Vertical}.Layout(gtx,
		layout.Rigid(Panel(style, NoFlair, func(gtx layout.Context) layout.Dimensions {
			return tv.list.Layout(gtx, len(tv.tabOrder), func(gtx layout.Context, i int) layout.Dimensions {
				tag := tv.tabOrder[i]
				tabBtn := tv.tabButtons[tag]
				tab := tabs[tag]

				flair := Flair(
					tv.selected == tag,
					tabBtn.Hovered(),
				)

				// Update selected after setting flair to avoid an extra frame
				if tabBtn.Clicked(gtx) {
					tv.selected = tag
					gtx.Execute(op.InvalidateCmd{})
				}

				return tabBtn.Layout(gtx, Panel(style, flair, Label(style, tab.DisplayName())))
			})
		})),
		// Fill the color in the following area
		layout.Flexed(1, Panel(style, NoFlair, func(gtx layout.Context) layout.Dimensions {
			dims := tabs[tv.selected].Layout(gtx)
			dims.Size.X = gtx.Constraints.Max.X
			return dims
		})),
	)

}

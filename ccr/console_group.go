package ccr

import (
	"fmt"

	"gioui.org/layout"

	"ccr/ccr/remotes"
	"ccr/ccr/widgets"
)

type ConsoleGroup struct {
	tv          widgets.TabbedView
	listeningOn string
}

func NewConsoleGroupWidget(listeningOn string) *ConsoleGroup {
	return &ConsoleGroup{
		tv:          widgets.TabbedView{},
		listeningOn: listeningOn,
	}
}

func (cg *ConsoleGroup) Layout(gtx layout.Context, style *widgets.Style, rm *remotes.Manager) layout.Dimensions {
	tabs := rm.GetRemoteTabs(style)
	if len(tabs) == 0 {
		return widgets.Panel(style, widgets.NoFlair, func(gtx layout.Context) layout.Dimensions {
			return layout.Flex{
				Axis: layout.Vertical,
			}.Layout(gtx,
				layout.Rigid(widgets.Label(style, "No remotes connected.")),
				layout.Rigid(widgets.Label(style, fmt.Sprintf("Listening on '%s'", cg.listeningOn))))
		})(gtx)
	}

	return widgets.Panel(style, widgets.NoFlair, func(gtx layout.Context) layout.Dimensions {
		return cg.tv.Layout(gtx, style, tabs)
	})(gtx)
}

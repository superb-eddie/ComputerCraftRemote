package remotes

import (
	"fmt"
	"sync"

	"gioui.org/io/event"
	"gioui.org/layout"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"ccr/ccr/console"
	"ccr/ccr/widgets"
)

// TODO: I hate remote manager

type remoteTab struct {
	focusTag event.Tag
	name     string
	id       RemoteId
	rm       *Manager
	style    *widgets.Style
}

func (r *remoteTab) FocusTag() event.Tag {
	return r.focusTag
}

func (r *remoteTab) DisplayName() string {
	return r.name
}

func (r *remoteTab) Layout(gtx layout.Context) layout.Dimensions {
	var events []console.Event
	var dimensions layout.Dimensions
	r.rm.WithRemoteConsole(r.id, func(conn *console.Console) {
		if conn == nil {
			dimensions = layout.Dimensions{
				Size: gtx.Constraints.Min,
			}
			return
		}

		events = conn.Update(gtx, r.style)
		dimensions = conn.Layout(gtx, r.style)
	})
	for _, e := range events {
		r.rm.QueuePacket(r.id, e)
	}
	return dimensions
}

type RemoteId uuid.UUID

func newRemoteId() RemoteId {
	return RemoteId(uuid.New())
}

type remote struct {
	sync.Mutex
	queuedPackets []any
	conn          *websocket.Conn
	console       *console.Console
}

// Manager "owns" all the consoles, and is the intermediary between the UI and conn goroutines
type Manager struct {
	living map[RemoteId]*remote
	debug  bool
}

func NewManager(debug bool) *Manager {
	return &Manager{
		living: map[RemoteId]*remote{},
		debug:  debug,
	}
}

func (m *Manager) NewRemote(conn *websocket.Conn) RemoteId {
	fmt.Println("New remote connected")

	name := fmt.Sprintf("#%d", len(m.living))
	id := newRemoteId()
	m.living[id] = &remote{
		conn:    conn,
		console: console.NewConsole(name),
	}
	return id
}

func (m *Manager) CloseRemote(id RemoteId) {
	delete(m.living, id)
}

func (m *Manager) GetRemoteTabs(style *widgets.Style) widgets.TabSet {
	tabs := make(widgets.TabSet, len(m.living))
	for id := range m.living {
		cons := m.living[id].console
		tab := remoteTab{
			focusTag: cons.FocusTag(),
			name:     cons.Name,
			id:       id,
			rm:       m,
			style:    style,
		}
		tabs[tab.focusTag] = &tab
	}
	return tabs
}

func (m *Manager) GetRemoteIds() []RemoteId {
	ids := make([]RemoteId, 0, len(m.living))
	for id := range m.living {
		ids = append(ids, id)
	}
	return ids
}

func (m *Manager) IsAlive(id RemoteId) bool {
	_, ok := m.living[id]
	return ok
}

func (m *Manager) WithRemoteConsoleErr(id RemoteId, f func(con *console.Console) error) error {
	r, ok := m.living[id]
	if !ok {
		return f(nil)
	}

	r.Lock()
	defer r.Unlock()
	return f(r.console)
}

func (m *Manager) WithRemoteConsole(id RemoteId, f func(conn *console.Console)) {
	r, ok := m.living[id]
	if !ok {
		f(nil)
	}

	r.Lock()
	defer r.Unlock()
	f(r.console)
}

func (m *Manager) QueuePacket(to RemoteId, payload any) {
	r, ok := m.living[to]
	if !ok {
		return
	}

	r.Lock()
	defer r.Unlock()

	r.queuedPackets = append(r.queuedPackets, payload)
}

func (m *Manager) SendQueuedPackets() error {
	for _, r := range m.living {
		if err := m.sendPacketQueue(r); err != nil {
			return err
		}
	}
	return nil
}

func (m *Manager) sendPacketQueue(r *remote) error {
	if len(r.queuedPackets) == 0 {
		return nil
	}

	r.Lock()
	defer r.Unlock()

	var sent int
	var err error
	for i, p := range r.queuedPackets {
		var raw []byte
		raw, err = marshalPacket(getRemotePayloadName(p), p)
		if err != nil {
			goto errored
		}

		if m.debug {
			fmt.Println(string(raw))
		}

		err = r.conn.WriteMessage(websocket.TextMessage, raw)
		if err != nil {
			goto errored
		}

		sent = i
	}
	r.queuedPackets = r.queuedPackets[:0]
	return nil

errored:
	r.queuedPackets = r.queuedPackets[sent:]
	return err
}

package remotes

import (
	"encoding/json"
	"fmt"

	"ccr/ccr/console"
)

// TODO: Code gen here

// Communication with remotes happens in two ways
// Messages:
//  - Sent by the remote to the console
//  - A response with the updated state is always expected
// Events:
//  - Sent to the remote by the console
//  - No response is expected
//  - Triggered by some kind of user input

// packet wraps every message sent between the remote and the console
type packet struct {
	Name    string          `json:"name"`
	Payload json.RawMessage `json:"payload"`
}

func marshalPacket(name string, payload any) ([]byte, error) {
	payloadMarshalled, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	return json.Marshal(packet{
		Name:    name,
		Payload: payloadMarshalled,
	})
}

// begin: console packets
const (
	// These two messages have no payload
	clearMessageName     = "clear-message"
	clearLineMessageName = "clear-line-message"
)

const writeMessageName = "write-message"

type writeMessage struct {
	Text string `json:"text"`
}

const blitMessageName = "blit-message"

type blitMessage struct {
	Text       string `json:"text"`
	Foreground string `json:"foreground"`
	Background string `json:"background"`
}

const scrollMessageName = "scroll-message"

type scrollMessage struct {
	Y int `json:"y"`
}

const setCursorPositionMessageName = "set-cursor-position-message"

type setCursorPositionMessage struct {
	X int `json:"x"`
	Y int `json:"y"`
}

const setCursorBlinkMessageName = "set-cursor-blink-message"

type setCursorBlinkMessage struct {
	Blink bool `json:"blink"`
}

const setForegroundColorMessageName = "set-foreground-color-message"

type setForegroundColorMessage struct {
	Color console.Color `json:"color"`
}

const setBackgroundColorMessageName = "set-background-color-message"

type setBackgroundColorMessage struct {
	Color console.Color `json:"color"`
}

const setPaletteColorMessageName = "set-palette-color-message"

type setPaletteColorMessage struct {
	Color console.Color `json:"color"`
	R     float32       `json:"r"`
	G     float32       `json:"g"`
	B     float32       `json:"b"`
}

const setConsoleNameMessageName = "set-console-name-message"

type setConsoleNameMessage struct {
	Name string `json:"name"`
}

type MessageHandler interface {
	Clear()
	ClearLine()
	Write(text string)
	Blit(text, foreground, background string)
	Scroll(y int)
	SetCursorPosition(x, y int)
	SetCursorBlink(blink bool)
	SetForegroundColor(color console.Color)
	SetBackgroundColor(color console.Color)
	SetPaletteColor(color console.Color, r, g, b float32)
	SetConsoleName(name string)
}

func HandlePacket(buf []byte, handler MessageHandler) error {
	var packets []packet
	if err := json.Unmarshal(buf, &packets); err != nil {
		return fmt.Errorf("unmarshalling packet: %w", err)
	}

	for _, p := range packets {
		switch p.Name {
		case clearMessageName:
			handler.Clear()
		case clearLineMessageName:
			handler.ClearLine()
		case writeMessageName:
			var m writeMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.Write(m.Text)
		case blitMessageName:
			var m blitMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.Blit(m.Text, m.Foreground, m.Background)
		case scrollMessageName:
			var m scrollMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.Scroll(m.Y)
		case setCursorPositionMessageName:
			var m setCursorPositionMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.SetCursorPosition(m.X, m.Y)
		case setCursorBlinkMessageName:
			var m setCursorBlinkMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.SetCursorBlink(m.Blink)
		case setForegroundColorMessageName:
			var m setForegroundColorMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.SetForegroundColor(m.Color)
		case setBackgroundColorMessageName:
			var m setBackgroundColorMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.SetBackgroundColor(m.Color)
		case setPaletteColorMessageName:
			var m setPaletteColorMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.SetPaletteColor(m.Color, m.R, m.G, m.B)
		case setConsoleNameMessageName:
			var m setConsoleNameMessage
			if err := json.Unmarshal(p.Payload, &m); err != nil {
				return fmt.Errorf("unmarshalling packet payload: %w", err)
			}
			handler.SetConsoleName(m.Name)
		}
	}

	return nil
}

//end

//begin: remote packets

const ccEventBundleName = "cc-event-bundle"

type CCEventBundle struct {
	Events []console.CCEvent `json:"events"`
}

func getRemotePayloadName(payload any) string {
	switch payload.(type) {
	case CCEventBundle:
		return ccEventBundleName

	}
	panic("unknown remote payload type")
}

//end

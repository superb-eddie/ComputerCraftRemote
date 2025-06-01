package console

type ScreenBufferSize struct {
	X int `json:"x"`
	Y int `json:"y"`
}

type ScreenBufferRow struct {
	Chars string `json:"chars"`
	Fg    string `json:"fg"`
	Bg    string `json:"bg"`
}

type ScreenBuffer struct {
	Size ScreenBufferSize  `json:"size"`
	Rows []ScreenBufferRow `json:"rows"`
}

type ScreenCursor struct {
	X     int  `json:"x"`
	Y     int  `json:"y"`
	Blink bool `json:"blink"`
}

type ScreenPalette map[string][3]float32

// ScreenUpdatePacket is just the `headlessRedirect` from the lua side encoded and shipped over the wire
type ScreenUpdatePacket struct {
	Buffer ScreenBuffer `json:"buffer"`
	Cursor ScreenCursor `json:"cursor"`
	//FgColor byte          `json:"fgColor"`
	//BgColor byte          `json:"bgColor"`
	Palette ScreenPalette `json:"palette"`
}

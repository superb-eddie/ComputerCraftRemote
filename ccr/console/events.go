package console

import (
	"strings"
	"unicode/utf8"

	"gioui.org/io/key"
)

type Key int

const (
	Key_Space          Key = 32
	Key_Apostrophe         = 39
	Key_Comma              = 44
	Key_Minus              = 45
	Key_Period             = 46
	Key_Slash              = 47
	Key_Zero               = 48
	Key_One                = 49
	Key_Two                = 50
	Key_Three              = 51
	Key_Four               = 52
	Key_Five               = 53
	Key_Six                = 54
	Key_Seven              = 55
	Key_Eight              = 56
	Key_Nine               = 57
	Key_Semicolon          = 59
	Key_Equals             = 61
	Key_A                  = 65
	Key_B                  = 66
	Key_C                  = 67
	Key_D                  = 68
	Key_E                  = 69
	Key_F                  = 70
	Key_G                  = 71
	Key_H                  = 72
	Key_I                  = 73
	Key_J                  = 74
	Key_K                  = 75
	Key_L                  = 76
	Key_M                  = 77
	Key_N                  = 78
	Key_O                  = 79
	Key_P                  = 80
	Key_Q                  = 81
	Key_R                  = 82
	Key_S                  = 83
	Key_T                  = 84
	Key_U                  = 85
	Key_V                  = 86
	Key_W                  = 87
	Key_X                  = 88
	Key_Y                  = 89
	Key_Z                  = 90
	Key_LeftBracket        = 91
	Key_Backslash          = 92
	Key_RightBracket       = 93
	Key_Grave              = 96
	Key_Enter              = 257
	Key_Tab                = 258
	Key_Backspace          = 259
	Key_Insert             = 260
	Key_Delete             = 261
	Key_Right              = 262
	Key_Left               = 263
	Key_Down               = 264
	Key_Up                 = 265
	Key_PageUp             = 266
	Key_PageDown           = 267
	Key_Home               = 268
	Key_End                = 269
	Key_CapsLock           = 280
	Key_ScrollLock         = 281
	Key_NumLock            = 282
	Key_PrintScreen        = 283
	Key_Pause              = 284
	Key_F1                 = 290
	Key_F2                 = 291
	Key_F3                 = 292
	Key_F4                 = 293
	Key_F5                 = 294
	Key_F6                 = 295
	Key_F7                 = 296
	Key_F8                 = 297
	Key_F9                 = 298
	Key_F10                = 299
	Key_F11                = 300
	Key_F12                = 301
	Key_F13                = 302
	Key_F14                = 303
	Key_F15                = 304
	Key_F16                = 305
	Key_F17                = 306
	Key_F18                = 307
	Key_F19                = 308
	Key_F20                = 309
	Key_F21                = 310
	Key_F22                = 311
	Key_F23                = 312
	Key_F24                = 313
	Key_F25                = 314
	Key_NumPad0            = 320
	Key_NumPad1            = 321
	Key_NumPad2            = 322
	Key_NumPad3            = 323
	Key_NumPad4            = 324
	Key_NumPad5            = 325
	Key_NumPad6            = 326
	Key_NumPad7            = 327
	Key_NumPad8            = 328
	Key_NumPad9            = 329
	Key_NumPadDecimal      = 330
	Key_NumPadDivide       = 331
	Key_NumPadMultiply     = 332
	Key_NumPadSubtract     = 333
	Key_NumPadAdd          = 334
	Key_NumPadEnter        = 335
	Key_NumPadEqual        = 336
	Key_LeftShift          = 340
	Key_LeftCtrl           = 341
	Key_LeftAlt            = 342
	Key_LeftSuper          = 343
	Key_RightShift         = 344
	Key_RightCtrl          = 345
	Key_RightAlt           = 346
	Key_Menu               = 348
)

func translateKey(name key.Name, modifiers key.Modifiers) (Key, string, bool) {
	switch name {
	case key.NameLeftArrow:
		return Key_Left, "", true
	case key.NameRightArrow:
		return Key_Right, "", true
	case key.NameUpArrow:
		return Key_Up, "", true
	case key.NameDownArrow:
		return Key_Down, "", true
	case key.NameReturn, key.NameEnter:
		return Key_Enter, "", true
	case key.NameHome:
		return Key_Home, "", true
	case key.NameEnd:
		return Key_End, "", true
	case key.NameBack, key.NameDeleteBackward, key.NameDeleteForward:
		return Key_Backspace, "", true
	case key.NamePageUp:
		return Key_PageUp, "", true
	case key.NamePageDown:
		return Key_PageDown, "", true
	case key.NameTab:
		return Key_Tab, "", true
	case key.NameSpace:
		return Key_Space, " ", true
	case key.NameCtrl, key.NameCommand:
		return Key_LeftCtrl, "", true
	case key.NameShift:
		return Key_LeftShift, "", true
	case key.NameAlt:
		return Key_LeftAlt, "", true
	case key.NameSuper:
		return Key_LeftSuper, "", true
	case key.NameF1:
		return Key_F1, "", true
	case key.NameF2:
		return Key_F2, "", true
	case key.NameF3:
		return Key_F3, "", true
	case key.NameF4:
		return Key_F4, "", true
	case key.NameF5:
		return Key_F5, "", true
	case key.NameF6:
		return Key_F6, "", true
	case key.NameF7:
		return Key_F7, "", true
	case key.NameF8:
		return Key_F8, "", true
	case key.NameF9:
		return Key_F9, "", true
	case key.NameF10:
		return Key_F10, "", true
	case key.NameF11:
		return Key_F11, "", true
	case key.NameF12:
		return Key_F12, "", true
	case key.NameEscape:
		return 0, "", false
	}

	//	Key should be a char, guess which key was pressed (assuming a us keyboard layout)
	keyRune, _ := utf8.DecodeRuneInString(string(name))
	char := string(keyRune)
	if keyRune >= '0' && keyRune <= '9' {
		return Key(Key_Zero + (keyRune - '0')), char, true
	} else if keyRune >= 'A' && keyRune <= 'Z' {
		if !modifiers.Contain(key.ModShift) {
			char = strings.ToLower(char)
		}

		return Key(Key_A + (keyRune - 'A')), char, true
	}

	switch keyRune {
	case '\'', '"':
		return Key_Apostrophe, char, true
	case ',', '<':
		return Key_Comma, char, true
	case '-', '_':
		return Key_Minus, char, true
	case '.', '>':
		return Key_Period, char, true
	case '/', '?':
		return Key_Slash, char, true
	case ';', ':':
		return Key_Semicolon, char, true
	case '=', '+':
		return Key_Equals, char, true
	case '[', '{':
		return Key_LeftBracket, char, true
	case '\\', '|':
		return Key_Backslash, char, true
	case ']', '}':
		return Key_RightBracket, char, true
	case '`', '~':
		return Key_Grave, char, true
	case '!':
		return Key_One, char, true
	case '@':
		return Key_Two, char, true
	case '#':
		return Key_Three, char, true
	case '$':
		return Key_Four, char, true
	case '%':
		return Key_Five, char, true
	case '^':
		return Key_Six, char, true
	case '&':
		return Key_Seven, char, true
	case '*':
		return Key_Eight, char, true
	case '(':
		return Key_Nine, char, true
	case ')':
		return Key_Zero, char, true
	}

	return 0, "", false
}

type Event interface {
	_isConsoleEvent()
}

type isConsoleEvent struct{}

func (i isConsoleEvent) _isConsoleEvent() {}

type ResizedEvent struct {
	isConsoleEvent `json:"-"`
	Width          int `json:"width"`
	Height         int `json:"height"`
}

type KeyDownEvent struct {
	isConsoleEvent `json:"-"`
	Key            Key    `json:"key"`
	Held           bool   `json:"held"`
	Char           string `json:"char"`
}

type KeyUpEvent struct {
	isConsoleEvent `json:"-"`
	Key            Key `json:"key"`
}

type ClipboardEvent struct {
	isConsoleEvent `json:"-"`
	Text           string `json:"text"`
}

type TerminateEvent struct {
	isConsoleEvent `json:"-"`
}

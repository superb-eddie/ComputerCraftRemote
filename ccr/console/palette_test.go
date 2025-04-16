package console

import (
	"fmt"
	"testing"
)

func Test_colorFromHexDigit(t *testing.T) {
	type testCase struct {
		digit rune
		want  Color
	}

	var tests []testCase

	for i := 0; i < 16; i++ {
		if i <= 9 {
			tests = append(tests, testCase{
				digit: rune('0' + i),
				want:  1 << i,
			})
		} else {
			tests = append(tests, testCase{
				digit: rune('a' + (i - 10)),
				want:  1 << i,
			})
			tests = append(tests, testCase{
				digit: rune('A' + (i - 10)),
				want:  1 << i,
			})
		}
	}

	for _, tt := range tests {
		t.Run(fmt.Sprintf("hex digit %s", string(tt.digit)), func(t *testing.T) {
			if got := colorFromHexDigit(tt.digit); got != tt.want {
				t.Errorf("colorFromHexDigit() = %v, want %v", got, tt.want)
			}
		})
	}
}

func Test_colorIndex(t *testing.T) {
	type testCase struct {
		col  Color
		want uint
	}
	var tests []testCase

	for i := 0; i < 16; i++ {
		tests = append(tests, testCase{
			col:  Color(1 << i),
			want: uint(i),
		})
	}

	for _, tt := range tests {
		t.Run(fmt.Sprintf("color %d", tt.want), func(t *testing.T) {
			if got := colorIndex(tt.col); got != tt.want {
				t.Errorf("colorIndex() = %v, want %v", got, tt.want)
			}
		})
	}
}

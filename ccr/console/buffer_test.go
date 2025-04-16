package console

import (
	"fmt"
	"image"
	"strings"
	"testing"
)

func generateTestBuffer(size image.Point) []int {
	buf := make([]int, size.X*size.Y)
	for y := 0; y < size.Y; y++ {
		for x := 0; x < size.X; x++ {
			buf[index2DBuffer(size, image.Pt(x, y))] = x
		}
	}
	return buf
}

func generateWantBuffer(oldSize, newSize image.Point) []int {
	buf := make([]int, newSize.X*newSize.Y)
	for y := 0; y < newSize.Y; y++ {
		for x := 0; x < newSize.X; x++ {

			val := x
			if x >= oldSize.X || y >= oldSize.Y {
				val = -1
			}

			buf[index2DBuffer(newSize, image.Pt(x, y))] = val
		}
	}
	return buf
}

func compareBuffers(a, b []int, size image.Point) bool {
	for y := 0; y < size.Y; y++ {
		for x := 0; x < size.X; x++ {
			i := index2DBuffer(size, image.Pt(x, y))
			if a[i] != b[i] {
				return false
			}
		}
	}
	return true
}

func printBuffer(buf []int, size image.Point) {
	// Max length the label in a cell could be
	cellSize := len(fmt.Sprintf("%d", size.X))

	horizSep := strings.Repeat("+"+strings.Repeat("-", cellSize), size.X) + "+"
	for y := 0; y < size.Y; y++ {
		fmt.Println(horizSep)
		for x := 0; x < size.X; x++ {
			fmt.Print("|")
			d := buf[index2DBuffer(size, image.Pt(x, y))]

			label := fmt.Sprintf("%d", d)
			label = strings.Repeat(" ", cellSize-len(label)) + label
			fmt.Print(label)
		}
		fmt.Println("|")
	}
	fmt.Println(horizSep)
}

type resize2DBuffer_testcase struct {
	old, new image.Point
}

func generateTestCases(dec int, maxSize image.Point) []resize2DBuffer_testcase {
	var sizes []image.Point
	size := maxSize
	for size.Y > 0 {
		for size.X > 0 {
			sizes = append(sizes, size)
			size.X -= dec
		}
		size.Y -= dec
		size.X = maxSize.X
	}

	var testCases []resize2DBuffer_testcase
	for i := 0; i < len(sizes); i++ {
		for j := len(sizes) - 1; j >= 0; j-- {
			testCases = append(testCases, resize2DBuffer_testcase{
				old: sizes[i],
				new: sizes[j],
			})
		}
	}

	return testCases
}

func Test_resize2DBuffer(t *testing.T) {
	tests := []resize2DBuffer_testcase{
		{
			old: image.Pt(4, 4),
			new: image.Pt(2, 2),
		},
		{
			old: image.Pt(2, 2),
			new: image.Pt(4, 4),
		},
	}
	tests = append(generateTestCases(10, image.Pt(50, 50)), tests...)

	for _, tt := range tests {
		name := fmt.Sprintf("%dx%d_to_%dx%d", tt.old.X, tt.old.Y, tt.new.X, tt.new.Y)
		oldBuf := generateTestBuffer(tt.old)
		wantBuf := generateWantBuffer(tt.old, tt.new)

		t.Run(name, func(t *testing.T) {
			if got := resize2DBuffer(oldBuf, tt.old, tt.new, -1); !compareBuffers(got, wantBuf, tt.new) {
				fmt.Println("Wanted:")
				printBuffer(wantBuf, tt.new)
				fmt.Println("Got:")
				printBuffer(got, tt.new)

				t.Error("gotBuf != wantBuf")
			}
		})
	}
}

package main

import (
	"bytes"
	"compress/zlib"
	"context"
	_ "embed"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"sync"
	"time"

	"gioui.org/app"
	"gioui.org/op"
	"gioui.org/text"
	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"

	"github.com/superb-eddie/ComputerCraftRemote/ccr"
	"github.com/superb-eddie/ComputerCraftRemote/ccr/console"
	"github.com/superb-eddie/ComputerCraftRemote/ccr/remotes"
	"github.com/superb-eddie/ComputerCraftRemote/ccr/widgets"
)

//go:embed ccr.lua
var remoteScript []byte

var debug bool
var listen string

func init() {
	flag.BoolVar(&debug, "debug", false, "Print debug messages")
	flag.StringVar(&listen, "listen", ":338", "ip:port to listen on")
	flag.Parse()
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
	remoteManager := remotes.NewManager(debug)

	wg := sync.WaitGroup{}
	srv := runRemoteListener(&wg, window, remoteManager)
	defer func() {
		// Graceful shutdown of http server
		ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
		defer cancel()
		if err := srv.Shutdown(ctx); err != nil {
			panic(err)
		}
		wg.Wait()
	}()

	return runUI(window, remoteManager)
}

func runUI(window *app.Window, rm *remotes.Manager) error {
	shaper := &text.Shaper{}
	style := widgets.DefaultStyle(shaper)

	consoleGroup := ccr.NewConsoleGroupWidget(listen)

	var ops op.Ops
	for {
		switch e := window.Event().(type) {
		case app.DestroyEvent:
			return e.Err
		case app.FrameEvent:
			gtx := app.NewContext(&ops, e)

			consoleGroup.Layout(gtx, &style, rm)
			if err := rm.SendQueuedEvents(); err != nil {
				return err
			}

			e.Frame(gtx.Ops)
		}
	}
}

func runRemoteListener(wg *sync.WaitGroup, window *app.Window, rm *remotes.Manager) *http.Server {
	return listenForConn(wg, func(conn *websocket.Conn) error {
		remoteId := rm.NewRemote(conn)
		window.Invalidate()
		defer rm.CloseRemote(remoteId)
		defer window.Invalidate()

		var inflator io.Reader
		var screenUpdate console.ScreenUpdatePacket
		for {
			_, packet, err := conn.ReadMessage()
			if err != nil {
				return err
			}

			packetR := bytes.NewReader(packet)
			if inflator == nil {
				inflator, err = zlib.NewReader(packetR)
			} else {
				err = inflator.(zlib.Resetter).Reset(packetR, nil)
			}
			if err != nil {
				return err
			}

			packetInflated, err := io.ReadAll(inflator)
			if err != nil {
				return err
			}

			if debug {
				fmt.Println(string(packetInflated))
			}

			err = json.Unmarshal(packetInflated, &screenUpdate)
			if err != nil {
				return err
			}

			rm.WithRemoteConsole(remoteId, func(con *console.Console) {
				con.UpdateFromRemote(screenUpdate)
				defer window.Invalidate() // redraw window as soon as we release the console
			})
		}
	})
}

func listenForConn(wg *sync.WaitGroup, connMain func(conn *websocket.Conn) error) *http.Server {
	// Start http server to listen for new connections from remote

	upgrader := websocket.Upgrader{} // use default options
	r := mux.NewRouter()
	r.HandleFunc("/ccr.lua", func(w http.ResponseWriter, r *http.Request) {
		http.ServeContent(w, r, "ccr.lua", time.Now(), bytes.NewReader(remoteScript))
	})
	r.HandleFunc("/.well-known/ccremote", func(w http.ResponseWriter, r *http.Request) {
		// Upgrade to websocket
		c, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			log.Print("upgrade:", err)
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		defer c.Close()

		if err := connMain(c); err != nil {
			fmt.Printf("Conn errored: %s\n", err.Error())
			return
		}
	})

	srv := &http.Server{
		Addr:    listen,
		Handler: r,
	}

	wg.Add(1)
	go func() {
		defer wg.Done()

		fmt.Printf("Listening on '%s'\n", listen)
		if err := srv.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("ListenAndServe(): %v", err)
		}
	}()

	return srv
}

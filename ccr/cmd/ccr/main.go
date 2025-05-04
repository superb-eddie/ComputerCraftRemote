package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
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

	"ccr/ccr"
	"ccr/ccr/console"
	"ccr/ccr/remotes"
	"ccr/ccr/widgets"
)

var debug bool
var invertColors bool
var listen string

func init() {
	flag.BoolVar(&debug, "debug", false, "Print debug messages")
	flag.BoolVar(&invertColors, "invert-colors", false, "invert palette colors")
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
	remoteManager := remotes.NewManager(debug, invertColors)

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
			if err := rm.SendQueuedPackets(); err != nil {
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

		for {
			_, packet, err := conn.ReadMessage()
			if err != nil {
				return err
			}

			if debug {
				fmt.Println(string(packet))
			}

			err = rm.WithRemoteConsoleErr(remoteId, func(con *console.Console) error {
				if err = remotes.HandlePacket(packet, con); err != nil {
					return err
				}
				defer window.Invalidate() // redraw window as soon as we release the console

				return nil
			})
			if err != nil {
				return err
			}
		}
	})
}

func listenForConn(wg *sync.WaitGroup, connMain func(conn *websocket.Conn) error) *http.Server {
	// Start http server to listen for new connections from remote

	upgrader := websocket.Upgrader{} // use default options
	r := mux.NewRouter()
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

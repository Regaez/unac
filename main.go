package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"unac/assets"
	"unac/domain"
	"unac/templates"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/starfederation/datastar-go/datastar"
)

// CLI flag to store the TCP port
var flagPort int

var games = make(map[string]*domain.GameState)
var history = []string{}

func init() {
	const (
		defaultPort = 3000
		usagePort   = "Specify a TCP port for the server to listen on."
	)
	flag.IntVar(&flagPort, "port", defaultPort, usagePort)
	flag.IntVar(&flagPort, "p", defaultPort, usagePort)

	flag.Usage = func() {
		fmt.Println("OPTIONS:")
		fmt.Println("\t-p, --port")
		fmt.Printf("\t\t%s (default %d)\n", usagePort, defaultPort)
	}
}

func main() {
	r := chi.NewRouter()

	// Apply middlewares
	r.Use(middleware.Logger)
	r.Use(middleware.Compress(5, "text/html", "text/css", "application/javascript", "application/json", "application/manifest+json", "image/svg+xml"))

	dsMux := chi.NewRouter()
	r.Use(middleware.RouteHeaders().Route("Datastar-Request", "true", middleware.New(dsMux)).Handler)

	// Generate routes for embedded assets
	for _, a := range assets.EmbeddedAssets {
		r.Get(a.Route(), assets.GetHandler(a))
	}

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		g := domain.NewGameState()

		// Limit stored games to 100
		history = append(history, g.Id)
		if len(history) > 100 {
			delete(games, history[0])
			history = history[1:]
		}

		games[g.Id] = &g
		w.Header().Add("Location", fmt.Sprintf("/%s", g.Id))
		w.WriteHeader(303)
	})

	r.Get("/{gameId}", func(w http.ResponseWriter, r *http.Request) {
		gameState, gameExists := games[chi.URLParam(r, "gameId")]

		if !gameExists {
			w.WriteHeader(404)
			return
		}

		// Need to add this to trigger compression middleware
		w.Header().Add("Content-Type", "text/html")
		templates.Page(*gameState).Render(context.Background(), w)
	})

	dsMux.Get("/{gameId}", func(w http.ResponseWriter, r *http.Request) {
		gameState, gameExists := games[chi.URLParam(r, "gameId")]

		sse := datastar.NewSSE(w, r, datastar.WithCompression(datastar.WithBrotli()))

		if !gameExists {
			sse.Redirect("/")
			return
		}

		sse.PatchElementTempl(templates.Game(*gameState))

		gameState.OnChange(func() {
			sse.PatchElementTempl(templates.Game(*gameState))
		})

		for {
			select {
			case <-r.Context().Done():
				return
			}
		}
	})

	dsMux.Post("/{gameId}/{boardId}/{cellId}", func(w http.ResponseWriter, r *http.Request) {
		gameState, gameExists := games[chi.URLParam(r, "gameId")]
		boardId, bErr := strconv.Atoi(chi.URLParam(r, "boardId"))
		cellId, cErr := strconv.Atoi(chi.URLParam(r, "cellId"))

		if !gameExists || bErr != nil || cErr != nil {
			w.WriteHeader(400)
			return
		}

		gameState.ApplyTurn(domain.Turn{
			BoardId: boardId,
			CellId:  cellId,
			Player:  gameState.GetCurrentPlayer(),
		})

		w.WriteHeader(204)
	})

	dsMux.Post("/{gameId}/undo", func(w http.ResponseWriter, r *http.Request) {
		gameState, gameExists := games[chi.URLParam(r, "gameId")]

		if !gameExists {
			w.WriteHeader(400)
			return
		}

		gameState.Undo()
		w.WriteHeader(204)
	})

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", flagPort), r))
}

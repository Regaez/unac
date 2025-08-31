package main

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"unac/assets"
	"unac/domain"
	"unac/templates"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/starfederation/datastar-go/datastar"
)

var games = make(map[string]*domain.GameState)

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
		games[g.Id] = &g
		w.Header().Add("Location", fmt.Sprintf("/%s", g.Id))
		w.WriteHeader(303)
	})

	r.Get("/{gameId}", func(w http.ResponseWriter, r *http.Request) {
		gameState, gameExists := games[chi.URLParam(r, "gameId")]

		if !gameExists {
			w.WriteHeader(400)
			return
		}

		// Need to add this to trigger compression middleware
		w.Header().Add("Content-Type", "text/html")
		templates.Page(*gameState).Render(context.Background(), w)
	})

	dsMux.Get("/{gameId}", func(w http.ResponseWriter, r *http.Request) {
		gameState, gameExists := games[chi.URLParam(r, "gameId")]

		if !gameExists {
			w.WriteHeader(400)
			return
		}

		sse := datastar.NewSSE(w, r, datastar.WithCompression(datastar.WithBrotli()))

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

	dsMux.Post("/{gameId}/reset", func(w http.ResponseWriter, r *http.Request) {
		gameState, gameExists := games[chi.URLParam(r, "gameId")]

		if !gameExists {
			w.WriteHeader(400)
			return
		}

		gameState.Reset()
		w.WriteHeader(204)
	})

	http.ListenAndServe(":3000", r)
}

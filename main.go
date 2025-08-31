package main

import (
	"context"
	"net/http"
	"strconv"
	"unac/assets"
	"unac/domain"
	"unac/templates"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)


func main() {
	gameState := domain.NewGameState()

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
		templates.Page(gameState).Render(context.Background(), w)
	})

	dsMux.Post("/select/{boardId}/{cellId}", func(w http.ResponseWriter, r *http.Request) {
		boardId, bErr := strconv.Atoi(chi.URLParam(r, "boardId"))
		cellId, cErr := strconv.Atoi(chi.URLParam(r, "cellId"))

		if bErr != nil || cErr != nil {
		 	w.WriteHeader(400)
			return
		}
		
		gameState.ApplyTurn(domain.Turn {
			BoardId: boardId,
			CellId: cellId,
			Player: gameState.GetCurrentPlayer(),
		})

		gameState.ApplyWinConditions()
		
		templates.Game(gameState).Render(context.Background(), w)
	})

	dsMux.Post("/reset", func(w http.ResponseWriter, r *http.Request) {
		gameState = domain.NewGameState()
		templates.Game(gameState).Render(context.Background(), w)
	})

	http.ListenAndServe(":3000", r)
}

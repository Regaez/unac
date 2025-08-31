package domain

import (
	"log"

	nanoid "github.com/matoous/go-nanoid/v2"
)

var WIN_CONDITIONS = [][]int{
	{0, 1, 2},
	{3, 4, 5},
	{6, 7, 8},
	{0, 3, 6},
	{1, 4, 7},
	{2, 5, 8},
	{0, 4, 8},
	{2, 4, 6},
}

type WinState string

func (s WinState) String() string {
	return string(s)
}

func ParseWinstate(input string) WinState {
	return WinState("")
}

const PLAYER_X = Player("X")
const PLAYER_O = Player("O")

type Player string

func (p Player) String() string {
	return string(p)
}

func (p Player) AsWinState() WinState {
	return WinState(p)
}

type Cell struct {
	Id    int
	State WinState
}

func (c *Cell) IsAvailable() bool {
	return c.State == ""
}

type Board struct {
	Id    int
	Cells []*Cell
	State WinState
}

func (b *Board) IsAvailable() bool {
	log.Printf("board state: %s", b.State)
	return b.State == ""
}

type Turn struct {
	BoardId int
	CellId  int
	Player  Player
}

type GameState struct {
	Id       string
	Boards   []*Board
	Turns    []Turn
	WinState WinState
}

func (g *GameState) IsOngoing() bool {
	return g.WinState == ""
}

func (g *GameState) IsSelectable(b *Board, c *Cell) bool {
	if len(g.Turns) < 1 {
		return true
	}

	if !g.IsOngoing() {
		return false
	}

	if !g.Boards[b.Id].IsAvailable() {
		return false
	}

	if !g.Boards[b.Id].Cells[c.Id].IsAvailable() {
		return false
	}

	nextBoardId := g.Turns[len(g.Turns)-1].CellId

	if !g.Boards[nextBoardId].IsAvailable() {
		return true
	}

	return nextBoardId == b.Id
}

func NewBoard(boardId int) *Board {
	cells := make([]*Cell, 9)

	for cellId := range cells {
		cells[cellId] = &Cell{
			Id:    cellId,
			State: "",
		}
	}

	return &Board{
		Id:    boardId,
		Cells: cells,
		State: "",
	}
}

func NewGameState() GameState {
	boards := make([]*Board, 9)

	for i := range boards {
		boards[i] = NewBoard(i)
	}

	return GameState{
		Id:       nanoid.Must(8),
		Boards:   boards,
		Turns:    []Turn{},
		WinState: "",
	}
}

func (g *GameState) ApplyTurn(t Turn) {
	g.Boards[t.BoardId].Cells[t.CellId].State = t.Player.AsWinState()
	g.Turns = append(g.Turns, t)
}

func (b *Board) ApplyWinConditions() {
	if !b.IsAvailable() {
		return
	}

	for _, ids := range WIN_CONDITIONS {
		if b.Cells[ids[0]].IsAvailable() ||
			b.Cells[ids[1]].IsAvailable() ||
			b.Cells[ids[2]].IsAvailable() {
			continue
		}

		log.Printf("Checking board %d", b.Id)

		if b.Cells[ids[0]].State == b.Cells[ids[1]].State &&
			b.Cells[ids[0]].State == b.Cells[ids[2]].State {
			log.Printf("Board %d has been won", b.Id)
			b.State = b.Cells[ids[0]].State
		}
	}
}

func (g *GameState) ApplyWinConditions() {
	count := 0

	for _, b := range g.Boards {
		b.ApplyWinConditions()

		if !b.IsAvailable() {
			count = count + 1
		}
	}

	if count > 2 {
		for _, ids := range WIN_CONDITIONS {
			if g.Boards[ids[0]].IsAvailable() ||
				g.Boards[ids[1]].IsAvailable() ||
				g.Boards[ids[2]].IsAvailable() {
				continue
			}

			if g.Boards[ids[0]].State == g.Boards[ids[1]].State &&
				g.Boards[ids[0]].State == g.Boards[ids[2]].State {
				g.WinState = g.Boards[ids[0]].State
			}
		}
	}

	if count == 9 && g.IsOngoing() {
		g.WinState = WinState("draw")
	}
}

func (g *GameState) GetCurrentPlayer() Player {
	if len(g.Turns) == 0 {
		return PLAYER_X
	}

	if g.Turns[len(g.Turns)-1].Player == PLAYER_X {
		return PLAYER_O
	}

	return PLAYER_X
}

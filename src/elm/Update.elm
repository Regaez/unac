module Update exposing (..)

import Messages exposing (Msg(..))
import Model exposing (..)
import Array exposing (Array, fromList, set, get)


type alias WinCondition =
    ( Int, Int, Int )


winConditions : List WinCondition
winConditions =
    [ ( 0, 1, 2 ), ( 3, 4, 5 ), ( 6, 7, 8 ), ( 0, 3, 6 ), ( 1, 4, 7 ), ( 2, 5, 8 ), ( 0, 4, 8 ), ( 2, 4, 6 ) ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        CheckGrid ->
            model

        SelectTile tileIndex boardIndex player ->
            { model
                | boards = updateBoards model.boards boardIndex tileIndex player
                , activePlayer = nextPlayer model.activePlayer
                , winner = checkBoard model tileIndex player
                , turnCount = model.turnCount + 1
            }


updateBoards : Array Board -> Int -> Int -> Player -> Array Board
updateBoards boards boardIndex tileIndex player =
    case get boardIndex boards of
        Just board ->
            set boardIndex (updateBoard board tileIndex player) boards

        Nothing ->
            boards


updateBoard : Board -> Int -> Player -> Board
updateBoard board tileIndex player =
    { board
        | grid = set tileIndex (Just player) board.grid
    }


nextPlayer : Player -> Player
nextPlayer player =
    case player of
        PlayerOne ->
            PlayerTwo

        PlayerTwo ->
            PlayerOne


checkBoard : Model -> Int -> Player -> Maybe Player
checkBoard model index player =
    if List.length (List.filter (winConditionsMet model player) (List.filter (isATargetCondition index) winConditions)) > 0 then
        Just player
    else
        Nothing


winConditionsMet : Model -> Player -> ( Int, Int, Int ) -> Bool
winConditionsMet model player condition =
    let
        ( x, y, z ) =
            condition

        tiles =
            [ x, y, z ]
    in
        List.length (List.filter (checkTile model player) tiles) == 2


isATargetCondition : Int -> ( Int, Int, Int ) -> Bool
isATargetCondition i condition =
    let
        ( x, y, z ) =
            condition
    in
        x == i || y == i || z == i


checkTile : Board -> Player -> Int -> Bool
checkTile board player index =
    case get index board.grid of
        Just owner ->
            owner == player

        Nothing ->
            False

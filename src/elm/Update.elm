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

        SelectTile tIndex bIndex player ->
            { model
                | boards = updateBoards model.boards bIndex tIndex player
                , activePlayer = nextPlayer model.activePlayer
                , turnCount = model.turnCount + 1
            }


updateBoards : Array Board -> Int -> Int -> Player -> Array Board
updateBoards boards bIndex tIndex player =
    case get bIndex boards of
        Just board ->
            set bIndex (updateBoard board tIndex player) boards

        Nothing ->
            boards


updateBoard : Board -> Int -> Player -> Board
updateBoard board tIndex player =
    { board
        | state = checkBoard board tIndex player
        , grid = set tIndex (Just player) board.grid
    }


nextPlayer : Player -> Player
nextPlayer player =
    case player of
        PlayerOne ->
            PlayerTwo

        PlayerTwo ->
            PlayerOne


checkBoard : Board -> Int -> Player -> BoardState
checkBoard board index player =
    if List.length (List.filter (winConditionsMet board player) (List.filter (isATargetCondition index) winConditions)) > 0 then
        Won player
    else
        board.state


winConditionsMet : Board -> Player -> ( Int, Int, Int ) -> Bool
winConditionsMet board player condition =
    let
        ( x, y, z ) =
            condition

        tiles =
            [ x, y, z ]
    in
        List.length (List.filter (checkTile board player) tiles) == 2


isATargetCondition : Int -> ( Int, Int, Int ) -> Bool
isATargetCondition i condition =
    let
        ( x, y, z ) =
            condition
    in
        x == i || y == i || z == i


checkTile : Board -> Player -> Int -> Bool
checkTile board player index =
    let
        arrayItem =
            get index board.grid
    in
        -- array get might return nothing
        case arrayItem of
            Just arrayItem ->
                -- board grid value might be nothing too
                case arrayItem of
                    Just owner ->
                        owner == player

                    Nothing ->
                        False

            Nothing ->
                False

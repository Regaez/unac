module Update exposing (..)

import Messages exposing (Msg(..))
import Model exposing (..)
import Array exposing (Array, fromList, set, get, indexedMap)


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

        SelectTile bIndex tIndex player ->
            { model
                | boards = updateBoards model.boards bIndex tIndex player
                , activePlayer = nextPlayer model.activePlayer
                , winner = checkWinner model.boards bIndex model.activePlayer
            }


updateBoards : Array Board -> Int -> Int -> Player -> Array Board
updateBoards boards bIndex tIndex player =
    updateBoardsOwner boards bIndex tIndex player
        |> updateBoardsState tIndex


updateBoardsState : Int -> Array Board -> Array Board
updateBoardsState tIndex boards =
    if (isBoardWon tIndex boards) then
        setAllBoardsActive boards
    else
        indexedMap
            (\x board ->
                if x == tIndex then
                    setBoardActiveState board
                else
                    setBoardInactiveState board
            )
            boards


isBoardWon : Int -> Array Board -> Bool
isBoardWon index boards =
    case get index boards of
        Just board ->
            board.state /= Active && board.state /= Inactive

        Nothing ->
            False


setAllBoardsActive : Array Board -> Array Board
setAllBoardsActive boards =
    indexedMap
        (\x board ->
            if board.state == Active || board.state == Inactive then
                setBoardActiveState board
            else
                board
        )
        boards


setBoardActiveState : Board -> Board
setBoardActiveState board =
    case board.state of
        Won a ->
            board

        _ ->
            { board
                | state = Active
            }


setBoardInactiveState : Board -> Board
setBoardInactiveState board =
    case board.state of
        Won a ->
            board

        _ ->
            { board
                | state = Inactive
            }


updateBoardsOwner : Array Board -> Int -> Int -> Player -> Array Board
updateBoardsOwner boards bIndex tIndex player =
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


checkWinner : Array Board -> Int -> Player -> Maybe Player
checkWinner boards index player =
    let
        isWinner =
            List.length (List.filter (gameWinConditionMet boards player) (List.filter (isATargetCondition index) winConditions)) > 0
    in
        case isWinner of
            True ->
                Just player

            False ->
                Nothing


checkBoard : Board -> Int -> Player -> BoardState
checkBoard board index player =
    if List.length (List.filter (winConditionsMet board player) (List.filter (isATargetCondition index) winConditions)) > 0 then
        Won player
    else
        board.state


gameWinConditionMet : Array Board -> Player -> ( Int, Int, Int ) -> Bool
gameWinConditionMet boards player condition =
    let
        ( x, y, z ) =
            condition

        boardsWon =
            [ x, y, z ]
    in
        List.length (List.filter (checkAllBoards boards player) boardsWon) == 2


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


checkAllBoards : Array Board -> Player -> Int -> Bool
checkAllBoards boards player index =
    let
        board =
            get index boards
    in
        -- array get might return nothing
        case board of
            Just board ->
                -- board grid value might be nothing too
                case board.state of
                    Active ->
                        False

                    Inactive ->
                        False

                    Won winner ->
                        if winner == player then
                            True
                        else
                            False

            Nothing ->
                False


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

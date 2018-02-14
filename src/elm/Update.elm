module Update exposing (..)

import Messages exposing (Msg(..))
import Model exposing (..)
import Array exposing (Array, fromList, set, get, indexedMap)
import Color exposing (Color)


type alias WinCondition =
    ( Int, Int, Int )


winConditions : List WinCondition
winConditions =
    [ ( 0, 1, 2 ), ( 3, 4, 5 ), ( 6, 7, 8 ), ( 0, 3, 6 ), ( 1, 4, 7 ), ( 2, 5, 8 ), ( 0, 4, 8 ), ( 2, 4, 6 ) ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        Reset ->
            defaults

        StartGame ->
            { model | state = Game }

        Configure ->
            { model | state = MenuSettings }

        PickColour player colour ->
            handlePlayerColourSelect model player colour

        SelectTile bIndex tIndex player ->
            handleSelection model bIndex tIndex player
                |> handleGameWin bIndex
                |> handleNextPlayer


handleSelection : Model -> Int -> Int -> Player -> Model
handleSelection model bIndex tIndex player =
    { model | boards = updateBoards model.boards bIndex tIndex player }


handleNextPlayer : Model -> Model
handleNextPlayer model =
    { model | activePlayer = nextPlayer model.activePlayer }


handleGameWin : Int -> Model -> Model
handleGameWin bIndex model =
    { model | winner = findWinner model.boards bIndex }


handlePlayerColourSelect : Model -> Player -> Color -> Model
handlePlayerColourSelect model player colour =
    case player of
        PlayerOne ->
            { model | playerOne = { name = model.playerOne.name, color = colour } }

        PlayerTwo ->
            { model | playerTwo = { name = model.playerTwo.name, color = colour } }


findWinner : Array Board -> Int -> Maybe Player
findWinner boards index =
    case get index boards of
        Just board ->
            case board.state of
                Won player ->
                    checkGameWinner boards index player

                _ ->
                    Nothing

        Nothing ->
            Nothing


updateBoards : Array Board -> Int -> Int -> Player -> Array Board
updateBoards boards bIndex tIndex player =
    updateBoard boards bIndex tIndex player
        |> updateBoardsState tIndex


updateBoardsState : Int -> Array Board -> Array Board
updateBoardsState tIndex boards =
    -- if the board the next player is being sent to is already won
    -- then we allow the next player to play on any existing "unwon" board
    if (isBoardWon tIndex boards) then
        setAllBoardsActive boards
    else
        -- otherwise, we set all boards to be inactive,
        -- except for the board that matches the tile index
        indexedMap
            (\x board ->
                if x == tIndex then
                    setBoardState board Active
                else
                    setBoardState board Inactive
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
    -- sets all boards that are NOT won, to be active
    indexedMap
        (\x board ->
            if board.state == Active || board.state == Inactive then
                setBoardState board Active
            else
                board
        )
        boards


setBoardState : Board -> BoardState -> Board
setBoardState board newState =
    case board.state of
        Won a ->
            board

        _ ->
            { board
                | state = newState
            }


updateBoard : Array Board -> Int -> Int -> Player -> Array Board
updateBoard boards bIndex tIndex player =
    case get bIndex boards of
        Just board ->
            set bIndex (updateSingleBoard board tIndex player) boards

        Nothing ->
            boards


updateSingleBoard : Board -> Int -> Player -> Board
updateSingleBoard board tIndex player =
    { board
        | state =
            checkBoardWinner board tIndex player
            -- this marks the selected tile in the grid as "owned" by the player
        , grid = set tIndex (Just player) board.grid
    }


nextPlayer : Player -> Player
nextPlayer player =
    case player of
        PlayerOne ->
            PlayerTwo

        PlayerTwo ->
            PlayerOne


checkGameWinner : Array Board -> Int -> Player -> Maybe Player
checkGameWinner boards index player =
    let
        -- we filter out the winConditions to check only conditions which contain the index of the board just selected
        -- then we check each item in that list to see if the player has gotten all 3 boards of each win condition
        isWinner =
            List.length (List.filter (gameWinConditionMet boards player) (List.filter (isATargetCondition index) winConditions)) > 0
    in
        case isWinner of
            True ->
                Just player

            False ->
                Nothing


checkBoardWinner : Board -> Int -> Player -> BoardState
checkBoardWinner board index player =
    -- similar to checkGameWinner, we see if any of the win conditions match for set of tiles on the selected board
    -- setting the board state to be "won" by the player if so
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
        -- if the three boards match, then the player has won
        List.length (List.filter (checkBoardForWinner boards player) boardsWon) == 3


winConditionsMet : Board -> Player -> ( Int, Int, Int ) -> Bool
winConditionsMet board player condition =
    let
        ( x, y, z ) =
            condition

        tiles =
            [ x, y, z ]
    in
        -- if the list is length 2, that means the tile we are about to select will
        -- be the third condition and therefore the player will "win" this board
        List.length (List.filter (checkTileForOwner board player) tiles) == 2


isATargetCondition : Int -> ( Int, Int, Int ) -> Bool
isATargetCondition i condition =
    let
        ( x, y, z ) =
            condition
    in
        x == i || y == i || z == i


checkBoardForWinner : Array Board -> Player -> Int -> Bool
checkBoardForWinner boards player index =
    let
        board =
            get index boards
    in
        -- array get might return nothing, ie no player has won
        case board of
            Just board ->
                case board.state of
                    Won winner ->
                        -- confirm that the winner was this player
                        if winner == player then
                            True
                        else
                            False

                    _ ->
                        False

            Nothing ->
                False


checkTileForOwner : Board -> Player -> Int -> Bool
checkTileForOwner board player index =
    let
        arrayItem =
            get index board.grid
    in
        -- array get might return nothing
        case arrayItem of
            Just arrayItem ->
                -- board grid value might be nothing too
                case arrayItem of
                    -- check the tile owner is this player
                    Just owner ->
                        owner == player

                    Nothing ->
                        False

            Nothing ->
                False

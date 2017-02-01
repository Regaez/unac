module Update exposing (..)

import Messages exposing (Msg(..))
import Model exposing (..)
import Array exposing (fromList, set, toList)


update : Msg -> Model -> Model
update msg model =
    case msg of
        CheckGrid ->
            model

        SelectTile i player ->
            let
                theBoard =
                    fromList model.board
            in
                { model
                    | board = toList (set i ( i, Just player ) theBoard)
                    , turn = nextPlayer player
                }


nextPlayer : Player -> PlayerIdentifier
nextPlayer player =
    case player.id of
        PlayerOne ->
            PlayerTwo

        PlayerTwo ->
            PlayerOne

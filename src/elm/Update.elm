module Update exposing (..)

import Messages exposing (Msg(..))
import Model exposing (..)
import Array exposing (fromList, set, toList)
import Tuple exposing (second)
import Helpers exposing (..)


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
                    , winner = checkBoard model i player
                    , turnCount = model.turnCount + 1
                }


nextPlayer : Player -> PlayerIdentifier
nextPlayer player =
    case player.id of
        PlayerOne ->
            PlayerTwo

        PlayerTwo ->
            PlayerOne


checkBoard : Model -> Int -> Player -> Maybe Player
checkBoard model index player =
    if List.length (List.filter (winConditionsMet model index player) (List.filter (isATargetCondition index) model.conditions)) > 0 then
        Just player
    else
        Nothing


winConditionsMet : Model -> Int -> Player -> ( Int, Int, Int ) -> Bool
winConditionsMet model i player condition =
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


checkTile : Model -> Player -> Int -> Bool
checkTile model player index =
    case get index model.board of
        Just a ->
            let
                owner =
                    second a
            in
                case owner of
                    Just owner ->
                        owner.id == player.id

                    Nothing ->
                        False

        Nothing ->
            False

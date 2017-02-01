module View exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model exposing (..)
import Messages exposing (Msg(..))
import List exposing (map)
import Tuple exposing (first, second)
import Color.Convert exposing (colorToCssRgba)


view : Model -> Html Msg
view model =
    div [ class "board" ] (map (renderTile model) model.board)


renderTile : Model -> ( Int, Maybe Player ) -> Html Msg
renderTile model item =
    let
        index =
            first item

        tile =
            second item
    in
        case tile of
            Just tile ->
                div [ class "board__tile", style [ ( "backgroundColor", colorToCssRgba tile.color ) ] ] []

            Nothing ->
                div [ class "board__tile", onClick (SelectTile index (activePlayer model model.turn)) ] []


activePlayer : Model -> PlayerIdentifier -> Player
activePlayer model turn =
    case turn of
        PlayerOne ->
            model.playerOne

        PlayerTwo ->
            model.playerTwo

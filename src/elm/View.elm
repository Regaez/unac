module View exposing (..)

import Html exposing (Html, h1, div, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model exposing (..)
import Messages exposing (Msg(..))
import List exposing (map)
import Tuple exposing (first, second)
import Color.Convert exposing (colorToCssRgba)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ renderWinMessage model
        , div [ class "board" ]
            [ div [ class "board__grid" ] (map (renderTile model) model.board)
            ]
        ]


renderWinMessage : Model -> Html Msg
renderWinMessage model =
    case model.winner of
        Just winner ->
            h1 [ class "message", style [ ( "color", colorToCssRgba winner.color ) ] ] [ text (winner.name ++ " has won!") ]

        Nothing ->
            h1 [ class "message" ] [ text (isDraw model.turnCount) ]


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


isDraw : Int -> String
isDraw turns =
    if turns == 9 then
        "It is a draw!"
    else
        ""

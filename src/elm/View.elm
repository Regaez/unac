module View exposing (..)

import Html exposing (Html, h1, div, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model exposing (..)
import Messages exposing (Msg(..))
import Array exposing (indexedMap, toList)
import Tuple exposing (first, second)
import Color.Convert exposing (colorToCssRgba)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ renderWinMessage model
        , renderBoards model
        ]


renderBoards : Model -> Html Msg
renderBoards model =
    div [ class "board" ]
        (toList
            (indexedMap
                (\x board ->
                    renderBoard model board x
                )
                model.boards
            )
        )


renderBoard : Model -> Board -> Int -> Html Msg
renderBoard model board bIndex =
    div [ class ("board__grid grid--" ++ toString bIndex) ]
        (toList
            (indexedMap
                (\y owner ->
                    renderTile model owner bIndex y
                )
                board.grid
            )
        )


renderWinMessage : Model -> Html Msg
renderWinMessage model =
    case model.winner of
        Just winner ->
            h1 [ class "message", style [ ( "color", colorToCssRgba (getPlayer model winner).color ) ] ] [ text ((getPlayer model winner).name ++ " has won!") ]

        Nothing ->
            h1 [ class "message" ] [ text (isDraw model.turnCount) ]


renderTile : Model -> Maybe Player -> Int -> Int -> Html Msg
renderTile model owner boardIndex tileIndex =
    case owner of
        Just owner ->
            div [ class "board__tile", style [ ( "backgroundColor", colorToCssRgba (getPlayer model owner).color ) ] ] []

        Nothing ->
            div [ class "board__tile", onClick (SelectTile boardIndex tileIndex model.activePlayer) ] []


getPlayer : Model -> Player -> PlayerConfig
getPlayer model player =
    case player of
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

module View exposing (..)

import Html exposing (Html, h1, div, text, button)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model exposing (..)
import Messages exposing (Msg(..))
import Array exposing (indexedMap, toList)
import Tuple exposing (first, second)
import Color.Convert exposing (colorToCssRgba)


view : Model -> Html Msg
view model =
    case model.winner of
        Just winner ->
            div [ class "container" ]
                [ renderWinMessage model
                , renderReset
                ]

        Nothing ->
            div [ class "container" ]
                [ renderTurnPrompt (getPlayer model model.activePlayer)
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
    div [ class ("board__grid grid--" ++ (getBoardState board.state)) ]
        (toList
            (indexedMap
                (\y owner ->
                    renderTile model board.state owner bIndex y
                )
                board.grid
            )
        )


renderTile : Model -> BoardState -> Maybe Player -> Int -> Int -> Html Msg
renderTile model boardState owner bIndex tIndex =
    case boardState of
        --Won player ->
        --    selectedTile model player
        Active ->
            case owner of
                Just owner ->
                    selectedTile model owner

                Nothing ->
                    clickableTile model bIndex tIndex

        --Inactive ->
        _ ->
            case owner of
                Just owner ->
                    selectedTile model owner

                Nothing ->
                    inactiveTile


clickableTile : Model -> Int -> Int -> Html Msg
clickableTile model bIndex tIndex =
    div [ class "board__tile tile--active", onClick (SelectTile bIndex tIndex model.activePlayer) ] []


selectedTile : Model -> Player -> Html Msg
selectedTile model player =
    div [ class "board__tile", style [ ( "backgroundColor", colorToCssRgba (getPlayer model player).color ) ] ] []


inactiveTile : Html Msg
inactiveTile =
    div [ class "board__tile tile--inactive" ] []


getPlayer : Model -> Player -> PlayerConfig
getPlayer model player =
    case player of
        PlayerOne ->
            model.playerOne

        PlayerTwo ->
            model.playerTwo


renderWinMessage : Model -> Html Msg
renderWinMessage model =
    case model.winner of
        Just winner ->
            h1 [ class "message", style [ ( "color", colorToCssRgba (getPlayer model winner).color ) ] ] [ text ((getPlayer model winner).name ++ " has won!") ]

        Nothing ->
            h1 [ class "message" ] []


renderTurnPrompt : PlayerConfig -> Html Msg
renderTurnPrompt player =
    h1 [ class "message", style [ ( "color", colorToCssRgba player.color ) ] ] [ text (player.name ++ "'s turn:") ]


renderReset : Html Msg
renderReset =
    button [ class "reset", onClick Reset ] [ text "Play again" ]


getBoardState : BoardState -> String
getBoardState state =
    case state of
        Active ->
            "active"

        Inactive ->
            "inactive"

        Won x ->
            "won"

module View exposing (..)

import Html exposing (Html, h1, h2, div, text, button, ul, li, p, input)
import Html.Attributes exposing (class, style, value)
import Html.Events exposing (onClick)
import Model exposing (..)
import Messages exposing (Msg(..))
import Array exposing (indexedMap, toList)
import Tuple exposing (first, second)
import Color exposing (Color)
import Color.Convert exposing (colorToCssRgba)


view : Model -> Html Msg
view model =
    case model.state of
        Game ->
            viewGame model

        MenuStart ->
            renderMenuStart

        MenuSettings ->
            renderMenuSettings model.playerOne model.playerTwo

        _ ->
            div [] []


viewGame : Model -> Html Msg
viewGame model =
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
                , renderConfigButton
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
    button [ class "button", onClick Reset ] [ text "Play again" ]


getBoardState : BoardState -> String
getBoardState state =
    case state of
        Active ->
            "active"

        Inactive ->
            "inactive"

        Won x ->
            "won"


renderConfigButton : Html Msg
renderConfigButton =
    button [ class "button", onClick Configure ] [ text "Configure players" ]


renderMenuStart : Html Msg
renderMenuStart =
    div [ class "container" ]
        [ h1 [ class "message" ] [ text "Ultimate Noughts and Crosses" ]
        , h2 [] [ text "Instructions" ]
        , p [] [ text "Normal rules for Noughts and Crosses (Tic Tac Toe) apply, with some extras:" ]
        , ul []
            [ li [] [ text "First player to win 3 game boards in a row, wins overall. An individual game is won by a player owning 3 tiles in a row." ]
            , li [] [ text "The tile you select determines which game board is played on by the next player. For example, selecting the top left tile on any game board will force the next player to play in the top left game." ]
            , li [] [ text "If a player should play on a game board which is already won, or has no tiles available, then they will have the choice to play on any remaining game board instead." ]
            ]
        , button [ class "button", onClick StartGame ] [ text "Start game" ]
        ]


renderMenuSettings : PlayerConfig -> PlayerConfig -> Html Msg
renderMenuSettings p1 p2 =
    div [ class "container" ]
        [ h1 [ class "message" ] [ text "Configure Players" ]
        , renderPlayerConfig PlayerOne p1 p2
        , renderPlayerConfig PlayerTwo p2 p1
        , button [ class "button", onClick StartGame ] [ text "Back to game" ]
        ]


renderPlayerConfig : Player -> PlayerConfig -> PlayerConfig -> Html Msg
renderPlayerConfig p player otherPlayer =
    div []
        [ input [ value player.name ] []
        , div [ class "colour__list" ] (renderColourList p player.color otherPlayer.color)
        ]


colours : List Color
colours =
    [ Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.brown ]


renderColourList : Player -> Color -> Color -> List (Html Msg)
renderColourList p player other =
    List.map (renderColourTile p player) (List.filter (otherPlayerColour other) colours)


renderColourTile : Player -> Color -> Color -> Html Msg
renderColourTile p player colour =
    div
        [ class "colour__option"
        , style [ ( "backgroundColor", colorToCssRgba colour ) ]
        , onClick (PickColour p colour)
        ]
        []


otherPlayerColour : Color -> Color -> Bool
otherPlayerColour otherPlayer colour =
    otherPlayer /= colour

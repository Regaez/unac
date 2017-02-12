module App exposing (..)

import Html exposing (beginnerProgram)
import Model exposing (..)
import Update exposing (update)
import View exposing (view)
import Color


main =
    Html.beginnerProgram { model = model, view = view, update = update }


model : Model
model =
    { turn = PlayerOne
    , turnCount = 0
    , board = [ ( 0, Nothing ), ( 1, Nothing ), ( 2, Nothing ), ( 3, Nothing ), ( 4, Nothing ), ( 5, Nothing ), ( 6, Nothing ), ( 7, Nothing ), ( 8, Nothing ) ]
    , conditions = winConditions
    , playerOne = p1
    , playerTwo = p2
    , winner = Nothing
    }


winConditions : List WinCondition
winConditions =
    [ ( 0, 1, 2 ), ( 3, 4, 5 ), ( 6, 7, 8 ), ( 0, 3, 6 ), ( 1, 4, 7 ), ( 2, 5, 8 ), ( 0, 4, 8 ), ( 2, 4, 6 ) ]


p1 : Player
p1 =
    { id = PlayerOne
    , name = "Red"
    , color = Color.red
    }


p2 : Player
p2 =
    { id = PlayerTwo
    , name = "Blue"
    , color = Color.blue
    }

module App exposing (..)

import Html exposing (beginnerProgram)
import Model exposing (..)
import Update exposing (update)
import View exposing (view)
import Array
import Color


main =
    Html.beginnerProgram { model = model, view = view, update = update }


model : Model
model =
    { turnCount = 0
    , boards = Array.fromList <| List.repeat 9 initialBoard
    , activePlayer = PlayerOne
    , playerOne = p1
    , playerTwo = p2
    , winner = Nothing
    }


p1 : PlayerConfig
p1 =
    { name = "Red"
    , color = Color.red
    }


p2 : PlayerConfig
p2 =
    { name = "Blue"
    , color = Color.blue
    }


initialBoard : Board
initialBoard =
    { state = Active
    , grid = Array.fromList <| List.repeat 9 Nothing
    }

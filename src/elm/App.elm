module App exposing (..)

import Html exposing (beginnerProgram)
import Model exposing (..)
import Update exposing (update)
import View exposing (view)
import Messages exposing (Msg)


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }


model : Model
model =
    defaults

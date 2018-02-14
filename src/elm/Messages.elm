module Messages exposing (..)

import Model exposing (Player)
import Color exposing (Color)


type Msg
    = Reset
    | StartGame
    | Configure
    | PickColour Player Color
    | SelectTile Int Int Player

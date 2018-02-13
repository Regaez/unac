module Messages exposing (..)

import Model exposing (Player)


type Msg
    = Reset
    | Start
    | SelectTile Int Int Player

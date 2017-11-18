module Messages exposing (..)

import Model exposing (Player)


type Msg
    = Reset
    | SelectTile Int Int Player

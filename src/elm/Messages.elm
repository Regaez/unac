module Messages exposing (..)

import Model exposing (Player)


type Msg
    = CheckGrid
    | SelectTile Int Int Player

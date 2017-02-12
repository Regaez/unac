module Helpers exposing (..)


get : Int -> List a -> Maybe a
get n xs =
    List.head (List.drop n xs)

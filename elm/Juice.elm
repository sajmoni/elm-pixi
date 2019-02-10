-- export const sine = ({
--   start, end, duration,
-- }) => (t) => {
--   return
-- };


module Juice exposing (sine)


sine : { start : Float, end : Float, duration : Int } -> Int -> Float
sine { start, end, duration } time =
    let
        middle =
            (start + end) / 2
    in
    middle + ((middle - start) * sin ((toFloat time * pi * 2) / toFloat duration))

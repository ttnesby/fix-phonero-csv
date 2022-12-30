module Csv exposing (..)


mapValue : Int -> String -> String
mapValue colNo value =
    if List.member colNo [ 0, 1 ] then
        "0"

    else if List.member colNo [ 4, 5, 6 ] then
        "0.00"

    else if colNo == 16 then
        "\"\""

    else
        value


mapLine : String -> Result String (List String)
mapLine str =
    str
        |> String.split ";"
        |> (\cols ->
                case List.length cols of
                    17 ->
                        cols
                            |> List.indexedMap mapValue
                            |> Ok

                    x ->
                        [ String.fromInt <| x, " columns, expected 17" ]
                            |> String.concat
                            |> Err
           )

gatherResults : List (Result String (List String)) -> Result String (List (List String))
gatherResults mappedLines =
    mappedLines
        |> List.filterMap Result.toMaybe
        |> (\lines ->
                if List.length lines == List.length mappedLines then
                    lines |> Ok

                else
                    "CSV mapping failed!" |> Err
           )


map : List String -> Result String (List (List String))
map csv =
    csv |> List.map mapLine |> gatherResults
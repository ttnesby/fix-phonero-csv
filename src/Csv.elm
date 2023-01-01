module Csv exposing (..)


splitStr : String
splitStr =
    ";"


split : String -> List String
split =
    String.split splitStr


requiredColumns : Int
requiredColumns =
    17


mapValue : Int -> String -> String
mapValue colNo existingValue =
    if List.member colNo [ 0, 1 ] then
        "0"

    else if List.member colNo [ 4, 5, 6 ] then
        "0.00"

    else if colNo == 16 then
        "\"\""

    else
        existingValue


mapLineErr : Int -> Int -> Int -> String
mapLineErr reqCols lineNo actCol =
    [ "At line "
    , String.fromInt (lineNo + 1)
    , ", found "
    , String.fromInt actCol
    , " columns, expected "
    , String.fromInt reqCols
    ]
        |> String.concat


invalidNoOfColumns : Int -> Int -> String
invalidNoOfColumns =
    mapLineErr requiredColumns


mapLine : Int -> String -> Result String (List String)
mapLine lineNo str =
    str
        |> split
        |> (\l ->
                ( l, List.length l )
                    |> (\( columns, noOfColumns ) ->
                            if noOfColumns == requiredColumns then
                                columns
                                    |> List.indexedMap mapValue
                                    |> Ok

                            else
                                Err <| invalidNoOfColumns lineNo noOfColumns
                       )
           )



-- gatherResults : List (Result String (List String)) -> Result String (List (List String))
-- gatherResults mappedLines =
--     mappedLines
--         |> List.filterMap Result.toMaybe
--         |> (\lines ->
--                 if List.length lines == List.length mappedLines then
--                     lines |> Ok
--                 else
--                     "CSV mapping failed!" |> Err
--            )


map : List String -> List (Result String (List String))
map csv =
    csv |> List.indexedMap mapLine



-- |> gatherResults

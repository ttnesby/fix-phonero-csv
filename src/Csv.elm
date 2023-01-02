module Csv exposing (..)

import Result exposing (toMaybe)


type CsvMappingStatus
    = Errors (List String)
    | Success (List (List String))


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
mapLineErr reqCols lineNo actCols =
    [ "Error at line "
    , String.fromInt (lineNo + 1)
    , ", found "
    , String.fromInt actCols
    , " column(s), expected "
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
                                invalidNoOfColumns lineNo noOfColumns
                                    |> Err
                       )
           )


removeEmptyLines : List String -> List String
removeEmptyLines l =
    let
        emptyStrToMaybe s =
            if String.isEmpty s then
                Nothing

            else
                Just s
    in
    l |> List.filterMap emptyStrToMaybe


toErrorsOrSuccess : List (Result String (List String)) -> CsvMappingStatus
toErrorsOrSuccess l =
    let
        errToMaybe r =
            case r of
                Err msg ->
                    Just msg

                _ ->
                    Nothing

        errorsOrSuccess : ( List String, List (List String) ) -> CsvMappingStatus
        errorsOrSuccess ( errors, mappedLines ) =
            if List.isEmpty errors then
                Success mappedLines

            else
                Errors errors
    in
    ( List.filterMap errToMaybe l, List.filterMap toMaybe l )
        |> errorsOrSuccess


map : List String -> CsvMappingStatus
map csv =
    csv
        |> removeEmptyLines
        |> List.indexedMap mapLine
        |> toErrorsOrSuccess

module CsvTests exposing (..)

import Csv exposing (..)
import Expect exposing (..)
import Fuzz exposing (string)
import Set exposing (..)
import Test exposing (..)


mapV : List Int -> String -> Set String
mapV cols str =
    cols
        |> List.map Csv.mapValue
        |> List.map (\f -> f str)
        |> Set.fromList



-- required- + 1 column corresponds to `requiredColumns` no of semicolons


colGTRequired : String
colGTRequired =
    String.repeat requiredColumns splitStr



-- requiredColumns corresponds to `requiredColumns` - 1 no of semicolons


colRequired : String
colRequired =
    String.repeat (requiredColumns - 1) splitStr


colReqMapped : List String
colReqMapped =
    [ "0"
    , "0"
    , ""
    , ""
    , "0.00"
    , "0.00"
    , "0.00"
    , ""
    , ""
    , ""
    , ""
    , ""
    , ""
    , ""
    , ""
    , ""
    , "\"\""
    ]



-- required- - 1 column ...


colLTRequired : String
colLTRequired =
    String.repeat (requiredColumns - 2) splitStr


csv : Test
csv =
    describe "Test Csv module"
        [ describe "mapValue"
            [ fuzz string
                "column 1 and 2 should always give \"0\""
                (\str ->
                    mapV [ 0, 1 ] str
                        |> Expect.equal (Set.singleton "0")
                )
            , fuzz string
                "column 5,6 and 7 should always give \"0.00\""
                (\str ->
                    mapV [ 4, 5, 6 ] str
                        |> Expect.equal (Set.singleton "0.00")
                )
            , fuzz string
                "column 17 should always give \"\""
                (\str ->
                    mapV [ 16 ] str
                        |> Expect.equal (Set.singleton "\"\"")
                )
            , fuzz string
                "column 3,4,8..16 should always give existing column value"
                (\str ->
                    mapV [ 2, 3, 7, 8, 9, 10, 11, 12, 13, 14, 15 ] str
                        |> Expect.equal (Set.singleton str)
                )
            ]
        , describe "mapLine"
            [ test "Required + 1 column"
                (\_ ->
                    colGTRequired
                        |> Csv.mapLine 0
                        |> Expect.equal (Err <| invalidNoOfColumns 0 <| requiredColumns + 1)
                )
            , test " Required - 1 column"
                (\_ ->
                    colLTRequired
                        |> Csv.mapLine 0
                        |> Expect.equal (Err <| invalidNoOfColumns 0 <| requiredColumns - 1)
                )
            , test " Required columns"
                (\_ ->
                    colRequired
                        |> Csv.mapLine 0
                        |> Expect.equal (Ok colReqMapped)
                )
            ]
        , describe "map"
            [ test " 1 line, required + 1 column"
                (\_ ->
                    [ colGTRequired ]
                        |> Csv.map
                        |> Expect.equal (Errors [invalidNoOfColumns 0 (requiredColumns + 1)])
                )
            , test " 1 line, required - 1 column"
                (\_ ->
                    [ colLTRequired ]
                        |> Csv.map
                        |> Expect.equal (Errors [invalidNoOfColumns 0 (requiredColumns - 1)])
                )
            , test " 1 line, required columns"
                (\_ ->
                    [ colRequired ]
                        |> Csv.map
                        |> Expect.equal (Success [colReqMapped])
                )
            , test " 3 lines, 1st required + 1 column, 2nd required, 3rd required - 1 column"
                (\_ ->
                    [ colGTRequired, colRequired, colLTRequired ]
                        |> Csv.map
                        |> Expect.equal
                            (Errors [ 
                                invalidNoOfColumns 0 (requiredColumns + 1)  
                                ,invalidNoOfColumns 2 (requiredColumns - 1)
                            ])
                )
            ]
        ]

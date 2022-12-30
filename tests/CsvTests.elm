module CsvTests exposing (..)

import Csv exposing (..)
import Expect exposing (..)
import Fuzz exposing (string)
import Test exposing (..)
import Set exposing (..)

mapV : List Int -> String -> Set String
mapV cols str =
    cols
        |> List.map Csv.mapValue
        |> List.map (\f -> f str)
        |> Set.fromList    

csv : Test
csv =
    describe "Test Csv module"
        [ describe "mapValue"
            [ fuzz string
                "column 1 and 2 should always give \"0\""
                (\str ->
                    mapV [0,1] str
                    |> Expect.equal (Set.singleton "0")
                )
            , fuzz string
                "column 5,6 and 7 should always give \"0.00\""
                (\str -> 
                    mapV [4,5,6] str
                    |> Expect.equal (Set.singleton "0.00")
                )
            , fuzz string
                "column 17 should always give \"\""
                (\str -> 
                    mapV [16] str
                    |> Expect.equal (Set.singleton "\"\"")
                )
            , fuzz string
                "column 3,4,8..16 should always give given value"
                (\str -> 
                    mapV [2,3,7,8,9,10,11,12,13,14,15] str
                    |> Expect.equal (Set.singleton str)
                )                                
            ]
        ]

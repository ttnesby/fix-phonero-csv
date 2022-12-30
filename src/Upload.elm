module Upload exposing (..)

-- https://github.com/elm/file/blob/master/README.md

import Browser
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Html, a, button, div, img, table, td, text, tr, p)
import Html.Attributes exposing (height, href, src, style, target, width)
import Html.Events exposing (onClick)
import String
import Task
import Csv exposing(mapCSV)  



-- HELPERS


csvCol : Int -> String -> Html Msg
csvCol colNo value =
    if List.member colNo [ 0, 1, 4, 5, 6, 16 ] then
        td [ style "background-color" "#D6EEEE" ] [ text value ]

    else
        td [] [ text value ]


csvRow : String -> Html Msg
csvRow row =
    tr []
        (row
            |> String.split ";"
            |> List.indexedMap csvCol
        )


downloadCSV : List String -> String -> Cmd Msg
downloadCSV csv fName =
    Download.string fName "text/csv" (String.join "\n" csv)


downloadFileName : String -> String
downloadFileName fName =
    String.dropRight 4 fName ++ "-FIXED.csv"



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { csv : Maybe (Result String (List String))
    , fName : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing "", Cmd.none )



-- UPDATE


type Msg
    = CsvRequested
    | CsvSelected File
    | CsvLoaded String
    | CsvDownload


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CsvRequested ->
            ( model
            , Select.file [ "text/csv" ] CsvSelected
            )

        CsvSelected file ->
            ( { model | fName = downloadFileName <| File.name file }
            , Task.perform CsvLoaded (File.toString file)
            )

        CsvLoaded content ->
            ( { model | csv = Just <| Csv.map <| String.lines <| content }
            , Cmd.none
            )

        CsvDownload ->
            ( model
            , downloadCSV (model.csv |> Maybe.withDefault (Ok [ "" ]) |> Result.withDefault [ "" ]) model.fName
            )



-- VIEW


view : Model -> Html Msg
view model =
    case model.csv of
        Nothing ->
            div []
                [ table [ style "border-spacing" "5px" ]
                    [ tr []
                        [ td []
                            [ a [ target "_blank", href "https://github.com/ttnesby/fix-phonero-csv" ]
                                [ img [ src "./media/github-mark.png", width 25, height 25 ] []
                                ]
                            ]
                        , td []
                            [ button [ onClick CsvRequested ] [ text "Load CSV" ]
                            ]
                        ]
                    ]
                ]

        Just content ->
            case content of
                Ok mappedCSV ->
                    div []
                        [ button [ onClick CsvDownload ] [ text <| "Download " ++ model.fName ]
                        , table [ style "border-spacing" "10px" ]
                            (List.map csvRow mappedCSV)
                        , button [ onClick CsvDownload ] [ text <| "Download " ++ model.fName ]
                        ]

                Err msg ->
                    div []
                        [ p [ style "white-space" "pre" ] [ text msg ]
                        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

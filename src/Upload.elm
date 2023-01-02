module Upload exposing (..)

-- https://github.com/elm/file/blob/master/README.md

import Browser
import Csv exposing (..)
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Html, a, button, div, img, table, td, text, tr)
import Html.Attributes exposing (height, href, src, style, target, width)
import Html.Events exposing (onClick)
import String
import Task



-- HELPERS


csvCol : Int -> String -> Html Msg
csvCol colNo value =
    if List.member colNo [ 0, 1, 4, 5, 6, 16 ] then
        td [ style "background-color" "#D6EEEE" ] [ text value ]

    else
        td [] [ text value ]


csvRow : List String -> Html Msg
csvRow columns =
    tr [] (List.indexedMap csvCol columns)


csvErrors : String -> Html Msg
csvErrors msg =
    tr [] [ td [] [ text msg ] ]


downloadCSV : List (List String) -> String -> Cmd Msg
downloadCSV csv fName =
    csv
        |> List.map (String.join ";")
        |> String.join "\n"
        |> (\str -> Download.string fName "text/csv" str)


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
    { csv : Maybe Csv.CsvMappingStatus
    , fName : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing "", Cmd.none )



-- UPDATE


type Msg
    = CsvRequested
    | CsvSelected File
    | CsvUpLoaded String
    | CsvDownload (List (List String)) String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CsvRequested ->
            ( model
            , Select.file [ "text/csv" ] CsvSelected
            )

        CsvSelected file ->
            ( { model | fName = File.name file }
            , Task.perform CsvUpLoaded (File.toString file)
            )

        CsvUpLoaded content ->
            ( { model | csv = Just <| Csv.map <| String.lines <| content }
            , Cmd.none
            )

        CsvDownload lines fname ->
            ( model
            , downloadCSV lines fname
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

        Just mapped ->
            case mapped of
                Errors msgs ->
                    div [] [ table [ style "border-spacing" "10px" ] (List.map csvErrors msgs) ]

                Success lines ->
                    let
                        dlFileName =
                            downloadFileName model.fName

                        dlButtonName =
                            "Download " ++ dlFileName
                    in
                    div []
                        [ button [ onClick (CsvDownload lines dlFileName) ] [ text dlButtonName ]
                        , table [ style "border-spacing" "10px" ] (List.map csvRow lines)
                        , button [ onClick (CsvDownload lines dlFileName) ] [ text dlButtonName ]
                        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

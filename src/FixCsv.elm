module FixCsv exposing (..)

-- https://github.com/elm/file/blob/master/README.md

import Browser
import Csv exposing (..)
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Html, a, button, div, img, p, table, td, text, tr)
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


viewFixCsv : () -> Html Msg
viewFixCsv () =
    div []
        [ table [ style "border-spacing" "5px" ]
            [ tr []
                [ td []
                    [ a [ target "_blank", href "https://github.com/ttnesby/fix-phonero-csv" ]
                        [ img [ src "./media/github-mark.png", width 25, height 25 ] []
                        ]
                    ]
                , td []
                    [ button [ onClick CsvRequested ] [ text "Fix CSV" ]
                    ]
                ]
            ]
        ]


viewCSVErrors : String -> List String -> Html Msg
viewCSVErrors fName msgs =
    let
        dlFileName =
            String.dropRight 4 fName ++ "-ERRORS.txt"

        title =
            String.join " " [ "Error(s) in uploaded file", fName ]

        str =
            title ++ "\n\n" ++ (msgs |> String.join "\n")

        dlButton =
            button [ onClick (FileDownload dlFileName "text/txt" str) ] [ text <| "Download " ++ dlFileName ]
    in
    div []
        [ p [ style "background-color" "yellow" ] [ text title ]
        , table [ style "border-spacing" "10px" ] (List.map csvErrors msgs)
        , dlButton
        ]


viewCSVFixed : String -> List (List String) -> Html Msg
viewCSVFixed fName lines =
    let
        dlFileName =
            String.dropRight 4 fName ++ "-FIXED.csv"

        str =
            lines |> List.map (String.join ";") |> String.join "\n"

        dlButton =
            button [ onClick (FileDownload dlFileName "text/csv" str) ] [ text <| "Download " ++ dlFileName ]
    in
    div []
        [ dlButton
        , table [ style "border-spacing" "10px" ] (List.map csvRow lines)
        , dlButton
        ]



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
    | FileDownload String String String


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

        FileDownload fname mime text ->
            ( Model Nothing ""
            , Download.string fname mime text
            )



-- VIEW


view : Model -> Html Msg
view model =
    case model.csv of
        Nothing ->
            viewFixCsv ()

        Just mapped ->
            case mapped of
                Errors msgs ->
                    viewCSVErrors model.fName msgs

                Success lines ->
                    viewCSVFixed model.fName lines



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

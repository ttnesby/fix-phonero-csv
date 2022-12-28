module Upload exposing (..)

-- https://github.com/elm/file/blob/master/README.md

import Browser
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


csvRow : String -> Html Msg
csvRow row =
    tr []
        (row
            |> String.split ";"
            |> List.indexedMap csvCol
        )


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


mapLine : String -> Result String String
mapLine str =
    str
        |> String.split ";"
        |> (\cols ->
                case List.length cols of
                    17 ->
                        cols
                            |> List.indexedMap mapValue
                            |> String.join ";"
                            |> Ok

                    x ->
                        [ String.fromInt <| x, " columns, expected 17" ]
                            |> String.concat
                            |> Err
           )


gatherResults : List (Result String String) -> Result String (List String)
gatherResults mappedLines =
    mappedLines
        |> List.filterMap Result.toMaybe
        |> (\lines ->
                if List.length lines == List.length mappedLines then
                    lines |> Ok

                else
                    "CSV mapping failed!" |> Err
           )


mapCSV : List String -> Result String (List String)
mapCSV csv =
    csv |> List.map mapLine |> gatherResults


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
            ( { model | csv = Just <| mapCSV <| String.lines <| content }
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

                        --, p [ style "white-space" "pre" ] [ text <| mapCSV <| content ]
                        , table [ style "border-spacing" "10px" ]
                            (List.map csvRow mappedCSV)
                        , button [ onClick CsvDownload ] [ text <| "Download " ++ model.fName ]
                        ]

                _ ->
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

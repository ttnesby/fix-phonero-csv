module Upload exposing (..)

-- https://github.com/elm/file/blob/master/README.md

import Browser
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Html, button, div, table, td, text, tr)
import Html.Attributes exposing (style)
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
    let
        cols =
            row |> mapLine |> String.split ";"
    in
    tr []
        (List.indexedMap csvCol cols)


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


mapLine : String -> String
mapLine str =
    let
        split =
            String.split ";" str
    in
    if List.length split == 1 then
        ""

    else if List.length split /= 17 then
        String.concat [ String.fromInt <| List.length split, " columns, expected 17" ]

    else
        split
            |> List.indexedMap mapValue
            |> List.foldr (\x y -> x ++ ";" ++ y) ""
            |> (\x -> String.dropRight 1 x)


mapCSV : List String -> String
mapCSV csv =
    case csv of
        [] ->
            ""

        h :: t ->
            (h |> mapLine) ++ "\n" ++ mapCSV t


downloadCSV : Maybe (List String) -> String -> Cmd Msg
downloadCSV csv fName =
    case csv of
        Nothing ->
            Cmd.none

        Just content ->
            Download.string fName "text/csv" (mapCSV content)


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
    { csv : Maybe (List String)
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
            ( { model | csv = Just <| String.lines <| content }
            , Cmd.none
            )

        CsvDownload ->
            ( model
            , downloadCSV model.csv model.fName
            )



-- VIEW


view : Model -> Html Msg
view model =
    case model.csv of
        Nothing ->
            button [ onClick CsvRequested ] [ text "Load CSV" ]

        Just content ->
            div []
                [ button [ onClick CsvDownload ] [ text <| "Download " ++ model.fName ]

                --, p [ style "white-space" "pre" ] [ text <| mapCSV <| content ]
                , table [ style "border-spacing" "10px" ]
                    (List.map csvRow content)
                , button [ onClick CsvDownload ] [ text <| "Download " ++ model.fName ]
                ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

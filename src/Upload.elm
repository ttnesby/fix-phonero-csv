module Upload exposing (..)

-- https://github.com/elm/file/blob/master/README.md

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import String
import Task


mapValue : Int -> String -> String
mapValue colNo value =
    if colNo == 0 || colNo == 1 then
        "0"

    else if colNo == 4 || colNo == 5 || colNo == 6 then
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
    if List.length split == 1 then --
        ""

    else if List.length split /= 17 then
        String.concat [ String.fromInt <| List.length split, " columns, expected 17" ]

    else
        split
            |> List.indexedMap mapValue
            |> List.foldr (\x y -> x ++ ";" ++ y) ""
            |> (\x -> String.dropRight 1 x) -- remove last semicolon


mapCSV : List String -> String
mapCSV csv =
    case csv of
        [] ->
            ""

        h :: t ->
            (h |> mapLine) ++ "\n" ++ mapCSV t



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
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing, Cmd.none )



-- UPDATE


type Msg
    = CsvRequested
    | CsvSelected File
    | CsvLoaded String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CsvRequested ->
            ( model
            , Select.file [ "text/csv" ] CsvSelected
            )

        CsvSelected file ->
            ( model
            , Task.perform CsvLoaded (File.toString file)
            )

        CsvLoaded content ->
            ( { model | csv = Just <| String.lines <| content }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    case model.csv of
        Nothing ->
            button [ onClick CsvRequested ] [ text "Load CSV" ]

        Just content ->
            p [ style "white-space" "pre" ] [ text <| mapCSV <| content ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

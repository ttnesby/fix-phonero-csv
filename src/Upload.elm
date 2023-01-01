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


csvRow : Result String (List String) -> Html Msg
csvRow row =
    tr []
        (case row of
            Ok columns ->
                List.indexedMap csvCol columns

            Err msg ->
                List.indexedMap csvCol (List.append (List.repeat (requiredColumns - 1) "") [ msg ])
        )


downloadCSV : List String -> String -> Cmd Msg
downloadCSV csv fName =
    Download.string fName "text/csv" (String.join "\n" csv)


downloadFileName : String -> List (Result String (List String)) -> String
downloadFileName fName content =

    let
        hasErr : Result String (List String) -> Bool
        hasErr r =
            case r of
                Err _ ->
                    True

                _ ->
                    False

        postfix = if List.any hasErr content then "ERROR" else "FIXED"
    in
        String.dropRight 4 fName ++ "-" ++ postfix ++ ".csv"



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
    { csv : Maybe (List (Result String (List String)))
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
            ( { model | fName = File.name file }
            , Task.perform CsvLoaded (File.toString file)
            )

        CsvLoaded content ->
            ( { model | csv = Just <| Csv.map <| String.lines <| content }
            , Cmd.none
            )

        CsvDownload ->
            ( model
            , case model.csv of
                Just content -> downloadCSV [ "testing" ] (downloadFileName model.fName content)
                Nothing -> Cmd.none
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
            div []
                [ button [ onClick CsvDownload ] [ text <| "Download " ++ (downloadFileName model.fName content) ]
                , table [ style "border-spacing" "10px" ] (List.map csvRow content)
                , button [ onClick CsvDownload ] [ text <| "Download " ++ (downloadFileName model.fName content) ]
                ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

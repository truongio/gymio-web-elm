module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (..)
import Json.Encode as Encode



---- MODEL ----


type alias Model =
    { description : String
    , weight : Int
    , bench : Int
    , deadlift : Int
    , squat : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { description = """Welcome to Gymio. Please enter your user stats. 
                         If you wish to contribute to the project go to: """
      , weight = 0
      , bench = 0
      , deadlift = 0
      , squat = 0
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = SaveStats
    | ChangeWeight String
    | ChangeBench String
    | ChangeDeadlift String
    | ChangeSquat String
    | GotItems (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveStats ->
            ( model, fetchItems model )

        GotItems result ->
            ( model, Cmd.none )

        ChangeWeight newContent ->
            ( { model | weight = String.toInt newContent |> Maybe.withDefault 0 }, Cmd.none )

        ChangeBench newContent ->
            ( { model | bench = String.toInt newContent |> Maybe.withDefault 0 }, Cmd.none )
            
        ChangeDeadlift newContent ->
            ( { model | deadlift = String.toInt newContent |> Maybe.withDefault 0 }, Cmd.none )

        ChangeSquat newContent ->
            ( { model | squat = String.toInt newContent |> Maybe.withDefault 0 }, Cmd.none )


fetchItems : Model -> Cmd Msg
fetchItems model =
    Http.post
        { url = "https://api.gymioapp.com/user-stats/04fd1e05-b91e-4b67-9cd3-ee7cae7fe1bd"
        , body = Http.jsonBody (dataEncoder model)
        , expect = Http.expectJson GotItems string
        }


dataEncoder : Model -> Encode.Value
dataEncoder model =
    Encode.object
        [ ( "trainingMaxes"
          , Encode.object
                [ ( "BenchPress"
                  , Encode.object
                        [ ( "value", Encode.int model.bench ), ( "unit", Encode.string "kg" ) ]
                  )
                , ( "Deadlift"
                  , Encode.object
                        [ ( "value", Encode.int model.deadlift ), ( "unit", Encode.string "kg" ) ]
                  )
                , ( "OverheadPress"
                  , Encode.object
                        [ ( "value", Encode.int 10 ), ( "unit", Encode.string "kg" ) ]
                  )
                , ( "Squat"
                  , Encode.object
                        [ ( "value", Encode.int model.squat ), ( "unit", Encode.string "kg" ) ]
                  )
                ]
          )
        , ( "bodyWeight"
          , Encode.object
                [ ( "value", Encode.int model.weight ), ( "unit", Encode.string "kg" ) ]
          )
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div
            [ class "row" ]
            [ div [ class "one-half column title" ]
                [ h4 [] [ text "Gymio" ]
                , p []
                    [ text model.description
                    , a [ href "https://github.com/truongio/gymio-web" ] [ text "https://github.com/truongio/gymio-web" ]
                    ]
                , label [ for "weight" ] [ text "Your weight" ]
                , input
                    [ id "weight"
                    , placeholder "Over 9000!!!"
                    , type_ "number"
                    , onInput ChangeWeight
                    , Html.Attributes.value (String.fromInt model.weight)
                    ]
                    []
                , label [ for "bench" ] [ text "Bench Press" ]
                , input
                    [ id "bench"
                    , placeholder "Over 9000!!!"
                    , type_ "number"
                    , onInput ChangeBench
                    , Html.Attributes.value (String.fromInt model.bench)
                    ]
                    []
                , label [ for "deadlift" ] [ text "Deadlift" ]
                , input
                    [ id "deadlift"
                    , placeholder "Over 9000!!!"
                    , type_ "number"
                    , onInput ChangeDeadlift
                    , Html.Attributes.value (String.fromInt model.deadlift)
                    ]
                    []
                , label [ for "squat" ] [ text "Squat" ]
                , input
                    [ id "squat"
                    , placeholder "Over 9000!!!"
                    , type_ "number"
                    , onInput ChangeSquat
                    , Html.Attributes.value (String.fromInt model.squat)
                    ]
                    []
                , br [] []
                , button [ class "button-primary", onClick SaveStats ] [ text "Loggit" ]
                ]
            ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }

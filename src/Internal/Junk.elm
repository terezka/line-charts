module Internal.Junk exposing (..)

{-| -}

import Svg exposing (Svg)
import Html exposing (Html)
import Html.Attributes
import LineChart.Coordinate as Coordinate



{-| -}
type Config data msg =
  Config ((data -> Maybe Float) -> (data -> Maybe Float) -> Coordinate.System -> Layers msg)


{-| -}
none : Config data msg
none =
  Config (\_ _ _ -> Layers [] [] [])


{-| -}
custom : (Coordinate.System -> Layers msg) -> Config data msg
custom func =
  Config (\_ _ -> func)


{-| -}
type alias Layers msg =
  { below : List (Svg msg)
  , above : List (Svg msg)
  , html : List (Html msg)
  }


{-| -}
getLayers : (data -> Maybe Float) -> (data -> Maybe Float) -> Coordinate.System -> Config data msg -> Layers msg
getLayers toX toY system (Config toLayers) =
  toLayers toX toY system


{-| -}
addBelow : List (Svg msg) -> Layers msg -> Layers msg
addBelow below layers =
  { layers | below = below ++ layers.below }



-- SPECIAL


tooltipOne : Maybe data -> List ( String, data -> String ) -> Config data msg
tooltipOne hovered properties =
  Config <| \toX toY system ->
    { below = []
    , above = []
    , html =
      case hovered of
        Just data -> [ tooltipHtml toX toY system data properties ]
        Nothing -> []
    }


tooltipHtml : (data -> Maybe Float) -> (data -> Maybe Float) -> Coordinate.System -> data -> List ( String, data -> String ) -> Html.Html msg
tooltipHtml toX toY system hovered properties =
  let
    xMiddle = system.x.max - system.x.min / 2
    yMiddle = system.y.max - system.y.min / 2
    x = Maybe.withDefault xMiddle (toX hovered)
    y = Maybe.withDefault yMiddle (toY hovered)

    shouldFlip =
      -- is point closer to the left or right side?
      -- if closer to the right, flip tooltip
      x - system.x.min > system.x.max - x

    space = if shouldFlip then -15 else 15
    xPosition = Coordinate.toSvgX system x + space
    yPosition = Coordinate.toSvgY system y

    containerStyles =
      [ ( "left", toString xPosition ++ "px" )
      , ( "top", toString yPosition ++ "px" )
      , ( "width", "100px" )
      , ( "position", "absolute" )
      , ( "padding", "5px" )
      , ( "background", "rgba(255,255,255,0.8)" )
      , ( "border", "1px solid #d3d3d3" )
      , ( "border-radius", "5px" )
      , ( "pointer-events", "none" )
      , if shouldFlip
          then ( "transform", "translateX(-100%)" )
          else ( "transform", "translateX(0)" )
      ]

    viewRow ( label, value ) =
      Html.p
        [ Html.Attributes.style valueStyles ]
        [ Html.text <| label ++ ": " ++ value hovered ]

    valueStyles =
      [ ( "margin", "3px" ) ]

    valuesHtml =
      List.map viewRow properties
  in
  Html.div [ Html.Attributes.style containerStyles ] valuesHtml

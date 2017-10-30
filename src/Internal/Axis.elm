module Internal.Axis exposing (..)


import Lines.Axis as Axis exposing (Mark)
import Internal.Utils exposing (..)
import Internal.Primitives exposing (..)
import Lines.Coordinate as Coordinate  exposing (..)
import Svg exposing (Attribute, Svg, g)
import Svg.Attributes as Attributes exposing (class, fill, style, x1, x2, y1, y2, stroke, d)



-- VIEWS


viewHorizontal : Coordinate.System -> Axis.Look msg -> Svg msg
viewHorizontal system axis =
    let
        axisPosition =
          axis.position system.y - scaleCartesian Y system axis.offset

        at x =
          { x = x, y = axisPosition }

        viewAxisLine { start, end, attributes } =
          horizontal system attributes axisPosition start end

        viewMark { position, tick, label } =
          g [ class "mark" ]
            [ viewMaybe tick (viewHorizontalTick system axis (at position))
            , viewMaybe label (viewHorizontalLabel system axis (at position))
            ]
    in
    g [ class "axis--horizontal" ]
      [ viewHorizontalTitle system at axis
      , viewMaybe axis.line (apply system.x >> viewAxisLine)
      , g [ class "marks" ] (List.map viewMark (apply system.x axis.marks))
      ]


viewVertical : Coordinate.System -> Axis.Look msg -> Svg msg
viewVertical system axis =
    let
        axisPosition =
          axis.position system.x - scaleCartesian X system axis.offset

        at y =
          { x = axisPosition, y = y }

        viewAxisLine { start, end, attributes } =
          vertical system attributes axisPosition start end

        viewMark { position, tick, label } =
          g [ class "mark" ]
            [ viewMaybe tick (viewVerticalTick system axis (at position))
            , viewMaybe label (viewVerticalLabel system axis (at position))
            ]
    in
    g [ class "axis--vertical" ]
      [ viewVerticalTitle system at axis
      , viewMaybe axis.line (apply system.y >> viewAxisLine)
      , g [ class "marks" ] (List.map viewMark (apply system.y axis.marks))
      ]



-- VIEW TITLE


viewHorizontalTitle : Coordinate.System -> (Float -> Point) -> Axis.Look msg -> Svg msg
viewHorizontalTitle system at { title } =
  let
    position =
      at (title.position system.x)

    transform =
      placeWithOffset system position.x position.y title.xOffset (title.yOffset + 40)
  in
  g [ class "title", style "text-anchor: middle;", transform ]
    [ title.view ]


viewVerticalTitle : Coordinate.System -> (Float -> Point) -> Axis.Look msg -> Svg msg
viewVerticalTitle system at { title } =
  let
    position =
      at (title.position system.y)

    transform =
      placeWithOffset system position.x position.y (title.xOffset - 5) (title.yOffset - 15)
  in
  g [ class "title", style "text-anchor: middle;", transform ]
    [ title.view ]



-- VIEW TICK


viewHorizontalTick : Coordinate.System -> Axis.Look msg -> Point -> Axis.Tick msg -> Svg msg
viewHorizontalTick system view { x, y } { attributes, length } =
    xTick system (lengthOfTick view length) attributes y x


viewVerticalTick : Coordinate.System -> Axis.Look msg -> Point -> Axis.Tick msg -> Svg msg
viewVerticalTick system view { x, y } { attributes, length } =
    yTick system (lengthOfTick view length) attributes x y


lengthOfTick : Axis.Look msg -> Int -> Int
lengthOfTick { direction } length =
    if isPositive direction then
        -length
    else
        length



-- VIEW LABEL


viewHorizontalLabel : Coordinate.System -> Axis.Look msg -> Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction } position view =
    let
        offset =
            if isPositive direction then
                -10
            else
                20
    in
    g [ placeWithOffset system position.x position.y 0 offset, style "text-anchor: middle;" ]
      [ view ]


viewVerticalLabel : Coordinate.System -> Axis.Look msg -> Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction } position view =
    let
        anchorOfLabel =
            if isPositive direction then
                "text-anchor: start;"
            else
                "text-anchor: end;"

        offset =
            if isPositive direction then
                10
            else
                -10
    in
    g [ placeWithOffset system position.x position.y offset 5, style anchorOfLabel ]
      [ view ]



-- UTILS


isPositive : Axis.Direction -> Bool
isPositive direction =
    case direction of
        Axis.Positive ->
            True

        Axis.Negative ->
            False

module Internal.Axis exposing (..)


import Lines.Axis as Axis exposing (Mark)
import Internal.Utils exposing (..)
import Internal.Junk as Junk exposing (..)
import Lines.Coordinate as Coordinate  exposing (..)
import Svg exposing (Attribute, Svg, g)
import Svg.Attributes as Attributes exposing (class, fill, style, x1, x2, y1, y2, stroke, d)
import Lines.Junk as Junk exposing (..)



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
  in
  g [ class "title"
    , transform
        [ move system position.x position.y
        , offset title.xOffset (title.yOffset + 40)
        ]
    , Junk.anchor Junk.Middle
    ]
    [ title.view ]


viewVerticalTitle : Coordinate.System -> (Float -> Point) -> Axis.Look msg -> Svg msg
viewVerticalTitle system at { title } =
  let
    position =
      at (title.position system.y)
  in
  g [ class "title"
    , transform
        [ move system position.x position.y
        , offset (title.xOffset - 5) (title.yOffset - 15)
        ]
    , Junk.anchor Junk.Middle
    ]
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
        yOffset =
            if isPositive direction then
                -10
            else
                20
    in
    g [ transform [ move system position.x position.y, offset 0 yOffset ]
      , Junk.anchor Junk.Middle
      ]
      [ view ]


viewVerticalLabel : Coordinate.System -> Axis.Look msg -> Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction } position view =
    let
        anchor =
            if isPositive direction
              then Junk.Start
              else Junk.End

        xOffset =
            if isPositive direction then
                10
            else
                -10
    in
    g [ transform [ move system position.x position.y, offset xOffset 5 ]
      , Junk.anchor anchor
      ]
      [ view ]



-- UTILS


isPositive : Axis.Direction -> Bool
isPositive direction =
    case direction of
        Axis.Positive ->
            True

        Axis.Negative ->
            False

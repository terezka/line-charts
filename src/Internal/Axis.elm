module Internal.Axis exposing (..)


import Svg exposing (Svg, Attribute, g)
import Svg.Attributes as Attributes exposing (class)
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Utils exposing (..)
import Internal.Numbers as Numbers
import Internal.Svg as Svg exposing (..)



-- CONFIG


{-| -}
type alias Axis data msg =
  { variable : data -> Float
  , limits : Coordinate.Limits -> Coordinate.Limits
  , look : Look msg
  , length : Float
  }


{-| -}
type alias Look msg =
  { title : Title msg
  , position : Coordinate.Limits -> Float
  , offset : Float
  , line : Maybe (Coordinate.Limits -> Line msg)
  , marks : Coordinate.Limits -> List (Mark msg)
  , direction : Direction
  }


{-| -}
type alias Title msg =
    { view : Svg msg
    , position : Coordinate.Limits -> Float
    , xOffset : Float
    , yOffset : Float
    }


{-| -}
type alias Mark msg =
  { label : Maybe (Svg msg)
  , tick : Maybe (Tick msg)
  , position : Float
  }


{-| -}
type alias Line msg =
  { attributes : List (Attribute msg)
  , start : Float
  , end : Float
  }


{-| -}
type alias Tick msg =
  { attributes : List (Attribute msg)
  , length : Int
  }


{-| -}
type Direction
  = Negative
  | Positive


-- HELP


axis : Float -> (data -> Float) -> String -> Axis data msg
axis length variable title =
  { variable = variable
  , limits = identity
  , look =
      { title = Title (defaultTitle title) .max 0 0
      , position = towardsZero
      , offset = 0
      , line =
        Just <| \limits ->
          { attributes = []
          , start = limits.min
          , end = limits.max
          }
      , marks = List.map mark << Numbers.defaultInterval length
      , direction = Negative
      }
  , length = length
  }


mark : Float -> Mark msg
mark position =
  { label = Just (defaultLabel position)
  , tick = Just (Tick [] 5)
  , position = position
  }


defaultTitle : String -> Svg msg
defaultTitle title =
   Svg.text_ [] [ Svg.tspan [] [ Svg.text title ] ]


defaultLabel : Float -> Svg msg
defaultLabel position =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text (toString position) ] ]



-- VIEW


{-| -}
viewHorizontal : Coordinate.System -> Look msg -> Svg msg
viewHorizontal system axis =
    let
        axisPosition =
          axis.position system.y - scaleDataY system axis.offset

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


{-| -}
viewVertical : Coordinate.System -> Look msg -> Svg msg
viewVertical system axis =
    let
        axisPosition =
          axis.position system.x - scaleDataX system axis.offset

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


viewHorizontalTitle : Coordinate.System -> (Float -> Point) -> Look msg -> Svg msg
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
    , anchorStyle Middle
    ]
    [ title.view ]


viewVerticalTitle : Coordinate.System -> (Float -> Point) -> Look msg -> Svg msg
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
    , anchorStyle Middle
    ]
    [ title.view ]



-- VIEW TICK


viewHorizontalTick : Coordinate.System -> Look msg -> Point -> Tick msg -> Svg msg
viewHorizontalTick system view { x, y } { attributes, length } =
  xTick system (lengthOfTick view length) attributes y x


viewVerticalTick : Coordinate.System -> Look msg -> Point -> Tick msg -> Svg msg
viewVerticalTick system view { x, y } { attributes, length } =
  yTick system (lengthOfTick view length) attributes x y


lengthOfTick : Look msg -> Int -> Int
lengthOfTick { direction } length =
  if isPositive direction then -length else length



-- VIEW LABEL


viewHorizontalLabel : Coordinate.System -> Look msg -> Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction } position view =
  let
    yOffset = if isPositive direction then -10 else 20
  in
  g [ transform [ move system position.x position.y, offset 0 yOffset ]
    , anchorStyle Middle
    ]
    [ view ]


viewVerticalLabel : Coordinate.System -> Look msg -> Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction } position view =
  let
    anchor = if isPositive direction then Start else End
    xOffset = if isPositive direction then 10 else -10
  in
  g [ transform [ move system position.x position.y, offset xOffset 5 ]
    , anchorStyle anchor
    ]
    [ view ]



-- UTILS


isPositive : Direction -> Bool
isPositive direction =
  case direction of
    Positive -> True
    Negative -> False

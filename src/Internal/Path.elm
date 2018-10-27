module Internal.Path exposing (Command(..), view, toPoint)

{-| SVG path commands.

@docs Command, view

-}

import Svg exposing (Svg, Attribute)
import Svg.Attributes exposing (d)
import LineChart.Coordinate as Coordinate exposing (..)



{-| -}
type Command
  = Move Point
  | Line Point
  | Horizontal Float
  | Vertical Float
  | CubicBeziers Point Point Point
  | CubicBeziersShort Point Point
  | QuadraticBeziers Point Point
  | QuadraticBeziersShort Point
  | Arc Float Float Int Bool Bool Point
  | Close


{-| Makes a path SVG element, translating your commands with the provided system.

    view =
      Svg.Path.view system attributes commands

-}
view : Coordinate.System -> List (Attribute msg) -> List Command -> Svg msg
view system attributes commands =
  viewPath <| attributes ++ [ d (description system commands) ]



-- INTERNAL


viewPath : List (Attribute msg) -> Svg msg
viewPath attributes =
  Svg.path attributes []


description : System -> List Command -> String
description system commands =
  join (List.map (translate system >> toString) commands)


toPoint : Command -> Point
toPoint command =
  case command of
    Close -> Point 0 0

    Move p       -> p
    Line p       -> p
    Horizontal x -> Point x 0
    Vertical y   -> Point 0 y

    CubicBeziers c1 c2 p    -> p
    CubicBeziersShort c1 p  -> p
    QuadraticBeziers c1 p   -> p
    QuadraticBeziersShort p -> p

    Arc rx ry xAxisRotation largeArcFlag sweepFlag p ->
      p


toString : Command -> String
toString command =
  case command of
    Close -> "Z"

    Move p       -> "M" ++ point p
    Line p       -> "L" ++ point p
    Horizontal x -> "H" ++ String.fromFloat x
    Vertical y   -> "V" ++ String.fromFloat y

    CubicBeziers c1 c2 p    -> "C" ++ points [ c1, c2, p ]
    CubicBeziersShort c1 p  -> "Q" ++ points [ c1, p ]
    QuadraticBeziers c1 p   -> "Q" ++ points [ c1, p ]
    QuadraticBeziersShort p -> "T" ++ point p

    Arc rx ry xAxisRotation largeArcFlag sweepFlag p ->
      "A" ++ join
        [ String.fromFloat rx
        , String.fromFloat ry
        , String.fromInt xAxisRotation
        , bool largeArcFlag
        , bool sweepFlag
        , point p
        ]


translate : System -> Command -> Command
translate system command =
  case command of
    Move p       -> Move (toSvg system p)
    Line p       -> Line (toSvg system p)
    Horizontal x -> Horizontal (toSvgX system x)
    Vertical y   -> Vertical (toSvgY system y)

    CubicBeziers c1 c2 p ->
      CubicBeziers
        (toSvg system c1)
        (toSvg system c2)
        (toSvg system p)

    CubicBeziersShort c1 p ->
      CubicBeziersShort
        (toSvg system c1)
        (toSvg system p)

    QuadraticBeziers c1 p ->
      QuadraticBeziers
        (toSvg system c1)
        (toSvg system p)

    QuadraticBeziersShort p ->
      QuadraticBeziersShort
        (toSvg system p)

    Arc rx ry xAxisRotation largeArcFlag sweepFlag p ->
      Arc rx ry xAxisRotation largeArcFlag sweepFlag (toSvg system p)

    Close ->
      Close



-- HELP


join : List String -> String
join commands =
  String.join " " commands


point : Point -> String
point point_ =
  String.fromFloat point_.x ++ " " ++ String.fromFloat point_.y


points : List Point -> String
points points_ =
  String.join "," (List.map point points_)


bool : Bool -> String
bool bool_ =
  if bool_ then "1" else "0"

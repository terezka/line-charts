module Internal.Path exposing (Command(..), view)

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


toString : Command -> String
toString command =
  case command of
    Close -> "Z"

    Move p       -> "M" ++ point p
    Line p       -> "L" ++ point p
    Horizontal x -> "H" ++ Basics.toString x
    Vertical y   -> "V" ++ Basics.toString y

    CubicBeziers c1 c2 p    -> "C" ++ points [ c1, c2, p ]
    CubicBeziersShort c1 p  -> "Q" ++ points [ c1, p ]
    QuadraticBeziers c1 p   -> "Q" ++ points [ c1, p ]
    QuadraticBeziersShort p -> "T" ++ point p

    Arc rx ry xAxisRotation largeArcFlag sweepFlag p ->
      "A" ++ join
        [ Basics.toString rx
        , Basics.toString ry
        , Basics.toString xAxisRotation
        , bool largeArcFlag
        , bool sweepFlag
        , point p
        ]


translate : System -> Command -> Command
translate system command =
  case command of
    Move p       -> Move (toSVG system p)
    Line p       -> Line (toSVG system p)
    Horizontal x -> Horizontal (toSVGX system x)
    Vertical y   -> Vertical (toSVGY system y)

    CubicBeziers c1 c2 p ->
      CubicBeziers
        (toSVG system c1)
        (toSVG system c2)
        (toSVG system p)

    CubicBeziersShort c1 p ->
      CubicBeziersShort
        (toSVG system c1)
        (toSVG system p)

    QuadraticBeziers c1 p ->
      QuadraticBeziers
        (toSVG system c1)
        (toSVG system p)

    QuadraticBeziersShort p ->
      QuadraticBeziersShort
        (toSVG system p)

    Arc rx ry xAxisRotation largeArcFlag sweepFlag p ->
      Arc rx ry xAxisRotation largeArcFlag sweepFlag (toSVG system p)

    Close ->
      Close



-- HELP


join : List String -> String
join commands =
  String.join " " commands


point : Point -> String
point { x, y } =
  Basics.toString x ++ " " ++ Basics.toString y


points : List Point -> String
points points =
  String.join "," (List.map point points)


bool : Bool -> String
bool bool =
  if bool then "1" else "0"

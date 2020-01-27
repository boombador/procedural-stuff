module Procedural.FencePosts exposing
    ( offsetList
    , post
    , postColor
    , posts
    , postsBetweenPoints
    , postsFromPath
    , rectangularPath
    )

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Procedural.Models exposing (Color, Triangle, TriangleMesh)
import Procedural.Primitives exposing (prism, toMesh)


postColor : Color
postColor =
    vec3 0 0 1


post : Vec3 -> List Triangle
post base =
    let
        ( x, y, z ) =
            ( 0.1, 0.5, 0.1 )

        centerY =
            (y / 2) + Vec3.getY base

        center =
            Vec3.setY centerY base
    in
    prism x y z center


posts : List Vec3 -> List Triangle
posts locations =
    locations
        |> List.map post
        |> List.concat


postsFromPath : List Vec3 -> TriangleMesh
postsFromPath points =
    List.map2 Tuple.pair points (offsetList points)
        |> List.map postsBetweenPoints
        |> List.concat
        |> toMesh postColor


offsetList : List Vec3 -> List Vec3
offsetList l =
    case l of
        x :: xs ->
            List.append xs [ x ]

        _ ->
            []


postsBetweenPoints : ( Vec3, Vec3 ) -> List Triangle
postsBetweenPoints ( a, b ) =
    posts (generateIntermediatePoints a b 0.5)



-- Point generator helpers


rectangularPath : Float -> Float -> List Vec3
rectangularPath w l =
    [ vec3 w 0 l
    , vec3 -w 0 l
    , vec3 -w 0 -l
    , vec3 w 0 -l
    ]


generateIntermediatePoints : Vec3 -> Vec3 -> Float -> List Vec3
generateIntermediatePoints a b targetSplit =
    let
        count =
            segmentsFromLength targetSplit (Vec3.distance a b)

        fromS =
            interpolate a b
    in
    sEntriesForCount count
        |> List.map fromS


segmentsFromLength : Float -> Float -> Int
segmentsFromLength minLength distance =
    ceiling (distance / minLength)


interpolate : Vec3 -> Vec3 -> Float -> Vec3
interpolate a b s =
    let
        aToB =
            Vec3.sub b a

        offset =
            Vec3.scale s aToB
    in
    Vec3.add a offset


{-| Calculate a list of values within (0,1) representing the fractional
position of each split point when dividing the unit lenght into the requested
number of segments
-}
sEntriesForCount : Int -> List Float
sEntriesForCount count =
    List.range 1 count
        |> List.map (\i -> toFloat i / toFloat count)

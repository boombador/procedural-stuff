module Procedural.Geometries exposing
    ( groundPlane
    , house
    , posts
    , postsFromPath
    , rectangularPath
    )

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Procedural.Models exposing (TriangleMesh, Tris)
import Procedural.Primitives exposing (cube, prism, quad, toMesh, tri)



-- House


houseColor : Vec3
houseColor =
    vec3 1 1 0


roofColor : Vec3
roofColor =
    vec3 1 0 0


groundColor : Vec3
groundColor =
    vec3 0 1 0


postColor : Vec3
postColor =
    vec3 0 0 1


house : Float -> Float -> Float -> Float -> Vec3 -> TriangleMesh
house width height length roofHeight start =
    let
        ( hw, hh, hl ) =
            ( width / 2
            , height / 2
            , length / 2
            )

        ( center, roofBase, roofTop ) =
            ( hh + Vec3.getY start
            , height + Vec3.getY start
            , height + roofHeight + Vec3.getY start
            )
    in
    List.concat
        [ toMesh houseColor (prism width height length (vec3 0 center 0))
        , toMesh houseColor (roofSides hw hl roofBase roofTop)
        , toMesh roofColor (roof hw hl roofTop roofBase)
        ]


roofSides : Float -> Float -> Float -> Float -> Tris
roofSides hw hl roofBase roofTop =
    List.concat
        [ tri (vec3 hw roofBase hl) (vec3 hw roofBase -hl) (vec3 hw roofTop 0)
        , tri (vec3 -hw roofBase hl) (vec3 -hw roofBase -hl) (vec3 -hw roofTop 0)
        ]


roof : Float -> Float -> Float -> Float -> Tris
roof hw hl roofTop roofBase =
    let
        { roofA, roofB, cornerA, cornerB } =
            { roofA = vec3 hw roofTop 0
            , roofB = vec3 -hw roofTop 0
            , cornerA = vec3 hw roofBase hl
            , cornerB = vec3 hw roofBase -hl
            }

        ( roofLine, downSlantA, downSlantB ) =
            ( Vec3.sub roofB roofA
            , Vec3.sub cornerA roofA
            , Vec3.sub cornerB roofA
            )
    in
    List.concat
        [ quad roofA roofLine downSlantA
        , quad roofA roofLine downSlantB
        ]



-- Posts


post : Vec3 -> Tris
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


posts : List Vec3 -> Tris
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


postsBetweenPoints : ( Vec3, Vec3 ) -> Tris
postsBetweenPoints ( a, b ) =
    posts (generateIntermediatePoints a b 0.5)



-- Terrain and Ground


type alias Terrain =
    { xSegments : Int
    , zSegments : Int
    , xDelta : Float
    , zDelta : Float
    , heightList : List Float
    }


groundPlane : Float -> TriangleMesh
groundPlane toEdge =
    let
        ( x, z, offset ) =
            ( Vec3.scale toEdge Vec3.i
            , Vec3.scale toEdge Vec3.k
            , -(toEdge / 2)
            )
    in
    toMesh groundColor (quad (vec3 offset 0 offset) x z)


terrain : Int -> Int -> Float -> Float -> List Float -> Terrain
terrain xSegments zSegments xDelta zDelta heightList =
    { xSegments = xSegments
    , zSegments = zSegments
    , xDelta = xDelta
    , zDelta = zDelta
    , heightList = heightList
    }


remainder : Int -> Int -> Int
remainder a b =
    -- no idea if this is doing what the old `rem` function did
    let
        quotient =
            a // b

        leastMultiple =
            quotient * b
    in
    a - leastMultiple


{-| This is making the plane go over in the wrong area, but otherwise is
looking good
-}
terrainToMesh : Terrain -> Procedural.Models.Tris
terrainToMesh t =
    let
        { xSegments, zSegments, xDelta, zDelta, heightList } =
            t

        withIndices : Int -> Float -> ( Int, Int, Float )
        withIndices idx h =
            ( remainder idx xSegments, idx // zSegments, h )

        quadFunc : ( Int, Int, Float ) -> Procedural.Models.Tris
        quadFunc =
            toQuad xDelta zDelta
    in
    heightList
        |> List.indexedMap withIndices
        |> List.map quadFunc
        |> List.concat


toQuad : Float -> Float -> ( Int, Int, Float ) -> Procedural.Models.Tris
toQuad dx dz triplet =
    let
        ( ix, iz, h ) =
            triplet

        ( xSide, zSide ) =
            ( toFloat ix * dx, toFloat iz * dz )

        start =
            vec3 xSide h zSide
    in
    quad start (Vec3.scale xSide Vec3.i) (Vec3.scale zSide Vec3.k)



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

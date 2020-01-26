module Procedural.Primitives exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Procedural.Models exposing (Color, TriangleMesh, Tris, Vertex)


toMesh : Color -> Tris -> TriangleMesh
toMesh color verts =
    verts
        |> List.map
            (\( x, y, z ) ->
                ( Vertex x color
                , Vertex y color
                , Vertex z color
                )
            )


tri : Vec3 -> Vec3 -> Vec3 -> Tris
tri x y z =
    [ ( x, y, z ) ]


quad : Vec3 -> Vec3 -> Vec3 -> Tris
quad corner x y =
    let
        { a, b, c, d } =
            { a = corner
            , b = Vec3.add corner x
            , c = Vec3.add corner (Vec3.add x y)
            , d = Vec3.add corner y
            }
    in
    List.concat
        [ tri a b c
        , tri a c d
        ]


cube : Float -> Vec3 -> Tris
cube s =
    prism s s s


prism : Float -> Float -> Float -> Vec3 -> Tris
prism w h l center =
    let
        ( x, y, z ) =
            ( Vec3.scale w Vec3.i
            , Vec3.scale h Vec3.j
            , Vec3.scale l Vec3.k
            )

        ( negX, negY, negZ ) =
            ( Vec3.negate x
            , Vec3.negate y
            , Vec3.negate z
            )

        nearCorner =
            List.foldl (\v a -> Vec3.sub a (Vec3.scale 0.5 v)) center [ x, y, z ]

        farCorner =
            List.foldl Vec3.add nearCorner [ x, y, z ]
    in
    List.concat
        [ quad nearCorner x y
        , quad nearCorner x z
        , quad nearCorner y z
        , quad farCorner negX negY
        , quad farCorner negX negZ
        , quad farCorner negY negZ
        ]

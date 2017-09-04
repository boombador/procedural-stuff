module Procedural.Main exposing (..)

import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Procedural.Models exposing (Vertex, TriangleMesh)
import Procedural.Geometries exposing (house, groundPlane, postsFromPath, rectangularPath)


sampleTriangles : TriangleMesh
sampleTriangles =
    let
        ( width, height, length, roofHeight, origin ) =
            ( 1, 1, 1, 0.5, vec3 0 0 0 )
    in
        List.concat
            [ house width height length roofHeight origin
            , postsFromPath (rectangularPath width length)
            , groundPlane 10000
            ]

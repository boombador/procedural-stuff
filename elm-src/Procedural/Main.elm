module Procedural.Main exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Procedural.Geometries exposing (groundPlane, house, postsFromPath, rectangularPath)
import Procedural.Models exposing (TriangleMesh, Vertex)


sampleTriangles : TriangleMesh
sampleTriangles =
    let
        width =
            1

        height =
            1

        length =
            1

        roofHeight =
            0.5

        origin =
            vec3 0 0 0
    in
    List.concat
        [ house width height length roofHeight origin
        , postsFromPath (rectangularPath width length)
        , groundPlane 10000
        ]

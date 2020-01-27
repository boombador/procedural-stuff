module Procedural.Main exposing (..)

import Math.Vector3 as Vec3 exposing (vec3)
import Procedural.FencePosts exposing (postsFromPath, rectangularPath)
import Procedural.House exposing (house)
import Procedural.Models exposing (TriangleMesh, Vertex)
import Procedural.Terrain exposing (groundPlane)
import Procedural.Wire exposing (wire)


sampleScene : TriangleMesh
sampleScene =
    -- wireTest
    houseScene


wireTest : TriangleMesh
wireTest =
    List.concat
        [ wire {}
        ]


houseScene : TriangleMesh
houseScene =
    let
        baseWidth =
            1

        baseLength =
            1
    in
    List.concat
        [ house
            { width = baseWidth
            , height = 1.0
            , length = baseLength
            , roofHeight = 0.5
            , origin = vec3 0 0 0
            }
        , postsFromPath (rectangularPath baseWidth baseLength)
        , groundPlane 10000
        ]

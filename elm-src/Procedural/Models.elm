module Procedural.Models exposing (..)

import Math.Vector3 as Vec3 exposing (vec3, Vec3)


type alias Color =
    Vec3


type alias Tris =
    List ( Vec3, Vec3, Vec3 )


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


type alias TriangleMesh =
    List ( Vertex, Vertex, Vertex )

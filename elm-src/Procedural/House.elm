module Procedural.House exposing
    ( HouseArgs
    , house
    , houseColor
    , roof
    , roofColor
    , roofSides
    )

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Procedural.Models exposing (Color, Triangle, TriangleMesh, Vertex)
import Procedural.Primitives exposing (prism, quad, toMesh, tri)


houseColor : Color
houseColor =
    vec3 1 1 0


roofColor : Color
roofColor =
    vec3 1 0 0


type alias HouseArgs =
    { width : Float
    , height : Float
    , length : Float
    , roofHeight : Float
    , origin : Vec3
    }


house : HouseArgs -> TriangleMesh
house { width, height, length, roofHeight, origin } =
    let
        ( hw, hh, hl ) =
            ( width / 2
            , height / 2
            , length / 2
            )

        ( center, roofBase, roofTop ) =
            ( hh + Vec3.getY origin
            , height + Vec3.getY origin
            , height + roofHeight + Vec3.getY origin
            )
    in
    List.concat
        [ toMesh houseColor (prism width height length (vec3 0 center 0))
        , toMesh houseColor (roofSides hw hl roofBase roofTop)
        , toMesh roofColor (roof hw hl roofTop roofBase)
        ]


roofSides : Float -> Float -> Float -> Float -> List Triangle
roofSides hw hl roofBase roofTop =
    List.concat
        [ tri (vec3 hw roofBase hl) (vec3 hw roofBase -hl) (vec3 hw roofTop 0)
        , tri (vec3 -hw roofBase hl) (vec3 -hw roofBase -hl) (vec3 -hw roofTop 0)
        ]


roof : Float -> Float -> Float -> Float -> List Triangle
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

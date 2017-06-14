module Procedural exposing (..)

import Math.Vector3 as Vec3 exposing (vec3, Vec3)


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


tri : Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
tri x y z =
    [ ( Vertex x (vec3 1 0 0)
      , Vertex y (vec3 0 1 0)
      , Vertex z (vec3 0 0 1)
      )
    ]


quad : Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
quad corner x y =
    let
        ( a, b, c, d ) =
            ( corner
            , Vec3.add corner x
            , Vec3.add corner (Vec3.add x y)
            , Vec3.add corner y
            )
    in
        List.concat
            [ tri a b c
            , tri a c d
            ]


cube : Float -> Vec3 -> List ( Vertex, Vertex, Vertex )
cube s =
    prism s s s


prism : Float -> Float -> Float -> Vec3 -> List ( Vertex, Vertex, Vertex )
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


posts : List Vec3 -> List ( Vertex, Vertex, Vertex )
posts locations =
    locations
        |> List.map post
        |> List.concat


postsBetweenEndpoints : Int -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
postsBetweenEndpoints count a b =
    let
        distance =
            Vec3.distance a b

        split : Int
        split =
            floor (distance / toFloat count)
    in
        []


interpolate : Vec3 -> Vec3 -> Float -> Vec3
interpolate a b s =
    let
        aToB =
            Vec3.sub b a

        offset =
            Vec3.scale s aToB
    in
        Vec3.add a offset


segmentsFromLength : Float -> Float -> Int
segmentsFromLength minLength distance =
    ceiling (distance / minLength)


{-| Calculate a list of values within (0,1) representing the fractional
position of each split point when dividing the unit lenght into the requested
number of segments
-}
sEntriesForCount : Int -> List Float
sEntriesForCount count =
    List.range 1 (count - 1)
        |> List.map (\i -> (toFloat i / toFloat count))


intermediatePoints : Float -> Vec3 -> Vec3 -> List Vec3
intermediatePoints targetSplit a b =
    let
        count =
            segmentsFromLength targetSplit (Vec3.distance a b)

        fromS =
            interpolate a b
    in
        sEntriesForCount count
            |> List.map fromS


postsBetweenPoints : ( Vec3, Vec3 ) -> List ( Vertex, Vertex, Vertex )
postsBetweenPoints ( a, b ) =
    List.concat
        [ posts (intermediatePoints 0.5 a b)
        ]


fromPostPath : List Vec3 -> List ( Vertex, Vertex, Vertex )
fromPostPath points =
    let
        offsetPoints =
            toOffsetList points

        endpointPairs =
            List.map2 (,) points offsetPoints

        innerPosts =
            List.map postsBetweenPoints endpointPairs
                |> List.concat

        --intermediate =
        --posts (intermediatePoints 0.5 a b)
    in
        List.concat
            [ posts points
            , innerPosts
            ]


roof : Float -> Float -> Float -> Float -> List ( Vertex, Vertex, Vertex )
roof hw hl roofTop roofBase =
    let
        ( roofA, roofB, cornerA, cornerB ) =
            ( vec3 hw roofTop 0
            , vec3 -hw roofTop 0
            , vec3 hw roofBase hl
            , vec3 hw roofBase -hl
            )

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


roofSides : Float -> Float -> Float -> Float -> List ( Vertex, Vertex, Vertex )
roofSides hw hl roofBase roofTop =
    List.concat
        [ tri (vec3 hw roofBase hl) (vec3 hw roofBase -hl) (vec3 hw roofTop 0)
        , tri (vec3 -hw roofBase hl) (vec3 -hw roofBase -hl) (vec3 -hw roofTop 0)
        ]


post : Vec3 -> List ( Vertex, Vertex, Vertex )
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


type alias HouseOpts =
    { center : Float
    , height : Float
    , hh : Float
    , hl : Float
    , hw : Float
    , length : Float
    , roofBase : Float
    , roofHeight : Float
    , roofTop : Float
    , start : Vec3
    , width : Float
    }


houseOpts : Float -> Float -> Float -> Float -> Vec3 -> HouseOpts
houseOpts width height length roofHeight start =
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
        { width = width
        , height = height
        , length = length
        , roofHeight = roofHeight
        , start = start
        , hw = hw
        , hh = hh
        , hl = hl
        , center = center
        , roofBase = roofBase
        , roofTop = roofTop
        }


house : Float -> Float -> Float -> Float -> Vec3 -> List ( Vertex, Vertex, Vertex )
house h w l r start =
    let
        { width, height, length, roofHeight, hw, hh, hl, center, roofBase, roofTop } =
            houseOpts h w l r start
    in
        List.concat
            [ prism width height length (vec3 0 center 0)
            , roofSides hw hl roofBase roofTop
            , roof hw hl roofTop roofBase
            , fromPostPath (postPathSquare w l)
            ]


getPair : List Vec3 -> ( List Vec3, List Vec3 )
getPair l =
    ( l, toOffsetList l )


toOffsetList : List Vec3 -> List Vec3
toOffsetList l =
    let
        initial =
            case List.head l of
                Just v ->
                    [ v ]

                Nothing ->
                    []

        rest =
            case List.tail l of
                Just l ->
                    l

                Nothing ->
                    []
    in
        List.concat [ rest, initial ]



-- sample data


samplePrism : List ( Vertex, Vertex, Vertex )
samplePrism =
    prism 0.5 3 0.5 (vec3 0 0 0)


postPathEdge : Float -> Float -> ( Vec3, Vec3 )
postPathEdge w l =
    ( (vec3 w 0 l)
    , (vec3 -w 0 l)
    )


postPathSquare : Float -> Float -> List Vec3
postPathSquare w l =
    [ (vec3 w 0 l)
    , (vec3 -w 0 l)
    , (vec3 -w 0 -l)
    , (vec3 w 0 -l)
    ]

var WIDTH = 400,
    HEIGHT = 400;

var m_Width = 1.0;
var m_Length = 1.0;
var m_Height = 3.0;
var m_SegmentCount = 10;

var m_RoofHeight = 0.5;
var m_RoofOverhangSide = 0.2;
var m_RoofOverhangFront = 0.1;

var m_PostHeight = 0.8;
var m_PostWidth = 0.2;
var m_SectionCount = 10;
var m_DistBetweenPosts = 1;
var m_CrossPieceHeight = 0.2;
var m_CrossPieceWidth = 0.1;
var m_CrossPieceY = 0.4;
var m_PostHeightVariation = 0.3;
var m_CrossPieceYVariation = 0.2;

var globalRight = new THREE.Vector3(1, 0, 0);
var globalUp = new THREE.Vector3(0, 1, 0);
var globalForward = new THREE.Vector3(0, 0, 1);

var addQuad = function (geo, offset) {
    console.log("generating mesh with offset:", offset);

    geo.vertices.push(
        (new THREE.Vector3( 0,  0, 0 )).add(offset),
        (new THREE.Vector3( m_Width,  0, 0 )).add(offset),
        (new THREE.Vector3( m_Width, m_Length, 0 )).add(offset),
        (new THREE.Vector3( 0, m_Length, 0 )).add(offset)
    );
    var baseIndex = geo.vertices.length - 4;
    geo.faces.push( new THREE.Face3( baseIndex, baseIndex+1, baseIndex+2 ) );
    geo.faces.push( new THREE.Face3( baseIndex, baseIndex+2, baseIndex+3 ) );
}

var addQuadForGrid = function(geo, pos, buildTriangles, vertsPerRow) {
    geo.vertices.push( pos );

    if (buildTriangles) {
        var baseIndex = geo.vertices.length - 1;

        var index0 = baseIndex;
        var index1 = baseIndex - 1;
        var index2 = baseIndex - vertsPerRow;
        var index3 = baseIndex - vertsPerRow - 1;

        geo.faces.push( new THREE.Face3(index0, index1, index2));
        geo.faces.push( new THREE.Face3(index2, index1, index3));
    }
}

var buildDirectedQuad = function(geo, offset, widthDir, lengthDir) {
    var v0 = offset.clone();
    var v1 = offset.clone().add(widthDir);
    var v2 = offset.clone().add(lengthDir);
    var v3 = offset.clone().add(lengthDir).add(widthDir);

    geo.vertices.push(v0);
    geo.vertices.push(v1);
    geo.vertices.push(v2);
    geo.vertices.push(v3);

    var baseIndex = geo.vertices.length - 4;
    geo.faces.push(new THREE.Face3(baseIndex, baseIndex + 2, baseIndex + 1));
    geo.faces.push(new THREE.Face3(baseIndex + 1, baseIndex + 2, baseIndex + 3));
}

var createPrism = (function(){

    var v1 = new THREE.Vector3(); 
    var v2 = new THREE.Vector3(); 
    var v3 = new THREE.Vector3(); 
    var nearCorner = new THREE.Vector3();
    var farCorner = new THREE.Vector3().addVectors(v1, v2).add(v3);

    return function(geo, upDir, rightDir, forwardDir) {
        v1.copy( upDir );
        v2.copy( rightDir );
        v3.copy( forwardDir );

        nearCorner.set(0, 0, 0);
        farCorner.addVectors(v1, v2).add(v3);

        buildDirectedQuad(geo, nearCorner, v3, v2);
        buildDirectedQuad(geo, nearCorner, v2, v1);
        buildDirectedQuad(geo, nearCorner, v1, v3);

        v2.multiplyScalar(-1);
        v3.multiplyScalar(-1);
        v1.multiplyScalar(-1);

        buildDirectedQuad(geo, farCorner, v2, v3);
        buildDirectedQuad(geo, farCorner, v1, v2);
        buildDirectedQuad(geo, farCorner, v3, v1);
    };
})();

var addTri = function (geo, v1, v2, v3) {
    geo.vertices.push( v1, v2, v3 );
    var baseIndex = geo.vertices.length - 3;
    geo.faces.push( new THREE.Face3( baseIndex, baseIndex+1, baseIndex+2 ) );
}

var createHouse = (function(){

    var vUp = new THREE.Vector3(); 
    var vRight = new THREE.Vector3(); 
    var vForward = new THREE.Vector3(); 
    var nearCorner = new THREE.Vector3();
    var farCorner = new THREE.Vector3(); // .addVectors(v1, v2).add(v3);
    var pivotOffset = new THREE.Vector3(); // (rightDir + forwardDir) * 0.5f;
    var roofPeak = new THREE.Vector3();
    var wallTopLeft = new THREE.Vector3();
    var wallTopRight = new THREE.Vector3();

    return function(geo, upDir, rightDir, forwardDir) {
        vUp.copy( upDir );
        vRight.copy( rightDir );
        vForward.copy( forwardDir );

        nearCorner.set(0, 0, 0);
        farCorner.addVectors(vUp, vRight).add(vForward);

        // set object origin to base of house
        pivotOffset.addVectors(vRight, vForward).multiplyScalar(0.5);
        farCorner.sub(pivotOffset);
        nearCorner.sub(pivotOffset);

        // build horizontal walls
        buildDirectedQuad(geo, nearCorner, vRight, vUp);
        buildDirectedQuad(geo, nearCorner, vUp, vForward);
        vRight.multiplyScalar(-1);
        vForward.multiplyScalar(-1);
        vUp.multiplyScalar(-1);
        buildDirectedQuad(geo, farCorner, vUp, vRight);
        buildDirectedQuad(geo, farCorner, vForward, vUp);
        vRight.multiplyScalar(-1);
        vForward.multiplyScalar(-1);
        vUp.multiplyScalar(-1);

        // roof
        roofPeak.set(0, 0, 0).addScaledVector(globalUp, vUp.length() + m_RoofHeight).addScaledVector(vRight, 0.5).sub(pivotOffset);
        wallTopLeft.subVectors(vUp, pivotOffset);
        wallTopRight.addVectors(vUp, vRight).sub(pivotOffset);

        addTri(geo, wallTopLeft.clone(), roofPeak.clone(), wallTopRight.clone());
        roofPeak.add(vForward);
        wallTopLeft.add(vForward);
        wallTopRight.add(vForward);
        addTri(geo, wallTopLeft.clone(), wallTopRight.clone(), roofPeak.clone());

        roofPeak.sub(vForward);
        wallTopLeft.sub(vForward);
        wallTopRight.sub(vForward);

        var dirFromPeakLeft = new THREE.Vector3().subVectors(wallTopLeft, roofPeak);
        var dirFromPeakRight = new THREE.Vector3().subVectors(wallTopRight, roofPeak);

        var normDirFromPeakLeft = dirFromPeakLeft.clone().normalize();
        var normDirFromPeakRight = dirFromPeakRight.clone().normalize();
        dirFromPeakLeft.addScaledVector(normDirFromPeakLeft, m_RoofOverhangSide);
        dirFromPeakRight.addScaledVector(normDirFromPeakRight, m_RoofOverhangSide);

        roofPeak.addScaledVector( globalForward, -m_RoofOverhangFront);
        vForward.addScaledVector( globalForward, m_RoofOverhangFront * 2);

        buildDirectedQuad(geo, roofPeak, vForward, dirFromPeakLeft);
        buildDirectedQuad(geo, roofPeak, dirFromPeakRight, vForward);
        buildDirectedQuad(geo, roofPeak, dirFromPeakLeft, vForward);
        buildDirectedQuad(geo, roofPeak, vForward, dirFromPeakRight);
    };
})();

var buildPost = function(geo, position) {

    var postHeight = m_PostHeight + Math.random()*m_PostHeightVariation;
    var upDir = new THREE.Vector3().addScaledVector(globalUp, postHeight);
    var rightDir = new THREE.Vector3().addScaledVector(globalRight, m_PostWidth);
    var forwardDir = new THREE.Vector3().addScaledVector(globalForward, m_PostWidth);

    var farCorner = new THREE.Vector3().addVectors(upDir, rightDir).add(forwardDir).add(position);
    var nearCorner = new THREE.Vector3().copy(position);

    //shift pivot to centre-bottom:
    var pivotOffset = new THREE.Vector3().addVectors(rightDir, forwardDir).multiplyScalar(0.5);
    farCorner.sub( pivotOffset );
    nearCorner.sub( pivotOffset );

    buildDirectedQuad(geo, nearCorner, rightDir, upDir);
    buildDirectedQuad(geo, nearCorner, upDir, forwardDir);

    upDir.multiplyScalar(-1);
    rightDir.multiplyScalar(-1);
    forwardDir.multiplyScalar(-1);

    buildDirectedQuad(geo, farCorner, rightDir, forwardDir);
    buildDirectedQuad(geo, farCorner, upDir, rightDir);
    buildDirectedQuad(geo, farCorner, forwardDir, upDir);
};

var createConnectedGrid = function(geo){
    var i, j, x, y;

    for (i = 0; i <= m_SegmentCount; i++) {
        y = m_Length * i;

        for (j = 0; j <= m_SegmentCount; j++) {
            x = m_Width * j;

            var offset = new THREE.Vector3(x, y, Math.random(m_Height));
            var buildTriangles = i > 0 && j > 0;
            addQuadForGrid(geo, offset, buildTriangles, m_SegmentCount + 1);
        }
    }
}

var createDisconnectedGrid = function(geo) {
    var i, j, x, y;

    for (i = 0; i < m_SegmentCount; i++) {
        y = m_Length * i;

        for (j = 0; j < m_SegmentCount; j++) {
            x = m_Width * j;

            var offset = new THREE.Vector3(x, y, Math.random(m_Height) );
            addQuad(geo, offset);
        }
    }
};

var buildCrossPiece = function(geo, start) {
    var upDir = new THREE.Vector3().addScaledVector(globalUp, m_CrossPieceHeight);
    var rightDir = new THREE.Vector3().addScaledVector(globalRight, m_DistBetweenPosts);
    var forwardDir = new THREE.Vector3().addScaledVector(globalForward, m_CrossPieceWidth);

    var farCorner = new THREE.Vector3().addVectors(upDir, rightDir).add(forwardDir).add(start);
    var nearCorner = new THREE.Vector3().copy(start);

    buildDirectedQuad(geo, nearCorner, forwardDir, rightDir);
    buildDirectedQuad(geo, nearCorner, rightDir, upDir);
    buildDirectedQuad(geo, nearCorner, upDir, forwardDir);

    upDir.multiplyScalar(-1);
    rightDir.multiplyScalar(-1);
    forwardDir.multiplyScalar(-1);

    buildDirectedQuad(geo, farCorner, rightDir, forwardDir);
    buildDirectedQuad(geo, farCorner, upDir, rightDir);
    buildDirectedQuad(geo, farCorner, forwardDir, upDir);
}


var prevCrossPosition = new THREE.Vector3(0, 0, 0);

var createFence = function(geo) {
    for (var i = 0; i <= m_SectionCount; i++) {
        var offset = new THREE.Vector3().addScaledVector( globalRight, m_DistBetweenPosts * i);
        buildPost(geo, offset);

        // offset now used for cross piece
        offset.addScaledVector(globalForward, m_PostWidth * 0.5);

        var randomYStart = m_CrossPieceY + Math.random() * m_CrossPieceYVariation;
        var randomYEnd = m_CrossPieceY + Math.random() * m_CrossPieceYVariation;

        var crossYOffsetStart = new THREE.Vector3().addScaledVector(globalUp, randomYStart).add(prevCrossPosition);
        var crossYOffsetEnd = new THREE.Vector3().addScaledVector(globalUp, randomYEnd).add(offset);

        prevCrossPosition.copy(offset);
        offset.addScaledVector(globalUp, m_CrossPieceY);

        if (i != 0) {
            buildCrossPiece(geo, crossYOffsetStart, crossYOffsetEnd);
        }
    }
};

var createGeometry = function() {
    var geometry = new THREE.Geometry();

    //createDisconnectedGrid(geometry);
    //createConnectedGrid(geometry);
    //createHouse(geometry, upDir, rightDir, forwardDir);

    createFence(geometry);

    geometry.computeBoundingSphere();
    geometry.computeFaceNormals();
    geometry.computeVertexNormals();
    return geometry;
}

var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera( 75, WIDTH/HEIGHT, 0.1, 1000 );

var renderer = new THREE.WebGLRenderer();
renderer.setSize( WIDTH, HEIGHT );
document.body.appendChild( renderer.domElement );

var geometry = createGeometry();
var material = new THREE.MeshNormalMaterial( );
// material.side = THREE.DoubleSide;
var mesh = new THREE.Mesh( geometry, material );
scene.add( mesh );
// soft white light

var axisHelper = new THREE.AxisHelper( 5 );
scene.add( axisHelper );

//var halfWayX = (m_SegmentCount / 2) * m_Width;
//var halfWayY = (m_SegmentCount / 2) * m_Length;
//camera.position.set(halfWayX, -halfWayY, 5);
//var objCenter = new THREE.Vector3(halfWayX, halfWayY, 0)

camera.position.set(3, 4, 4);
var objCenter = new THREE.Vector3(0, 0, 0)
var controls = new THREE.OrbitControls( camera, renderer.domElement, {
    target: objCenter
});


var render = function () {
    requestAnimationFrame( render );
    renderer.render(scene, camera);
    controls.update();
};

render();


var THREE = require('three');

var OrbitControls = require('three-orbit-controls')(THREE)

var WIDTH = 400,
    HEIGHT = 400;

var m_Width = 3.0;
var m_Length = 3.0;
var m_Height = 2.0;
var m_SegmentCount = 20;

var m_RoofHeight = 0.5;
var m_RoofOverhangSide = 0.2;
var m_RoofOverhangFront = 0.1;

var m_PostHeight = 0.8;
var m_PostWidth = 0.2;
var m_SectionCount = 10;
var m_IdealPostSeparation = 1; // ideal distance, not necessarily used
var m_CrossPieceHeight = 0.2;
var m_CrossPieceWidth = 0.1;
var m_CrossPieceY = 0.4;
var m_PostHeightVariation = 0.3;
var m_CrossPieceYVariation = 0.2;
var m_PostTiltAngle = 0.3;

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

        geo.faces.push( new THREE.Face3(index0, index2, index1));
        geo.faces.push( new THREE.Face3(index2, index3, index1));
    }
}

var buildPost = function(geo, position, rotation) {

    var postHeight = m_PostHeight + Math.random()*m_PostHeightVariation;

    var upDir = globalUp.clone().applyQuaternion(rotation);
    var rightDir = globalRight.clone().applyQuaternion(rotation);
    var forwardDir = globalForward.clone().applyQuaternion(rotation);

    upDir.multiplyScalar( postHeight);
    rightDir.multiplyScalar(m_PostWidth);
    forwardDir.multiplyScalar(m_PostWidth);

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

// array storing height samples of x-z plane
// row major encoding
var terrain = (function(){
    var that = {};
    that.samples = [];

    var init = function(xSections, zSections) {
        this.xCount = xSections;
        this.zCount = zSections;
    };

    var getSample = function(x, z) {
        var index = this.xCount * z + x
        return that.samples[index]
    }

    var interpolate = function(xCoord, zCoord) {
        var normX = xCoord / m_Width;
        var normZ = zCoord / m_Length;

        var minX = Math.floor(normX);
        var maxX = Math.ceil(normX);
        var minZ = Math.floor(normZ);
        var maxZ = Math.ceil(normZ);

        var height0 = this.getSample(minX, minZ);
        var height1 = this.getSample(maxX, minZ);
        var height2 = this.getSample(minX, maxZ);
        var height3 = this.getSample(maxX, maxZ);

        var lowZ = (normX - minX) * (height1 - height0) + height0;
        var highZ = (normX - minX) * (height3 - height2) + height2;
        var estimate = (normZ - minZ) * (highZ - lowZ) + lowZ;
        return estimate;
    };

    that.init = init;
    that.interpolate = interpolate;
    that.getSample = getSample;
    return that;
})();

var createConnectedGrid = function(geo){
    var i, j, x, y;

    terrain.init(m_SegmentCount, m_SegmentCount);

    for (i = 0; i <= m_SegmentCount; i++) {
        for (j = 0; j <= m_SegmentCount; j++) {
            var randomHeight = Math.random(m_Height);
            terrain.samples.push(randomHeight);
        }
    }

    for (i = 0; i <= m_SegmentCount; i++) {
        y = m_Length * i;

        for (j = 0; j <= m_SegmentCount; j++) {
            x = m_Width * j;

            var storedHeight = terrain.getSample(j, i);
            var offset = new THREE.Vector3(x, storedHeight, y);
            var buildTriangles = i > 0 && j > 0;
            addQuadForGrid(geo, offset, buildTriangles, m_SegmentCount + 1);
        }
    }
};

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

var buildCrossPiece = function(geo, start, end) {

    var quat = new THREE.Quaternion();
    var vTo = new THREE.Vector3().subVectors(end, start);
    quat.setFromUnitVectors(globalRight, vTo);

    var upDir = globalUp.clone().applyQuaternion(quat);
    var rightDir = globalRight.clone().applyQuaternion(quat);
    var forwardDir = globalForward.clone().applyQuaternion(quat);

    upDir.multiplyScalar( m_CrossPieceHeight);
    rightDir.multiplyScalar( vTo.length() );
    forwardDir.multiplyScalar( m_CrossPieceWidth);

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
var prevRotation = new THREE.Quaternion();;

var createFence = function(geo, opts) {
    opts = opts || {};
    opts.length = opts.length || 30;

    var sectionCount = Math.floor( opts.length / m_IdealPostSeparation );
    var actualDistBetweenPosts = opts.length / sectionCount;

    opts.start = opts.start || new THREE.Vector3();
    opts.direction = opts.direction || globalRight.clone(); // assumed to be normalized

    var offset = new THREE.Vector3();

    for (var i = 0; i <= sectionCount; i++) {
        offset.copy(opts.direction).multiplyScalar(actualDistBetweenPosts * i).add(opts.start);

        var xAngle = (Math.random() * 2 - 1) * m_PostTiltAngle;
        var zAngle = (Math.random() * 2 - 1) * m_PostTiltAngle;

        var rotation = new THREE.Quaternion();
        var euler = new THREE.Euler( xAngle, 0, zAngle, 'XYZ' );
        rotation.setFromEuler(euler);

        // height offset
        offset.y += terrain.interpolate(offset.x, offset.z)

        buildPost(geo, offset, rotation);

        // offset now used for cross piece
        offset.addScaledVector(globalForward, m_PostWidth * 0.5);

        var randomYStart = m_CrossPieceY + Math.random() * m_CrossPieceYVariation;
        var randomYEnd = m_CrossPieceY + Math.random() * m_CrossPieceYVariation;

        var crossYOffsetStart = globalUp.clone().applyQuaternion(prevRotation).multiplyScalar(randomYStart);
        var crossYOffsetEnd = globalUp.clone().applyQuaternion(rotation).multiplyScalar(randomYEnd);
        crossYOffsetStart.add(prevCrossPosition);
        crossYOffsetEnd.add(offset);

        prevCrossPosition.copy(offset);
        prevRotation.copy(rotation);

        if (i != 0) {
            buildCrossPiece(geo, crossYOffsetStart, crossYOffsetEnd);
        }
    }
};

/* sequentially stored x,z coordinates
 * coords = [
 *      20, 20,
 *      40, 30,
 *      40, 40
 * ]
 */
var createFencePath = function(geo, coords) {
    if (!coords) {
        return;
    }

    var delta = new THREE.Vector3();
    for (var i = 1; i < coords.length; i++) {
        delta.subVectors(coords[i], coords[i-1]);
        var length = delta.length();
        delta.normalize();

        createFence(geo, {
            start: coords[i-1],
            direction: delta,
            length: length
        });
    }

};

var createGeometry = function() {
    var geometry = new THREE.Geometry();

    var rotation = new THREE.Quaternion();
    rotation.setFromUnitVectors(globalRight, globalForward);

    //createConnectedGrid(geometry);
    //createFencePath(geometry, [
        //new THREE.Vector3( 20, 0, 20 ),
        //new THREE.Vector3( 40, 0, 20 ),
        //new THREE.Vector3( 40, 0, 40 ),
        //new THREE.Vector3( 20, 0, 40 ),
        //new THREE.Vector3( 20, 0, 20 )
    //]);

    geometry.computeBoundingBox();
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
var mesh = new THREE.Mesh( geometry, material );
scene.add( mesh );

var geoCenter = new THREE.Vector3();
geoCenter.addVectors(geometry.boundingBox.min, geometry.boundingBox.max).multiplyScalar(0.5);

var axisHelper = new THREE.AxisHelper( 5 );
scene.add( axisHelper );

camera.position.set(3, 4, 4);
// var objCenter = new THREE.Vector3(0, 0, 0)
var controls = new OrbitControls( camera, renderer.domElement, {
    target: geoCenter
});


var render = function () {
    requestAnimationFrame( render );
    renderer.render(scene, camera);
    controls.update();
};

export default render;


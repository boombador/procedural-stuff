var WIDTH = 400,
    HEIGHT = 400;

var m_Width = 1.0;
var m_Length = 1.0;
var m_Height = 3.0;
var m_SegmentCount = 10;

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

var createGeometry = function() {
    var geometry = new THREE.Geometry();

    // createDisconnectedGrid(geometry);
    createConnectedGrid(geometry);
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
var mesh = new THREE.Mesh( geometry, material );
scene.add( mesh );
// soft white light

var axisHelper = new THREE.AxisHelper( 5 );
scene.add( axisHelper );

var halfWayX = (m_SegmentCount / 2) * m_Width;
var halfWayY = (m_SegmentCount / 2) * m_Length;

camera.position.set(halfWayX, -halfWayY, 5);
var objCenter = new THREE.Vector3(halfWayX, halfWayY, 0)
var controls = new THREE.OrbitControls( camera, renderer.domElement, {
    target: objCenter
});


var render = function () {
    requestAnimationFrame( render );
    renderer.render(scene, camera);
    controls.update();
};

render();


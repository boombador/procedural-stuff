'use strict';

import render from './procedural.js';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

const Elm = require('../elm-src/Main.elm');

const mountNode = document.createElement('div');
document.body.appendChild(mountNode);
var app = Elm.Main.embed(mountNode);

render();

// https://www.elm-tutorial.org/en/04-starting/04-webpack-2.html
// https://guide.elm-lang.org/interop/javascript.html

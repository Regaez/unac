// pull in desired CSS/SASS files
require( './scss/import.scss' );

// inject bundled Elm app into div#main
var Elm = require( './elm/App' );
Elm.App.embed( document.getElementById( 'main' ) );
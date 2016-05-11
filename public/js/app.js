'use strict';
/*jslint browser: true*/
/*global $, jQuery, alert, utils, api, desktop, mobile*/

function init() {
  var canvas = document.getElementById("pad");
  var buttons = {
    cleanAll: document.getElementById("cleanAll"),
    cleanLast: document.getElementById("cleanLast"),
    save: document.getElementById("save")
  };
  if(canvas.getContext){
    if(screen.width <= 800){
      mobile(canvas, buttons);
    } else {
      desktop(canvas, buttons);
    }
  } else {
    alert("Your browser does not support canvas!");
  }
}
//$( document ).ready(init);
document.addEventListener( "DOMContentLoaded", function(){
  // setup a new canvas for drawing wait for device init
  
  setTimeout(function(){
    init();
  }, 500);
}, false );

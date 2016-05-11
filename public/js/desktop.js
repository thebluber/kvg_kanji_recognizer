'use strict';
/*jslint browser: true*/
/*global $, jQuery, alert, utils, api, _*/

var desktop = function(canvas, buttons) {
  var strokes = [];
  var drawing = false;
  var ctx = canvas.getContext("2d");

  //setup canvas
  canvas.width = 300;
  canvas.height = 300;
  ctx = canvas.getContext("2d");
  ctx.strokeStyle = "#df4b26";
  ctx.lineJoin = "round";
  ctx.lineCap = "round";
  ctx.lineWidth = 3;

  window.addEventListener("save", function(e){ utils.saveSample(e.detail, strokes); }, false);

  //helper function
  function addPoint2Stroke(x, y) {
    strokes[strokes.length - 1].push([x, y]);
  }

  //api callbacks
  function errorCallback(msg) {
    console.log(msg);
  }

  function successCallback(results) {
    utils.renderResults(results.scores);
    utils.renderTimer(results.time);
  }

  //debounce sending strokes
  function sendStrokes() {
    api.getScores(strokes, 12, successCallback, errorCallback);
  }
  var debounced = _.debounce(sendStrokes, 500, { 'leading': true, 'trailing': false });
  window.addEventListener("send", debounced, false);

  //event handlers
  function startRecording(event) {
    if(!drawing){
      var x = event.pageX;
      var y = event.pageY;
      x -= canvas.offsetLeft;
      y -= canvas.offsetTop;

      //Start drawing
      drawing = true;
      utils.draw(ctx, x, y, x, y);

      //Add start point of the stroke to the list
      strokes.push([[x,y]]);
    }
  }

  function recording(event){
    if(drawing){
      var x = event.pageX;
      var y = event.pageY;
      x -= canvas.offsetLeft;
      y -= canvas.offsetTop;

      var curr = strokes[strokes.length - 1];
      utils.draw(ctx, x, y, curr[curr.length - 1][0], curr[curr.length - 1][1]);
      addPoint2Stroke(x, y);
    }
  }

  function stopRecording(){
    drawing = false;
    var evt = new Event('send');
    window.dispatchEvent(evt);
  }

  function cancelRecording(){
    drawing = false;
  }

  //interactions
  function cleanAll(event){
    strokes = [];
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
  }

  function cleanLast(event){
    drawing = false;
    strokes.pop();
    utils.redraw(ctx, strokes);
  }

  function save(event){
    utils.save2File(strokes);
  }

  //add event listeners
  canvas.addEventListener("mousedown", startRecording, false);
  canvas.addEventListener("mousemove", recording, false);
  canvas.addEventListener("mouseup", stopRecording, false);
  canvas.addEventListener("mouseleave", cancelRecording, false);

  buttons.cleanAll.addEventListener("click", cleanAll, false);
  buttons.cleanLast.addEventListener("click", cleanLast, false);
  buttons.save.addEventListener("click", save, false);
};

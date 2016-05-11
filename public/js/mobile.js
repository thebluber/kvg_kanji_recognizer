'use strict';
/*jslint browser: true*/
/*global $, jQuery, alert, utils, api, _*/

var mobile = function(canvas, buttons) {
  var strokes = [];
  var drawing = false;
  var ctx = canvas.getContext("2d");

  //window events
  function resizeCanvas(){
    canvas.width = window.innerWidth;
    canvas.height = window.innerWidth;
    ctx = canvas.getContext("2d");
    ctx.strokeStyle = "#df4b26";
    //ctx.lineJoin = "round";
    ctx.lineCap = "round";
    ctx.lineWidth = 5;
    utils.redraw(ctx, strokes);
  }
  window.addEventListener("resize", resizeCanvas, false);
  window.addEventListener("orientationchange", resizeCanvas, false);
  //for save
  window.addEventListener("save", function(e){ utils.saveSample(e.detail, strokes); }, false);

  //setup canvas
  resizeCanvas();


  //helper function
  function addPoint2Stroke(x, y) {
    strokes[strokes.length - 1].push([x, y]);
  }

  //api callbacks
  function errorCallback(msg) {
    alert(msg);
  }

  function successCallback(results) {
    utils.renderResults(results.scores, strokes);
    utils.renderTimer(results.time);
  }

  //debounce sending strokes
  function sendStrokes() {
    api.getScores(strokes, 12, successCallback, errorCallback);
  }
  var debounced = _.debounce(sendStrokes, 500);
  window.addEventListener("send", debounced, false);

  //event handlers
  function startRecording(event) {
    if(!drawing){
      var x = event.pageX;
      var y = event.pageY;
      if(event.changedTouches){
        x = event.changedTouches[0].pageX;
        y = event.changedTouches[0].pageY;
      }
      x -= canvas.offsetLeft;
      y -= canvas.offsetTop;

      //Start drawing
      drawing = true;
      ctx.beginPath();
      ctx.moveTo(x, y);

      //Add start point of the stroke to the list
      strokes.push([[x,y]]);
      debounced.cancel();
    }
  }

  function recording(event){
    event.preventDefault();
    if(drawing){
      var x = event.changedTouches[0].pageX;
      var y = event.changedTouches[0].pageY;
      x -= canvas.offsetLeft;
      y -= canvas.offsetTop;

      ctx.lineTo(x, y);
      ctx.stroke();
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
  function cleanAll(){
    drawing = false;
    strokes = [];
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
  }

  function cleanLast(){
    drawing = false;
    strokes.pop();
    utils.redraw(ctx, strokes);
  }

  function save(){
    utils.save2File(strokes);
  }


  //add event listeners
  canvas.addEventListener("touchstart", startRecording, false);
  canvas.addEventListener("touchmove", recording, false);
  canvas.addEventListener("touchend", stopRecording, false);
  canvas.addEventListener("touchcancel", cancelRecording, false);

  buttons.cleanAll.addEventListener("click", cleanAll, false);
  buttons.cleanLast.addEventListener("click", cleanLast, false);
  buttons.save.addEventListener("click", save, false);
};

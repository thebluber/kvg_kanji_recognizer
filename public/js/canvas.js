'use strict';
/*jslint browser: true*/
/*global $, jQuery, alert, utils, api*/

function init() {

    /*
     * Functions handling canvas and point recording
     */
     
    var canvas = document.getElementById("pad");
    var drawing = false;
    var points = [];
    var stroke = 0;
    var sending = false;
    
    if( screen.width <= 480 ) {
      window.addEventListener("resize", function(){ mobile.resizeCanvas(canvas) }, false);
      window.addEventListener("orientationchange", function(){ mobile.resizeCanvas(canvas) }, false);

      canvas.addEventListener("touchstart", startRecording, false);
      canvas.addEventListener("touchmove", recording, false);
      canvas.addEventListener("touchend", stopRecording, false);
      canvas.addEventListener("touchcancel", mouseleave, false);
    } else {
      canvas.width = 300;
      canvas.height = 300;
      canvas.addEventListener("mousedown", startRecording, false);
      canvas.addEventListener("mousemove", recording, false);
      canvas.addEventListener("mouseup", stopRecording, false);
      canvas.addEventListener("mouseleave", mouseleave, false);
    }
    if(canvas.getContext){
        var ctx = canvas.getContext("2d");
        ctx.strokeStyle = "#df4b26";
        ctx.lineJoin = "round";
        ctx.lineCap = "round";
        ctx.lineWidth = 3;
    } else {
        alert("Your browser does not support canvas!");
    }

    function errorCallback(msg) {
      sending = false;
      alert(msg);
    }

    function successCallback(results) {
      sending = false;
      resultsUtils.render(results.scores);
      resultsUtils.renderTimer(results.time);
    }

    function mouseleave() {
      sending = false;
      drawing = false;
    }

    function stopRecording(){
      drawing = false;
      if(!sending) {
        var strokes = utils.convertPoints2Strokes(points);
        api.getScores(strokes, 10, successCallback, errorCallback);
      }
    }

    function recording(event){
        if(drawing){
            var x = event.pageX;
            var y = event.pageY;
            x -= canvas.offsetLeft;
            y -= canvas.offsetTop;

            draw(x, y, points[points.length - 1][1], points[points.length - 1][2]);
            addPoint(x, y, stroke);
        }
    }

    function startRecording(event){
        if(!drawing){
            var x = event.pageX;
            var y = event.pageY;
            x -= canvas.offsetLeft;
            y -= canvas.offsetTop;

            //Start drawing
            drawing = true;
            draw(x, y, x, y);
            //Increment stroke index
            stroke += 1;
            //Add start point of the stroke to the list
            addPoint(x, y, stroke);
        }
    }

    function addPoint(x, y, stroke){
        points.push([stroke, x, y]);
    }

    function draw(x, y, xPre, yPre){
        ctx.beginPath();
        ctx.moveTo(xPre, yPre);
        ctx.lineTo(x, y);
        ctx.closePath();
        ctx.stroke();
      //ctx.fillRect(xPre,yPre,2,2);
    }

    function redraw(){
      drawing = false;
      ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

      var i = 1;
      var interval = setInterval(function(){
        if(points[i][0] == points[i-1][0]){
          draw(points[i][1], points[i][2], points[i-1][1], points[i-1][2]);
        }
        i += 1;
        if(i >= points.length) clearInterval(interval);
      }, 10);
    }

    /*
     * Utilities
     */

    function euclidean_dist(p1, p2){
      sum = Math.pow(p1[1]-p2[1], 2) + Math.pow(p1[2]-p2[2], 2);
      return Math.sqrt(sum);
    }

    function downsample(threshold){
      new_points = [];
     
      //downsample by removing consecutive samples for which
      //the euclidean distance is inferior to threshold.
      for(var i = 1; i < points.length; i++){
        if(euclidean_dist(points[i], points[i-1]) > threshold){
          new_points.push(points[i]);
        }
      }

      points = new_points
    }

    function smooth(){
      //p'(i) = (w(-M)*p(i-M) + ... + w(0)*p(i) + ... + w(M)*p(i+M)) / S
      var weights = [1,1,2,1,1];
      var offset = Math.floor(weights.length / 2.0);
      var wsum = weights.reduce(function(a, b){ return a + b }, 0);

      var strokes = points.reduce(function(a,b){ a[b[0]-1] ? a[b[0]-1].push(b) : a[b[0]-1] = [b]; return a }, []);

      var point_index = 0;
      for(var i = 0; i < strokes.length; i++){
        if(strokes[i].length < weights.length){
          point_index += strokes[i].length
          continue;
        }
        point_index += offset;
        for(var j = offset; j < strokes[i].length - offset; j++){
          point_index += 1;

          var new_x = 0;
          var new_y = 0;
          for(var w = 0; w < weights.length; w++){
            new_x += weights[w] * strokes[i][j + w - offset][1];
            new_y += weights[w] * strokes[i][j + w - offset][2];
          }
          points[point_index-1] = [ i+1, new_x/wsum, new_y/wsum ];
        }
        point_index += offset;
      }

    }

    //helper function for interpolation
    function calculate_average_length(stroke) {
      var sum = 0;
      for(var i = 1; i < stroke.length; i++){
        sum += euclidean_dist(stroke[i-1], stroke[i]);
      }
      return sum / stroke.length;
    }

    function interpolate(){
      //adding points to stroke so that the distance between point is not less than the average length
      //for one stroke: average_length = sum(euclidean_dist(p_i-1, p_i)) / number of points in stroke
      //more in paper preprocessing techniques for online character recognition
      
      //interpolating
      var new_points = [];
      var strokes = points.reduce(function(a,b){ a[b[0]-1] ? a[b[0]-1].push(b) : a[b[0]-1] = [b]; return a }, []);
      
      for(var i = 0; i < strokes.length; i++){
        d = calculate_average_length(strokes[i]) / 2;
        console.log(d);
        first_p = strokes[i][0];
        new_points.push(first_p);

        var last_j = 0;
        for(var j = 1; j < strokes[i].length; j++){
          if (euclidean_dist(first_p, strokes[i][j]) < d) continue;
          point = strokes[i][j];
          new_point = [point[0]];

          //calculate new point coordinates
          if (point[1] == first_p[1]){
            if (point[2] > first_p[2]){
              new_point = new_point.concat([first_p[1], first_p[2] + d]);
            } else {
              new_point = new_point.concat([first_p[1], first_p[2] - d]);
            }
          } else {
            var slope = (point[2] - first_p[2]) / (point[1] - first_p[1]);
            var new_x, new_y;
            if (point[1] > first_p[1]){
              new_x = first_p[1] + Math.sqrt(Math.pow(d,2) / (Math.pow(slope,2) + 1));
            } else {
              new_x = first_p[1] - Math.sqrt(Math.pow(d,2) / (Math.pow(slope,2) + 1));
            }
            new_y = slope * new_x + first_p[2] - (slope * first_p[1]);
            new_point = new_point.concat([new_x, new_y]);
          }

          new_points.push(new_point);
          first_p = new_point;
          last_j += Math.floor((j - last_j)/2);
          j = last_j;
        }
        //keep last point of stroke
        new_points.push(strokes[i][strokes[i].length - 1]);
      }

      points = new_points;
    }

    /*
     * Functions for interactions with buttons
     */

    var cleanButton = document.getElementById("clean");
    var saveButton = document.getElementById("save");
    var downsampleButton = document.getElementById("downsample");
    var outputButton = document.getElementById("output");
    var smoothButton = document.getElementById("smooth");
    var redrawButton = document.getElementById("redraw");
    var interpolateButton = document.getElementById("interpolate");


    cleanButton.addEventListener("click", cleanAll, false);
    saveButton.addEventListener("click", saveToFile, false);
    downsampleButton.addEventListener("click", downsampling, false);
    outputButton.addEventListener("click", output, false);
    smoothButton.addEventListener("click", smoothing, false);
    redrawButton.addEventListener("click", redrawing, false);
    interpolateButton.addEventListener("click", interpolating, false);


    function cleanAll(event){
        drawing = false;
        points = [];
        stroke = 0;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    }

    function saveToFile(event){
        var strokes = utils.convertPoints2Strokes(points);
        var value = prompt("Value of the input: ", "蔵　京　機　画　物　壬　浜　大　豊　都")
        if (value) {
          var json = JSON.stringify({ value: value, strokes: strokes});
          //Not possible to save files on client side using javascript due to security
          //workaround is to create a Blob object
          var textFileAsBlob = new Blob([json], {type:'text/csv;charset=utf-8'});
          window.open(window.URL.createObjectURL(textFileAsBlob));
        } else {
          alert("Value is required for identifying input!");
        }
    }

    function output(event){
      console.log(points.length);
      var textarea = document.getElementById("out");
      textarea.value = points.join("\n");
    }

    function downsampling(event){
      console.log("downsampling with threshold 1.5");
      //downsample(1.5);
      new_points = [];
      for(var i = 0; i < points.length; i++){
        if(i % 3 == 0){
          new_points.push(points[i]);
        }
      }
      points = new_points;
      downsample(1.5);
      redraw();
    }
    
    function smoothing(event){
      smooth();
      redraw();
    }

    function interpolating(event){
      interpolate();
      redraw();
    }

    function redrawing(event){
      redraw();
    }
}

$( document ).ready(init);

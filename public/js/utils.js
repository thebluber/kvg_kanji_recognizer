'use strict';
/*global $, jQuery, alert*/
/*
 * utilities
 */

var utils = {
  draw(ctx, x, y, xPre, yPre){
    ctx.beginPath();
    ctx.moveTo(xPre, yPre);
    ctx.lineTo(x, y);
    //ctx.closePath();
    ctx.stroke();
    //ctx.fillRect(xPre,yPre,2,2);
  },
  renderResults(results) {
    $('#results').html('');
    for(var i=0; i<results.length; i++) {
      $('<a class="result" onclick="utils.dispatchSaveEvent(this.innerHTML)">' + results[i] + '</a>').appendTo('#results');
    }
  },
  renderTimer(time) {
    $('#time').html('Timer: ' + time)
  },
  redraw(ctx, strokes){
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

    for(var i=0; i<strokes.length; i++){
      for(var j=1; j<strokes[i].length; j++){
        this.draw(ctx, strokes[i][j][0], strokes[i][j][1], strokes[i][j-1][0], strokes[i][j-1][1]);
      }
    }
  },
  save2File(strokes){
    var value = prompt("Value of the input: ", "蔵　京　機　画　物　壬　浜　大　豊　都");
    if (value) {
      var json = JSON.stringify({ value: value, strokes: strokes});
      api.saveSample(json);
      //Not possible to save files on client side using javascript due to security
      //workaround is to create a Blob object
      //var textFileAsBlob = new Blob([json], {type:'text/csv;charset=utf-8'});
      //window.open(window.URL.createObjectURL(textFileAsBlob));
    } else {
      alert("Value is required for identifying input!");
    }
  },
  saveSample(value, strokes){
    var confirmed = confirm("Save sample of " + value + "?");
    if (confirmed){
      var json = JSON.stringify({ value: value, strokes: strokes});
      api.saveSample(json);
    }
  },
  dispatchSaveEvent(value){
    var evt = new CustomEvent('save', { 'detail': value });
    window.dispatchEvent(evt);
  }
};

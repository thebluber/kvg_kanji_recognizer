'use strict';
/*global $, jQuery, alert*/
/*
 * API server interactions
 */
var api_host, api_version;
api_host = 'http://192.168.2.101:9292';
var api = {
  api_host: api_host || 'http://localhost:9292',
  api_version: api_version || '/api/v1',

  //strokes in the nested array form
  getScores(strokes, n_best, success, error) {
    var url = this.api_host + this.api_version + '/scores';
    $.ajax({
      url: url,
      type: 'POST',
      dataType: 'json',
      data: {
        strokes: JSON.stringify(strokes),
        n_best: n_best
      },
      done: function(response) {
        console.log(response);
      },
      fail: function(response) {
        console.log(response);
      },
      success: success,
      error: error
    })
  },

  saveSample(sample) {
    var url = this.api_host + this.api_version + '/save';
    $.ajax({
      url: url,
      type: 'POST',
      dataType: 'json',
      data: {
        sample: sample
      },
      success: function(response) {
      },
      error: function(response) {
        alert(response.notice);
      }
    })
  }

}



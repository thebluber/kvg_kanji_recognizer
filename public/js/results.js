'use strict';
/*global $, jQuery, alert*/
/*
 * Utilities for handling results
 */
var resultsUtils = {
  renderResults(results) {
    $('#results').html('');
    for(var i=0; i<results.length; i++) {
      $('<span class="result">' + results[i] + '</span>').appendTo('#results');
    }
  },
  renderTimer(time) {
    $('#time').html('<p>Timer: ' + time + '</p>')
  }
}

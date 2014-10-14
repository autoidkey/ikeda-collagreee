# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# for NP calculate
INTERVAL = 400
timeout = 0

init_timer = ->
  clearTimeout(timeout) if timeout
  timeout = setTimeout content_change, INTERVAL

content_change = ->
  console.log 'calculating...'

$(document).on 'keyup', '.reply-entry-form', (e) ->
  init_timer()

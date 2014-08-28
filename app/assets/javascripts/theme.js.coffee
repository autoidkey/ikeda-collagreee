# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click',  '#facilitation a', (e) ->
  e.preventDefault()
  console.log($('#entry_body').val($(@).text()))

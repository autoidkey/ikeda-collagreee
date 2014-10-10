# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.facilitation-phrase a', (e) ->
  e.preventDefault()
  $(@).parents('.tab-pane').find('textarea').val($(@).text())

$(document).on 'click', '.facilitation-phrase h4', (e) ->
  $(@).next().toggle()

$(document).on 'mouseenter', '.user-icon', (e) ->
  $(@).popover('show')

$(document).on 'mouseleave', '.user-icon', (e) ->
  $(@).popover('hide')

$ ->
  $(".slider").slider
    orientation: "horizontal",
    animate: "fast"
    range: "min",
    max: 100,
    value: 50,

    change: (e, ui) ->
      $("#num").val ui.value
      return

    # 4スライダーの初期化時に、その値をテキストボックスにも反映
    create: (e, ui) ->
      $("#num").val $(this).slider("option", "value")
      return

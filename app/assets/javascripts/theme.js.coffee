# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.facilitation-phrase a', (e) ->
  e.preventDefault()
  $(@).parents('.tab-pane').find('textarea').val($(@).text())

$(document).on 'click', '.facilitation-phrase h4', (e) ->
  $(@).next().toggle()

$(document).on 'click', '.reply-label', (e) ->
  $(@).nextAll('.reply-form').toggle()

$(document).on
  mouseenter: (e) ->
    $(@).popover('show')
  mouseleave: (e) ->
    $(@).popover('hide')
  '.user-icon'

$ ->
  $(".slider").slider
    orientation: "horizontal",
    animate: "fast"
    range: "min",
    max: 100,
    value: 50,

    change: (e, ui) ->
      $("#num").val ui.value

    # 4スライダーの初期化時に、その値をテキストボックスにも反映
    create: (e, ui) ->
      $("#num").val $(this).slider("option", "value")

$ ->
  $.autopager
    autoLoad: true
    content: "#entry-tl > .panel"
    link: ".next a"
    start: (current, next) ->
      $("#icon-loading").css "display", "block"
    load: (current, next) ->
      $("#icon-loading").css "display", "none"

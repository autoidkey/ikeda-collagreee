# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @SetTool
  set_slider: ->
    $(".slider").slider
      orientation: "horizontal",
      animate: "fast"
      range: "min",
      max: 100,
      value: 50,

      change: (e, ui) ->
        $(".np-input").val ui.value

      # 4スライダーの初期化時に、その値をテキストボックスにも反映
      create: (e, ui) ->
        $("#num").val $(this).slider("option", "value")

  set_autopager: ->
    $.autopager
      autoLoad: true
      content: "#entry-tl > .panel"
      link: ".next a"
      start: (current, next) ->
        $("#icon-loading").css "display", "block"
      load: (current, next) ->
        $("#icon-loading").css "display", "none"

$(document).on 'click', '.facilitation-phrase a', (e) ->
  e.preventDefault()
  $(@).parents('.tab-pane').find('textarea').val($(@).text())

$(document).on 'click', '.facilitation-phrase h4', (e) ->
  $(@).next().toggle()

$(document).on 'click', '.reply-label', (e) ->
  $(@).nextAll('.reply-form').toggle()

$(document).on 'click', 'button#order-time', (e) ->
  $('#entry-tl').html("")

$(document).on 'click', 'button#order-popular', (e) ->
  $('#entry-tl').html("")

$(document).on 'click', '#issues .label', (e) ->
  $(e.target).toggleClass "active"

$(document).on 'click', '#issues', (e) ->
  issue_arr = $('#issues .label.active').map(->
    $(this).data('id').toString()
  )
  if issue_arr.count == 0
    $('.panel').css 'display', 'block'
  else
    $('.panel').each ->
      $(@).css 'display', 'none'
      _this = @
      $(@).find('.issue-label').each ->
        if !($.inArray(this.dataset.id, issue_arr))
          $(_this).css 'display', 'block'

$(document).on
  mouseenter: (e) ->
    $(@).popover('show')
  mouseleave: (e) ->
    $(@).popover('hide')
  '.user-icon'

$ ->
  tool.set_autopager()
  tool.set_slider()

@tool = new SetTool()

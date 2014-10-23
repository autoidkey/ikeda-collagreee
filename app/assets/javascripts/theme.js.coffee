# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @Slider
  set: ->
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

class @AutoPager
  set: ->
    $.autopager
      autoLoad: true
      content: "#entry-tl > .panel"
      link: "#next a"
      start: (current, next) ->
        $("#icon-loading").css "display", "block"
      load: (current, next) ->
        $("#icon-loading").css "display", "none"
        slider.set()

class @SetTools
  set: ->
    slider.set()
    autopager.set()

@slider = new Slider()
@autopager = new AutoPager()
@settools = new SetTools()

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


# like!
$(document).on 'click', '.like_button', (e) ->
  status = $(@).data('status')
  url = "/entries/like"
  data = {id: $(@).data('id'), status: status}
  $.post(url, data)

  if status  == 'remove'
    $(@).data('status', 'attach')
    $(@).text "Like!"
  else if status == 'attach'
    $(@).data('status', 'remove')
    $(@).text "Like!を取り消す"

$(document).on 'click', '#issues', (e) ->
  issue_arr = $('#issues .label.active').map(->
    $(this).data('id').toString()
  )
  if issue_arr.length == 0
    $('.panel').css 'display', 'block'
  else
    $('.panel').each ->
      $(@).css 'display', 'none'
      _this = @
      $(@).find('.issue-label').each ->
        if !($.inArray(this.dataset.id, issue_arr))
          $(_this).css 'display', 'block'
  settools.set()

$(document).on
  mouseenter: (e) ->
    $(@).popover('show')
  mouseleave: (e) ->
    $(@).popover('hide')
  '.user-icon'

$ ->
  slider.set()
  # autopager.set()

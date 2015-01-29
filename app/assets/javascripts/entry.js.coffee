# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# For NP calculate

e = window.event if !e

INTERVAL = 400
timeout = 0

init_timer = (e) ->
  clearTimeout(timeout) if timeout
  timeout = setTimeout(
    (->
      content_change e
    ), INTERVAL
  )

content_change = (e) =>
  target = e.target || e.srcElement
  data = {text: target.value, entry_id: $(target).data('id')}
  url = "/entries/np"
  $.post(url, data, (
    (json) =>
      $('#slider-' + json.entry_id).slider 'value', json.np
      $('#np-input' + json.entry_id).val json.np
      ),
    'JSON'
    )

# event binding
$(document).on 'keyup blur', '.reply-entry-form', (e) ->
  init_timer(e)

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
      content: "#timeline > .panel"
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

class @Modal
  set: ->
    $("a[rel*=leanModal]").leanModal
      top: 50 # #modal-windowの縦位置
      left: 50 # #modal-windowの縦位置
      overlay: 0.5 # #modal-windowの背面の透明度
      closeButton: ".modal_close" # #modal-windowを閉じるボタンのdivのclass

@slider = new Slider()
@autopager = new AutoPager()
@settools = new SetTools()
@modal = new Modal()

$(document).on 'ready page:load', ->
  slider.set()
  modal.set()

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# for NP calculate
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
  data = {text: e.target.value, entry_id: e.target.dataset.id}
  url = "/entries/np"
  $.post(url, data, (
    (json) =>
      $('#slider-' + json.entry_id).slider 'value', json.np
      $('#np-input' + json.entry_id).val json.np
      ),
    'JSON'
    )

# event binding
$(document).on 'keyup', '.reply-entry-form', (e) ->
  init_timer(e)

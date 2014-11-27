# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ENTRY_POINT = 10.00
REPLY_POINT = 10.00
LIKE_POINT = 10.00
UNLIKE_POINT = -10.00
REPLIED_POINT = 10.00
LIKED_POINT = 10.00

class @PointCount
  entry: (theme) ->
    point = (parseFloat( $('#entry_point').text() ) + ENTRY_POINT).toFixed(1)
    $('#entry_point').text(point).hide().fadeIn 'slow'
    @sum(ENTRY_POINT)
    @active(ENTRY_POINT)
    @animation('entry')

  reply: (theme) ->
    point = (parseFloat( $('#reply_point').text() ) + REPLY_POINT).toFixed(1)
    $('#reply_point').text(point).hide().fadeIn 'slow'
    @sum(REPLY_POINT)
    @active(REPLY_POINT)
    @animation('reply')

  like: ->
    point = (parseFloat( $('#like_point').text() ) + LIKE_POINT).toFixed(1)
    $('#like_point').text(point).hide().fadeIn 'slow'
    @sum(LIKE_POINT)
    @active(LIKE_POINT)
    @animation('like')

  unlike: ->
    point = (parseFloat( $('#like_point').text() ) + UNLIKE_POINT).toFixed(1)
    $('#like_point').text(point).hide().fadeIn 'slow'
    @sum(UNLIKE_POINT)
    @active(UNLIKE_POINT)

  active:(point) ->
    point = (parseFloat( $('#active_point').text() ) + point).toFixed(1)
    $('#active_point').text(point).hide().fadeIn 'slow'

  sum: (point) ->
    sum_point = (parseFloat( $('#sum_point').text() ) + point).toFixed(1)
    $('#sum_point').text(sum_point).hide().fadeIn 'slow'

  animation: (action) ->
    switch action
      when 'entry'
        comment = "投稿ポイント" + ENTRY_POINT + " pt 獲得！！"
      when 'reply'
        comment = "返信ポイント" + REPLY_POINT + " pt 獲得！！"
      when 'like'
        comment = "Likeポイント" + LIKE_POINT + " pt 獲得！！"

    $('#header-alert').css 'display', 'block'
    $('#point-alert').text(comment)
    $('#point-alert').addClass 'expandUp'
    setTimeout (->
      $('#header-alert').fadeOut 'fast'
      $('#point-alert').removeClass 'expandUp'
    ), 2500

  parent: (entry)->
    parent = entry.parents('div[id^="entry-"]').first()
    point = parent.find('.point').first()
    new_point = (parseFloat(point.text()) + REPLIED_POINT).toFixed(1)
    point.text(new_point).hide().fadeIn 'slow'

change_point = (target, count, base_point) ->
  obj = target.parents('div[id^="entry-"]').first()
  unless obj.length == 0
    point = obj.find('.point').first()
    new_point = (parseFloat(point.text()) + base_point / count).toFixed(2)
    point.text(new_point).hide().fadeIn 'slow'
    count = count * 2
    change_point(obj, count, base_point)

check_new = () ->
  setTimeout(
      (=>
        console.log 'checking...'
        check_new()
      ), 1000)

@point = new PointCount()

$(document).on 'click', '.facilitation-phrase a', (e) ->
  e.preventDefault()
  $(@).parents('.tab-pane').find('textarea').val($(@).text())

$(document).on 'click', '.facilitation-phrase h4', (e) ->
  $(@).next().toggle()

$(document).on 'click', '.reply-label', (e) ->
  $(@).nextAll('.reply-form').toggle()

$(document).on 'click', 'button#order-time', (e) ->
  $('#timeline').html("")

$(document).on 'click', 'button#order-popular', (e) ->
  $('#timeline').html("")

$(document).on 'click', '#issues .label', (e) ->
  $(e.target).toggleClass "active"


# like操作
$(document).on 'click', '.like_button', (e) ->
  status = $(@).data('status')
  url = "/entries/like"
  data = {id: $(@).data('id'), status: status}
  $.post(url, data)
  count = 2

  if status  == 'remove'
    $(@).data('status', 'attach')
    $(@).text "Like!"

    like = parseInt($(@).nextAll('.like_count').text()) - 1
    $(@).nextAll('.like_count').text(like).hide().fadeIn 'slow'

    point = (parseFloat($(@).nextAll('.point').text()) + UNLIKE_POINT).toFixed(2)
    $(@).nextAll('.point').text(point).hide().fadeIn 'slow'

    _this = $(@).parents('div[id^="entry-"]').first()
    change_point(_this, count, UNLIKE_POINT)

  else if status == 'attach'
    $(@).data('status', 'remove')
    $(@).text "Like!を取り消す"

    like = parseInt($(@).nextAll('.like_count').text()) + 1
    $(@).nextAll('.like_count').text(like).hide().fadeIn 'slow'

    point = (parseFloat($(@).nextAll('.point').text()) + LIKE_POINT).toFixed(2)
    $(@).nextAll('.point').text(point).hide().fadeIn 'slow'

    _this = $(@).parents('div[id^="entry-"]').first()
    change_point(_this, count, LIKE_POINT)

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

$(document).on 'ready page:load', ->
  check_new()

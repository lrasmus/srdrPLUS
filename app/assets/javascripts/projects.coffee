# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    if gon.message_name
      toastr.info(gon.message_content, gon.message_name, {
          'timeOut': '15000',
          'progressBar': true })

    delay = do ->
      timer = 0
      (callback, ms) ->
        clearTimeout timer
        timer = setTimeout(callback, ms)
        return

    searchProjectsList = ->
      $.get {
          url: '/projects/search?q=' + $('#project-search').val(),
          dataType: 'script'
        }
      return

    $('#project-search').keyup ->
      delay searchProjectsList, 500
      return

    return

  return

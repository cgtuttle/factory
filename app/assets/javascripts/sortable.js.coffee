jQuery ->
  $('#sortable').sortable(
    axis: 'y'
    items: ".sortable"
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
   )

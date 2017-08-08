# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    ###########################
    # Hide unnecessary options.
    multiSelect = ['checkbox', 'dropdown', 'radio', 'select2_single', 'select2_multi']

    $('.fieldset').on 'change', ->
      that = $(this)
      that.find('.field-options').hide()
      that.find('.links').hide()
      _value = that.find('select').children(':selected').text()

      if _value in multiSelect
        that.find('.field-options.field-option-type-answer_choice').show()
        that.find('.links').show()

      else if _value == 'text'  # Text.
        that.find('.field-options.field-option-type-min_length').show()
        that.find('.field-options.field-option-type-max_length').show()

      else if _value == 'numeric'  # Numeric.
        that.find('.field-options.field-option-type-min_value').show()
        that.find('.field-options.field-option-type-max_value').show()

      else if _value == 'scientific'  # Scientific.
        that.find('.field-options.field-option-type-min_value').show()
        that.find('.field-options.field-option-type-max_value').show()
        that.find('.field-options.field-option-type-coefficient').show()
        that.find('.field-options.field-option-type-exponent').show()

    $('.fieldset').trigger 'change'


    ###########################################
    # Hide first row and column if only 1 cell.

    hideHeaders = (_tableRows) ->
      _rowCnt = _tableRows.length
      _colCnt = _tableRows[0].cells.length

      if _rowCnt == 2 and _colCnt == 2
        _tableRows.find('th:nth-child(-n+3)').hide()
        _tableRows.find('td:first-child').hide()

      return


    $('#step-two table').each ->

      _tableRows = $(this).find('tr')

      if _tableRows.length > 1
        hideHeaders(_tableRows)



    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->

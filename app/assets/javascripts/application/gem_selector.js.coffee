$ ->
  $('.js-submit-choice').on 'click', (e) ->
    quality = $(".js-gem-quality").data('value')
    type = $(".js-gem-type").data('value')
    #console.log $(".js-selected-gems tr").length
    if GemSuggestor.availableGems.length >= 5
      $(".js-selection-count-alert").show('slow')
    else if quality? && type?
      hideAlerts()
      gem = Gem.find(quality, type)
      GemSuggestor.addGem(gem)
    else
      $(".js-selection-alert").show('slow')

  $(".js-available-gems").on 'click', '.js-remove-gem-option', (e) ->
    e.preventDefault()
    hideAlerts()
    $gemRow = $(this).closest(".js-gem-option")

    GemSuggestor.removeGem($gemRow)
    #$gemRow.hide 'slow', ->
    #  GemSuggestor.removeGem($gemRow.data('number'))
    #  $(this).remove()


  $("body").on "keyup", "input.js-refresh-recipe", (e) ->
    row = $(this).closest("tr")
    name = row.find(".js-recipe-name").data('value')
    recipe = Recipe.findByName(name)
    priority = row.find(".js-priority").val()
    quantity = row.find(".js-quantity").val()
    recipe.updateAttributes({priority, quantity})
    GemSuggestor.refreshSuggestion()

    saveConfig("__default")

  $("body").on "click", ".btn[data-select=gem]", (e) ->
    e.preventDefault()

    unless $(this).is(".disabled")
      (new GemSuggestor).disableButtons(true)
      gem = Gem.findByFullName($.trim($(this).data('value')))
      gem.select()
      $(".js-clear-choices").trigger("click")

  $("body").on "click", ".btn[data-select=recipe]", (e) ->
    e.preventDefault()

    unless $(this).is(".disabled")
      (new GemSuggestor).disableButtons(true)
      recipe = Recipe.findByName($(this).data('value'))
      $.each recipe.gems, (index, gem) -> gem.select()
      $(".js-clear-choices").trigger("click")

  $("body").on "click", ".js-remove-gem", (e) ->
    e.preventDefault()
    item = $(this).closest("li")[0]
    index = $.inArray item, $(".js-selected-gems li")

    if index > -1
      Gem.selectedGems.deleteAt(index)
      $(item).remove()

    GemSuggestor.refreshSuggestion()

  $("body").on "click", ".js-clear-choices", (e) ->
    e.preventDefault()
    $(".js-remove-gem-option").trigger("click")
    $(".js-gem-selector .btn.active").removeClass("active")
    $(".js-gem-selector .js-btn-group").data("value", null)

  $("body").on "click", ".js-reset-everything", (e) ->
    e.preventDefault()
    GemSuggestor.availableGems = []
    $(".js-available-gems").empty()
    Gem.selectedGems = []
    $(".js-selected-gems").empty()

    $(".js-gem-selector .btn.active").removeClass("active")
    $(".js-gem-selecor .js-btn-group").data("value", null)
    GemSuggestor.refreshSuggestion()



  GemSuggestor.refreshSuggestion()

  hideAlerts = ->
    $(".js-selection-alert").hide('slow')
    $(".js-selection-count-alert").hide('slow')


    #if quality? && type?
    #  $(".js-selection-alert").hide()
    #  $(".js-gem#{gemIndex - 1}").removeClass("success")
#
    #  $row = $(".js-gem#{gemIndex}")
    #  $row.removeClass("info").removeClass("muted").addClass("success")
    #  $row.find(".js-gem-number").html(gemIndex)
    #  $row.find(".js-gem-name").html("#{quality} #{type}")
    #  gemIndex += 1
#
    #  $(".js-gem#{gemIndex}").show('slow')
    #  $(".js-gem-selector .btn.active").removeClass("active")
    #  $(".js-gem-selector .js-btn-group").data("value", null)
    #else
    #  $(".js-selection-alert").show()



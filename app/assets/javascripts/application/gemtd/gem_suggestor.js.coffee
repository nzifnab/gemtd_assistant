class window.GemSuggestor
  suggestions: ->
    @disableButtons()
    @suggestableGems = GemSuggestor.availableGems.slice(0)
    @checkDuplicates()
    downgrades = (GemSuggestor.availableGems.map (gem) -> gem.downgrade()).reject (gem) -> !gem?
    @suggestableGems.push(downgrades...)

    # Step 1:  Select only gems that have not been saturated yet
    @rejectSaturatedGems()
    # Step 2:  Collect only those gems from the highest
    #          found priority level unless that type of
    #          gem has been collected more times than the others
    #          for that recipe.
    @filterHighestPriority()
    # Step 3:  Collect only gems from the highest amount of gems
    #          left to collect, but also consider perfects to be
    #          at the top of the precedence for this step.
    #          This 'count' must also include the downgraded version
    #          of the gem (for counting purposes only)
    @filterHighestQuantityNeeded()
    # Step 4:  Collect gems from the highest upgrade level
    #          (perfect > flawless > normal > flawed > chipped)
    @filterHighestQuality()

    @suggestableGems.uniq()

  filterHighestQuality: ->
    maxRank = 0
    gems = []
    for gem in @suggestableGems
      gemRank = gem.quality.rank
      if gemRank > maxRank
        maxRank = gemRank
        gems = [gem]
      else if gemRank == maxRank
        gems.push(gem)

    @suggestableGems = gems

  filterHighestQuantityNeeded: ->
    perfectAdded = false
    perfectRank = GemQuality.findByName("Perfect").rank

    while true
      perfects = []
      maxCountFound = 0
      gems = []

      for gem in @suggestableGems
        count = gem.remainingQuantity() + (gem.downgrade()?.remainingQuantity() || 0)
        if count > maxCountFound
          maxCountFound = count
          gems = []
          perfectAdded = false
        if count == maxCountFound
          gems.push(gem)
          perfectAdded = true if gem.quality.rank >= perfectRank
        if gem.quality.rank >= perfectRank
          perfects.push(gem)

      if perfects.length > 0 && !perfectAdded
        # We recorded that there was a perfect in the search
        # space (but it was NOT at the same quantity remaining
        # to collect as other lower-quality gems), so we
        # have to repeat the loop exclusively *for* the perfects
        # to determine which one(s) have the highest count remaining
        @suggestableGems = perfects
      else
        break
    @suggestableGems = gems

  filterHighestPriority: ->
    priorities = @suggestableGems.map (gem) -> gem.priority()
    maxPriorityFound = -1
    gems = []
    forcedGems = []

    for priority, index in priorities
      gem = @suggestableGems[index]
      if gem.quality.rank >= GemQuality.findByName("Perfect").rank
        forcedGems.push gem

      unless gem.outnumbersRecipeSiblings()
        if priority > maxPriorityFound
          maxPriorityFound = priority
          gems = [gem]
        else if priority == maxPriorityFound
          gems.push gem

    if gems.length > 0
      gems.push(forcedGems...)
      @suggestableGems = gems

  rejectSaturatedGems: ->
    @suggestableGems = @suggestableGems.reject (gem) =>
      gem.isSaturated()

  checkDuplicates: ->
    gemCounts = {}
    upgradeGems = []

    gemNumber = 1
    for gem in GemSuggestor.availableGems
      name = gem.fullName()
      gemCounts[name] ?= 0
      gemCounts[name]++

      if gemCounts[name] == 2
        upgrade = gem.upgrade()
        @enableUpgrade(upgrade)
        upgradeGems.push(upgrade)
      else if gemCounts[name] == 4
        upgrade = upgradeGems[0].upgrade()
        @disableUpgrade(upgradeGems[0])
        @enableUpgrade(upgrade, true)
        upgradeGems = [upgradeGems[0].upgrade()]
      upgradeGems = upgradeGems.compact()
    @suggestableGems.push(upgradeGems...)

  disableButtons: ->
    $buttons = $(".js-gem-option .btn[data-select]").filter(':not(.js-base)')

    $buttons.addClass("disabled").removeClass("btn-primary").
      removeClass("btn-info").removeClass("btn-success")

    $buttons.filter(".js-double-upgrade").hide()

  enableUpgrade: (gem, isDoubleUpgrade=false) ->
    if isDoubleUpgrade
      $(".btn.js-double-upgrade").each (index, button) =>
        $button = $(button)
        if gem.fullName() == $.trim($button.data('value'))
          $button.show().removeClass("disabled").addClass("btn-primary")
    else
      $(".btn.js-upgrade").each (index, button) =>
        $button = $(button)
        if gem.fullName() == $.trim($button.data('value'))
          $button.removeClass("disabled").addClass("btn-info")

  disableUpgrade: (gem) ->
    $(".btn.js-upgrade").each (index, button) =>
      $button = $(button)
      if gem.fullName() == $.trim($button.data('value'))
        $button.addClass("disabled").removeClass("btn-info")

  @availableGems: []

  @addGem: (gem) ->
    $tmpl = $(JST["available_gem"](number: @gemIndex(), gem: gem)).hide()
    $(".js-available-gems").append $tmpl
    $tmpl.show('slow')

    $(".js-gem-selector .btn.active").removeClass("active")
    $(".js-gem-selector .btn-group").data("value", null)
    @availableGems.push(gem)
    @refreshSuggestion()

  @removeGem: ($gemRow) ->
    gemNumber = $gemRow.data('number')
    @availableGems.deleteAt(gemNumber-1)
    for number in [gemNumber..5]
      $row = $(".js-available-gems").find("[data-number=#{number}]")
      $row.attr("data-number", number - 1)
      $row.data("number", number - 1)
      $row.find(".badge").text(number - 1)

    $gemRow.hide 'slow', =>
      @refreshSuggestion()
      $gemRow.remove()

  @gemIndex: ->
    @availableGems.length + 1

  @suggestion: ->
    (new GemSuggestor.suggestion())

  @refreshSuggestion: ->
    suggestions = (new GemSuggestor()).suggestions()
    $(".js-suggested-gem").show()
    $(".js-suggestions").empty()
    for gem in suggestions
      tmpl = JST["gem_button"](class: "btn-primary", gem: gem, select: 'gem')
      $(".js-suggestions").append $(tmpl)
    window.registerHotkey $(".js-suggestions .btn").first().attr("data-hotkey", "%enter").
      data("hotkey", "%enter")

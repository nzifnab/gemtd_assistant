class window.GemSuggestor
  constructorName: "GemSuggestor"

  suggestions: ->
    @disableButtons()
    @suggestableGems = GemSuggestor.availableGems.slice(0)
    @checkDuplicates()
    downgrades = (GemSuggestor.availableGems.map (gem) -> gem.downgrade()).reject (gem) -> !gem?
    @suggestableGems.push(downgrades...)

    # First let's check if there's any available one-shots
    # that haven't been saturated and use the highest priority one
    @oneshotRecipes = []
    @filterOneshotRecipes()

    # No one-shots...continue checking gems

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

    # We want to prioritize one-shot recipes.
    # but if by some miracle you got a great or better
    # you probably want that instead.

    return @filterRecipesAgainstGems()

  filterRecipesAgainstGems: ->
    greatRank = GemQuality.findByName("Great").rank
    perfectRank = GemQuality.findByName("Perfect").rank
    maxRecipeRank = (@oneshotRecipes.max (recipe) ->
      recipe.maxRank())?.maxRank()

    # *) ALWAYS uses a gem selection if there's a great or better
    #    in the suggestions
    # *) Use a gem selection if there's a perfect in the suggestions
    #      and no perfects in the oneshot recipes
    if @oneshotRecipes.length <= 0 || (@suggestableGems.areAny (gem) ->
          gem.quality.rank >= greatRank || (gem.quality.rank >= perfectRank && maxRecipeRank < perfectRank)
    )

      @suggestableGems.uniq()
    else
      @oneshotRecipes.uniq()

  filterOneshotRecipes: ->
    for gem in GemSuggestor.availableGems
      for recipe in gem.recipes()
        if recipe.isOneshot() && recipe.gems.areAny((gem) -> gem.remainingQuantity() > 0)
          @oneshotRecipes.push(recipe)

    maxPriorityFound = -1000
    recipes = []
    for recipe in @oneshotRecipes
      if recipe.priority > maxPriorityFound
        maxPriorityFound = recipe.priority
        recipes = [recipe]
      else if recipe.priority == maxPriorityFound
        recipes.push(recipe)
    @oneshotRecipes = recipes

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
    # We'll calculate perfects+ and 'others' separately
    # -- we want perfects to be included after this step
    # but also for them to follow the same rules as non-perfects
    # (IE. if there's multiple perfects we only want the highest
    # priority one)
    maxPriorityFound = -1000
    maxPerfectPriorityFound = -1000
    gems = []
    perfectGems = []
    perfectRank = GemQuality.findByName("Perfect").rank

    for priority, index in priorities
      gem = @suggestableGems[index]

      unless gem.outnumbersRecipeSiblings()
        if gem.quality.rank >= perfectRank
          if priority > maxPerfectPriorityFound
            maxPerfectPriorityFound = priority
            perfectGems = [gem]
          else if priority == maxPerfectPriorityFound
            perfectGems.push gem
        else
          if priority > maxPriorityFound
            maxPriorityFound = priority
            gems = [gem]
          else if priority == maxPriorityFound
            gems.push gem

    gems.push(perfectGems...)

    if gems.length > 0
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

  disableButtons: (disableAll = false) ->
    $buttons = $(".js-gem-option .btn[data-select]")
    $buttons = $buttons.filter(':not(.js-base)') unless disableAll

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

  @enableRecipeButtons: ->
    buttons = $(".js-gem-recipes .btn[data-select=recipe]")

    buttons.each (index, button) =>
      $button = $(button)
      recipe = Recipe.findByName($button.data('value'))
      if recipe.isOneshot()
        $button.addClass("btn-success").removeClass("disabled")

  @availableGems: []

  @addGem: (gem) ->
    $tmpl = $(JST["available_gem"](number: @gemIndex(), gem: gem)).hide()
    $(".js-available-gems").append $tmpl
    $tmpl.show('slow')

    $(".js-gem-selector .btn.active").removeClass("active")
    $(".js-gem-selector .js-btn-group").data("value", null)
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
    Gem.refreshVolatileCaches()
    Recipe.refreshVolatileCaches()
    suggestions = (new GemSuggestor()).suggestions()
    $(".js-suggested-gem").show()
    $(".js-suggestions").empty()
    for gem in suggestions
      tmpl = JST["gem_button"](class: "btn-primary", object: gem)
      $(".js-suggestions").append $(tmpl)
    $(".js-suggestions i").remove()
    window.registerHotkey $(".js-suggestions .btn").first().attr("data-hotkey", "%enter").
      data("hotkey", "%enter")
    @refreshNotificationIcons()
    @enableRecipeButtons()

    $(".js-gem-total-needed").text(Recipe.totalGemCount())
    $(".js-gem-collected").text(Gem.selectedGems.length)
    $(".js-gem-remaining").text(Gem.totalRemainingQuantity())

  @refreshNotificationIcons: ->
    $("[data-notification-for]").removeClass("icon-star-empty").
      removeClass("icon-star").removeClass("notification-partial-saturation").
      removeClass("notification-exact-saturation").
      removeClass("notification-over-saturation")

    $("[data-notification-for]").each (index, icon) =>
      $icon = $(icon)
      gem = Gem.findByFullName($icon.data("notification-for"))
      selectedQuantity = gem.selectedQuantity()
      recipeQuantity = gem.recipeQuantity()

      # The gem is needed in some fashion
      if recipeQuantity > 0
        $icon.addClass("icon-star")

      # The gem is not needed at all
      if recipeQuantity <= 0
        $icon.addClass("icon-star-empty")
      # The gem has been collected, but more are required
      else if selectedQuantity > 0 && recipeQuantity > selectedQuantity
        $icon.addClass("notification-partial-saturation")
      # The gem has been collected the exact number of times required
      else if selectedQuantity == recipeQuantity
        $icon.addClass("notification-exact-saturation")
      # The gem has been collected more times than required
      else if selectedQuantity > recipeQuantity
        $icon.addClass("notification-over-saturation")

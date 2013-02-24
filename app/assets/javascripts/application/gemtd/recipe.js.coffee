class window.Recipe
  constructor: ({priority, @name, quantity, @gems}) ->
    @priority = Number(priority)
    @quantity = Number(quantity)
    @gems = @gems.compact()

  updateAttributes: ({priority, name, quantity, gems}) ->
    @priority = Number(priority) ? @priority
    @name = name ? @name
    @quantity = Number(quantity) ? @quantity
    @gems = gems ? @gems.compact()

  toString: ->
    @name()

  isOneshot: ->
    @_isOneshot ?= @gems.length > 1 && @gems.areAll (gem) ->
      $.inArray(gem, GemSuggestor.availableGems) != -1

  refreshVolatileCache: ->
    @_isOneshot = null

  @all: ->
    @allRecipes ?= do =>
      r = []
      $(".js-gem-recipes tbody tr").each ->
        r.push(Recipe.fromDomRow($(this)))
      r

  @fromDomRow: ($domRow) ->
    options = {
      priority: $domRow.find(".js-priority").val(),
      name: $domRow.find(".js-recipe-name").data('value'),
      quantity: $domRow.find(".js-quantity").val(),
      gems: (Gem.findByFullName($domRow.find(".js-gem#{num}-name").data('value')) for num in [1..4])
    }
    new Recipe(options)

  @findAllByGem: (gem) ->
    @all().select (recipe) ->
      recipe.gems.find (recipeGem) ->
        recipeGem?.fullName() == gem.fullName()

  @findByName: (name) ->
    @all().find (recipe) ->
      recipe.name == name

  @refreshVolatileCaches: ->
    for recipe in @all()
      recipe.refreshVolatileCache()

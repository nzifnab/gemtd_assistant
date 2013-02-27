class window.Recipe
  constructor: ({priority, @name, quantity, @gems, @extended}) ->
    @priority = Number(priority)
    @quantity = Number(quantity)
    @gems = @gems.compact()

  constructorName: "Recipe"

  updateAttributes: ({priority, name, quantity, gems, extended}) ->
    @priority = Number(priority) ? @priority
    @name = name ? @name
    @quantity = Number(quantity) ? @quantity
    @gems = gems ? @gems.compact()
    @extended = extended ? @extended

  toString: ->
    @name

  isOneshot: ->
    @_isOneshot ?= do =>
      @gems.length > 1 && @gems.areAll (gem) ->
        $.inArray(gem, GemSuggestor.availableGems) != -1

  refreshVolatileCache: ->
    @_isOneshot = null
    @_maxRank = null

  maxRank: ->
    @_maxRank ?= (@gems.max (gem) ->
      gem.quality.rank).quality.rank

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
      gems: (Gem.findByFullName($domRow.find(".js-gem#{num}-name").data('value')) for num in [1..4]),
      extended: $domRow.is(".js-extended-recipe")
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

  @export: ->
    data = {}
    for recipe in @all()
      data[recipe.name] = {
        priority: recipe.priority,
        quantity: recipe.quantity
      }
    data

  @import: (data) ->
    for own key, value of data
      fieldIdentifier = key.replace(/\ /g, "_").toLowerCase()
      $("##{fieldIdentifier}_priority").val(value['priority'])
      $("##{fieldIdentifier}_quantity").val(value['quantity'])
    @allRecipes = null
    for gem in Gem.all()
      gem._recipes = null

  @totalGemCount: ->
    @all().inject 0, (sum, recipe) ->
      if recipe.extended
        sum
      else
        recipe.gems.length * recipe.quantity + sum

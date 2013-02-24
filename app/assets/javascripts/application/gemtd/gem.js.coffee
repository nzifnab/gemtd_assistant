class window.Gem
  constructor: (@quality, @type) ->
    @selectedCount = 0

  fullName: ->
    @_fullName ?= [@displayQuality(), @displayType()].compact().join(" ")

  displayQuality: ->
    @_displayQuality ?= if @quality.name == "Normal" then null else @quality.name

  displayType: ->
    @_displayType ?= @type.name

  recipes: ->
    @_recipes ?= Recipe.findAllByGem(this)

  toString: ->
    @fullName()

  downgrade: ->
    @_downgrade ?= Gem.find(GemQuality.find(@quality.rank - 1), @type)

  upgrade: ->
    @_upgrade ?= Gem.find(GemQuality.find(@quality.rank + 1), @type)

  recipeQuantity: ->
    @recipes().inject(0, ((sum, recipe) -> sum+recipe.quantity))

  selectedQuantity: ->
    Gem.selectedGems.countOfValue(this)

  remainingQuantity: ->
    [@recipeQuantity() - @selectedQuantity(), 0].max()

  priority: ->
    @recipes().max -1, (recipe) =>
      recipe.priority

  isSaturated: ->
    @selectedQuantity() >= @recipeQuantity()

  outnumbersRecipeSiblings: ->
    for recipe in @recipes()
      for gem in recipe.gems
        return true if gem.selectedQuantity() < @selectedQuantity()
    false

  select: ->
    tmpl = JST["selected_gem"](gem: this)
    $(".js-selected-gems").append tmpl
    Gem.selectedGems.push(this)

  @selectedGems: []

  @all: ->
    @allGems ?= do =>
      g = []
      $.each GemQuality.all(), (i, quality) ->
        $.each GemType.all(), (i, type) ->
          g.push new Gem(quality, type)
      g

  @findByFullName: (fullName) ->
    @allByName ?= {}
    @allByName[fullName] ?= do =>
      @all().find (gem) =>
        gem.fullName() == fullName

  @find: (quality, type) ->
    quality = quality?.name ? quality
    type = type?.name ? type
    return undefined unless quality? && type?

    quality = null if quality == "Normal"
    type = "God" if quality == "Stone of"
    @findByFullName([quality, type].compact().join(" "))

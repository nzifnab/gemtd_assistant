class window.GemQuality
  constructor: (@name, @rank) ->

  toString: ->
    @name

  @all: ->
    @_all ?= do =>
      q = []
      lastRank = 0
      $(".btn-group.js-gem-quality .btn").each (i, qualityButton) ->
        q.push new GemQuality($(qualityButton).data('value'), i+1)
        lastRank = i+1
      q.push new GemQuality("Great", lastRank + 1)
      q.push new GemQuality("Stone Of", lastRank + 2)
      q

  @find: (rank) ->
    @allByRank ?= {}
    @allByRank[rank] ?= do =>
      @all().find (quality) =>
        quality.rank == rank

  @findByName: (name) ->
    @allByName ?= {}
    @allByName[name] ?= do =>
      @all().find (quality) =>
        quality.name == name

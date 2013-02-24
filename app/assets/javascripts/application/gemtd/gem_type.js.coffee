class window.GemType
  constructor: (@name) ->

  toString: ->
    @name

  @all: ->
    @_all ?= do =>
      t = []
      $(".btn-group.js-gem-type .btn").each (i, typeButton) ->
        t.push new GemType($(typeButton).data('value'))
      t.push new GemType("God")
      t

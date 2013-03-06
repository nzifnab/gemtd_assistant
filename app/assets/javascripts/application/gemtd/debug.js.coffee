class window.Logger
  @__debug: false

  @debug: (values...) ->
    for val in values
      console.log val if @__debug

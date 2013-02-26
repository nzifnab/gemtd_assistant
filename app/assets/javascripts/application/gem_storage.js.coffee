$ ->
  $("body").on "click", ".js-save-configuration", (e) ->
    e.preventDefault()

    key = $("#configuration_name").val()
    if key && key != "__default"
      saveConfig(key)
      $(this).closest(".modal").modal('hide')

  $("body").on "click", ".js-load-configuration", (e) ->
    e.preventDefault()
    loadConfig($(this).closest("li").data('value'))
    $(this).closest(".modal").modal('hide')


  $("body").on "click", ".js-delete-configuration", (e) ->
    e.preventDefault()
    key = $(this).closest("li").data("value")
    removeConfig(key)

  $("body").on "click", ".js-select-configuration", (e) ->
    e.preventDefault()
    key = $(this).closest("li").data("value")
    $("#configuration_name").val(key)

  $("body").on "click", ".js-load-default-config", (e) ->
    e.preventDefault()

    defaultConfig = {}
    for recipe in Recipe.all()
      defaultConfig[recipe.name] = {
        priority: 1,
        quantity: 1
      }

    Recipe.import(defaultConfig)
    GemSuggestor.refreshSuggestion()
    saveConfig("__default")


  loadConfig("__default")
  for configName in $.jStorage.index()
    addConfig(configName)

addConfig = (name) ->
  unless name == "__default"
    tmpl = JST["saveable_configuration"](configName: name)
    $("#save-window .js-saved-configurations ul").append(tmpl)

    tmpl = JST["loadable_configuration"](configName: name)
    $("#load-window .js-saved-configurations ul").append(tmpl)

removeConfig = (name) ->
  saveDomNode = $(".js-saveable-configuration[data-value='#{name}']")
  loadDomNode = $(".js-loadable-configuration[data-value='#{name}']")

  $.jStorage.deleteKey(name)
  saveDomNode.remove()
  loadDomNode.remove()

window.saveConfig = (name) ->
  $.jStorage.set(name, Recipe.export())
  addConfig(name)
  setTitle(name)

window.loadConfig = (name) ->
  Recipe.import $.jStorage.get(name, {})
  setTitle(name)
  GemSuggestor.refreshSuggestion()

setTitle = (name) ->
  title = if name == "__default" then "Recipes" else "#{name} Recipes"
  $(".js-recipe-title").text(title)

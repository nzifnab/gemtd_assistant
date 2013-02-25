$ ->
  $("body").on "click", ".js-save-configuration", (e) ->
    e.preventDefault()

    key = $("#configuration_name").val()
    return unless key
    $.jStorage.set(key, Recipe.export())
    addConfig(key)
    $(this).closest(".modal").modal('hide')

  $("body").on "click", ".js-delete-configuration", (e) ->
    e.preventDefault()
    key = $(this).closest("li").data("value")
    $(this).closest(".btn-group").data("value", null).find(".btn").removeClass("active")
    removeConfig(key)

  $("body").on "click", ".js-select-configuration", (e) ->
    e.preventDefault()
    key = $(this).closest("li").data("value")
    $("#configuration_name").val(key)

  for configName in $.jStorage.index()
    addConfig(configName)

addConfig = (name) ->
  tmpl = JST["saveable_configuration"](configName: name)
  $("#save-window .js-saved-configurations ul").append(tmpl)

  tmpl = JST["loadable_configuration"](configName: name)
  $("#load-window .js-saved-configurations ul").append(tmpl)

removeConfig = (name) ->
  saveDomNode = $(".js-saveable-configuration[data-value='#{name}']")

  $.jStorage.deleteKey(name)
  saveDomNode.remove()

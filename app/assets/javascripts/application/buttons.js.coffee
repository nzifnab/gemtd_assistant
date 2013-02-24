$ ->
  keyCode = 97
  keyCodeMap = {}
  alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
    'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
    'u', 'v', 'w', 'x', 'y', 'z']
  for val in alphabet
   keyCodeMap[keyCode++] = val
  keyCode = 65
  for val in alphabet
    keyCodeMap[keyCode++] = val
  keyCodeMap[13] = '%enter'
  keyCodeMap[32] = '%space'
  keyCodeMap[8] = '%backspace'

  $('body').on "click", ".btn-group[data-toggle='buttons-radio'] .btn", (e) ->
    activateRadioButton($(this))

  activateRadioButton = ($element) ->
    $element.parent('.btn-group').data('value', $element.data('value')).children('.btn').removeClass('active')
    $element.addClass('active')

  $('body').on "keypress", (e) ->
    keyPressed = keyCodeMap[e.keyCode || e.which]

    if keyPressed? && ($element = $(this).find("[data-hotkey='#{keyPressed}']")).length > 0
      e.preventDefault()
      $element.first().trigger('click')

  $("[data-hotkey]").each ->
    registerHotkey(this)

window.registerHotkey = (element) ->
  val = $(element).text()
  hotkey = $(element).data('hotkey')
  return unless hotkey?

  if match = val.match(new RegExp(hotkey, 'i'))
    match = match[0]
    underlinedHotkey = "<strong class='underline'>#{match}</strong>"
    val = val.replace(match, underlinedHotkey)
  else
    val = "#{val} <em>(#{hotkey.replace('%', '')})</em>"

  $(element).html(val)

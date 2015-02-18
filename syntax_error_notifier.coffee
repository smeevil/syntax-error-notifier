@SyntaxErrorNotifier =
  config:
    checkInterval: 1
    obtrusive: true

  ParseMsg: (msg) ->
    matches =  msg.match /\(compiling\s(.*?)\)/
    unless @config.obtrusive
      parts=msg.split("\n")
      msg = "#{parts[6]} #{parts[7]}"
    return msg

  GetMessage: (callback)->
    $.get "http://#{window.location.host}", (message) ->
      callback(message)

  UpdateMessage: (message) ->
    modal = $('.syntax-error-modal')
    unless modal.length
      modal=$('<div/>').addClass('syntax-error-modal')
      modal.addClass('obtrusive') if @config.obtrusive
      modal.appendTo($('body'))

    messageElement = $('.syntax-error-modal .message')
    unless messageElement.length
      messageElement=$('<div/>').addClass('message')
      messageElement.appendTo(modal)
      if @config.obtrusive
        messageElement.addClass('obtrusive')
      else
        messageElement.addClass('unobtrusive')

    msg=$('<p/>').html(@ParseMsg(message))
    messageElement.html(msg)

    $(modal).fadeIn() if modal.is(':hidden')

    if @config.obtrusive && messageElement.is(':hidden')
      $(messageElement).fadeIn()


window.onerror = (message, filename, lineno, colno, error)->
  console.log "CAUGHT"
  console.log message
  console.log filename
  console.log lineno
  console.log colno
  console.log error

  #first is safari, latter is chrome
  if message=='SyntaxError: JSON Parse error: Unexpected identifier "Your"' || "Uncaught SyntaxError: Unexpected token Y"
    console.log "passing"
    SyntaxErrorNotifier.GetMessage (message)->
      SyntaxErrorNotifier.UpdateMessage(message)

      setInterval ->
        SyntaxErrorNotifier.GetMessage (message)->
          if message.match(/^Your app is crashing/)
            SyntaxErrorNotifier.UpdateMessage(message)
          else
            location.reload()
      , SyntaxErrorNotifier.config.checkInterval*1000
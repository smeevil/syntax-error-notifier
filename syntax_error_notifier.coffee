@SyntaxErrorNotifier =
  config:
    checkInterval: 1
    editorProtocol: 'x-mine'

  ParseMsg: (msg) ->
    matches =  msg.match /\(compiling\s(.*?)\)/
    msg = msg.replace matches[1], "compiling <a href='#{@config.editorProtocol}://#{matches[1]}'>#{matches[1]}</a>"
    return msg

  GetMessage: (callback)->
    $.get "http://#{window.location.host}", (message) ->
      callback(message)

  UpdateMessage: (message) ->
    modal = $('.syntax-error-modal')
    unless modal.length
      modal=$('<div/>').addClass('syntax-error-modal')
      modal.appendTo($('body'))
    modal.html('')
    $('<p/>').html(@ParseMsg(message)).appendTo(modal)



window.onerror = (message, filename, lineno, colno, error)->
  if message=='SyntaxError: JSON Parse error: Unexpected identifier "Your"'
    SyntaxErrorNotifier.GetMessage (message)->
      SyntaxErrorNotifier.UpdateMessage(message)

      setInterval ->
        SyntaxErrorNotifier.GetMessage (message)->
          if message.match(/^Your app is crashing/)
            SyntaxErrorNotifier.UpdateMessage(message)
          else
            location.reload()
      , SyntaxErrorNotifier.config.checkInterval*1000
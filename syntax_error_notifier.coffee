@SyntaxErrorNotifier =
  config:
    checkInterval: 1
    mode: 'obtrusive'
    debug: false
    clearConsoleOnReload: true
    filterDotMeteor: true
    editorProtocol: 'x-mine'
    linkFiles: true

  Simulate: ->
    message='''
Your app is crashing. Here's the latest log.


/Users/smeevil/.meteor/packages/meteor-tool/.1.0.41.v0q0sk++os.osx.x86_64+web.browser+web.cordova/meteor-tool-os.osx.x86_64/dev_bundle/server-lib/node_modules/fibers/future.js:173
throw(ex);
^
ReferenceError: type is not defined
at Package (/Users/smeevil/dev/meteor/bac/.meteor/local/build/programs/server/packages/smeevil_paypal-checkout.js:70:15)
at /Users/smeevil/dev/meteor/bac/.meteor/local/build/programs/server/packages/smeevil_paypal-checkout.js:80:4
at /Users/smeevil/dev/meteor/bac/.meteor/local/build/programs/server/packages/smeevil_paypal-checkout.js:87:3
at /Users/smeevil/dev/meteor/bac/.meteor/local/build/programs/server/boot.js:205:10
at Array.forEach (native)
at Function._.each._.forEach (/Users/smeevil/.meteor/packages/meteor-tool/.1.0.41.v0q0sk++os.osx.x86_64+web.browser+web.cordova/meteor-tool-os.osx.x86_64/dev_bundle/server-lib/node_modules/underscore/underscore.js:79:11)
at /Users/smeevil/dev/meteor/bac/.meteor/local/build/programs/server/boot.js:116:5

Exited with code: 8
Your application is crashing. Waiting for file change.
'''
    @UpdateMessage(message)


  ParseMsg: (msg) ->
    if @config.mode=='unobtrusive'
      parts=msg.split("\n")
      msg = "#{parts[6]} #{parts[7]}"
    else
      msg = @FilterDotMeteor(msg) if @config.filterDotMeteor
      msg = @CleanMessage(msg)

      lines=[]
      for line in msg.split("\n")
        line = @HighlightErrors(line)
        line = @LinkFiles(line)
        lines.push line
      msg = lines.join("\n")

    return msg

  GetMessage: (callback)->
    $.get "http://#{window.location.host}", (message) ->
      callback(message)

  UpdateMessage: (message, header="Your app is crashing !") ->
    container = $('.syntax-error-container')
    unless container.length
      template = _.template("
        <div class='syntax-error-container <%= mode %>'>
          <div class='syntax-error-modal'>
          <div class='syntax-error-header'><%= header %></div>
          <div class='syntax-error-message'>
            <%= message %>
          </div>
        </div>
      ");
      $(template(mode: SyntaxErrorNotifier.config.mode, header: header, message: message)).appendTo($('body'))
      container = $('.syntax-error-container')

    headerElement = container.find('.syntax-error-header')
    messageElement = container.find('.syntax-error-message')

    headerElement.html(header)
    messageElement.html($('<p/>').html(@ParseMsg(message)))

    container.fadeIn() if container.is(':hidden')

#    unless @config.mode=='unobtrusive'
#      container.fadeIn() if container.is(':hidden')


  FilterDotMeteor: (msg) ->
    lines=[]
    for line in msg.split("\n")
      continue unless line.match(/^at Package/)
      lines.push line
    msg = lines.join("\n")

    return msg

  CleanMessage: (msg) ->
    lines=[]
    for line in msg.split("\n")
      if line.match /\/\.meteor\//
        continue if line.match(/^Your app is crashing|throw(ex);|\^/)
      lines.push line
    msg = lines.join("\n")

  HighlightErrors: (line)->
    line = "<span class='highlight'>#{line}</span>" if line.match /^ReferenceError/
    return line

  LinkFiles: (line)->
    matches = line.match /^at\s.*?(\/.*?):/
    line = line.replace matches[1], "<a href='#{@config.editorProtocol}://open?file=#{matches[1]}'>#{matches[1]}</a>" if matches && matches[1]?
    return line

if SyntaxErrorNotifier.config.clearConsoleOnReload
  window.onbeforeunload = ->
    console.clear()

window.onerror = (message, filename, lineno, colno, error)->
  if SyntaxErrorNotifier.config.debug
    console.log "ERROR CAUGHT"
    console.log message
    console.log filename
    console.log lineno
    console.log colno
    console.log error

  #first is safari, latter is chrome
  if message in ['SyntaxError: JSON Parse error: Unexpected identifier "Your"',
                 "Uncaught SyntaxError: Unexpected token Y"]
    SyntaxErrorNotifier.GetMessage (message)->
      SyntaxErrorNotifier.UpdateMessage(message)

      setInterval ->
        SyntaxErrorNotifier.GetMessage (message)->
          if message.match(/^Your app is crashing/)
            SyntaxErrorNotifier.UpdateMessage(message)
          else
            location.reload()
      , SyntaxErrorNotifier.config.checkInterval * 1000

$ ->
  console.log "simulating error"
  SyntaxErrorNotifier.Simulate()
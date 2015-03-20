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
    message = '''Your app is crashing. Here's the latest log.

=> Meteor 1.0.4.1 is available. Update this project with 'meteor update'.
Started MongoDB.
Started your app.

App running at: http://localhost:3000/
=> Client modified -- refreshing (x26)
Error serving static file Error: ENOENT, stat '/Users/smeevil/dev/meteor/interface/.meteor/local/build/programs/web.browser/15479cdc50c5eff57439eff875263dd57d4fbcb7.css'
=> Client modified -- refreshing (x4)
Errors prevented startup:

While building the application:
<runJavaScript-14>:148:11: client/lib/03-stats.coffee:1: unexpected ! (compiling client/lib/03-stats.coffee) (at handler)

Your application has errors. Waiting for file change.
'''
    @UpdateMessage(message)


  ParseMsg: (msg) ->
    msg = @FilterDotMeteor(msg) if @config.filterDotMeteor
    msg = @CleanMessage(msg)
    console.log "Cleaned: #{msg}"

    lines = []
    for line in msg.split("\n")
      line = @HighlightErrors(line)
      line = @LinkFiles(line)
      lines.push line

    if @config.mode == 'unobtrusive'
      msg = "#{lines[0]} : #{lines[1]}"
    else
      msg = lines.join("\n")
    console.log "MESSAGE: #{msg}"
    return msg

  GetMessage: (callback) ->
    $.get "http://#{window.location.host}", (message) ->
      console.log "MESSAGE CALLBACK"
      console.log message
      callback(message)

  UpdateMessage: (message, header = "Your app is crashing !") ->
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
      ")
      $(template(mode: SyntaxErrorNotifier.config.mode, header: header, message: message)).appendTo($('body'))
      container = $('.syntax-error-container')

    headerElement = container.find('.syntax-error-header')
    messageElement = container.find('.syntax-error-message')

    headerElement.html(header)
    messageElement.html($('<p/>').html(@ParseMsg(message)))

    container.fadeIn() if container.is(':hidden')


  FilterDotMeteor: (msg) ->
    lines = []
    for line in msg.split("\n")
      if line.match /\/\.meteor\//
        continue unless line.match /at Package/
      lines.push line
    msg = lines.join("\n")

    return msg

  CleanMessage: (msg) ->
    whileBuilding = msg.match(/While building the application/g)
    whileBuildingEncountered = false
    lines = []
    for line in msg.split("\n")
      if whileBuilding && !whileBuildingEncountered
        whileBuildingEncountered = true if line.match(/While building the application/)
        continue
      else
        continue if line.match(/meteor-tool/)
        continue if line.match(/Your app.*? is crashing/)
        continue if line.match(/throw\(ex\)/)
        continue if line.match(/^\^/)
        continue unless line.match(/\S/)
        continue if line.match(/Your application has errors/)
        continue if line.match(/Exited with/)
        lines.push line
    msg = lines.join("\n")


  HighlightErrors: (line) ->
    line = "<span class='highlight'>#{line}</span>" if line.match /^ReferenceError/
    return line

  LinkFiles: (line) ->
    matches = line.match /^at\s.*?(\/.*?):/
    line = line.replace matches[1], "<a href='#{@config.editorProtocol}://open?file=#{matches[1]}'>#{matches[1]}</a>" if matches && matches[1]?
    return line

if SyntaxErrorNotifier.config.clearConsoleOnReload
  window.onbeforeunload = ->
    console.clear()

window.onerror = (message, filename, lineno, colno, error) ->
  if SyntaxErrorNotifier.config.debug
    console.log "ERROR CAUGHT"
    console.log message
    console.log filename
    console.log lineno
    console.log colno
    console.log error

  #first is safari, latter is chrome
  if message in [
    'SyntaxError: JSON Parse error: Unexpected identifier "Your"',
    "Uncaught SyntaxError: Unexpected token Y"
  ]
    SyntaxErrorNotifier.GetMessage (message) ->
      SyntaxErrorNotifier.UpdateMessage(message)

      setInterval ->
        SyntaxErrorNotifier.GetMessage (message) ->
          if message.match(/^Your app is crashing/)
            SyntaxErrorNotifier.UpdateMessage(message)
          else
            location.reload()
      , SyntaxErrorNotifier.config.checkInterval * 1000

#$ ->
#  console.log "simulating error"
#  SyntaxErrorNotifier.Simulate()
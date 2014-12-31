# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

#  Listen to a key and respond
#  1. listen to a key and map it to a function
#  2. catch the key and call the function
#  3. extend subscriber so we can subscribe and unsubscribe
{Subscriber} = require "emissary"

module.exports=
class KeyWatcher
  Subscriber.includeInto(this)

  constructor: () ->

  keybind: (objdoc, thekey, themodifier, parent_this, callback) ->
    console.log("initializing key watcher #{thekey}")
    @watchkey = thekey
    @watchmodifier = themodifier
    @subscribe objdoc, "keyup", (e) => @keyUpAction(e, callback, parent_this)

  keyUpAction: (event, callback, parent_this) ->
    {key, modifiers} = @keystrokeForKeyboardEvent(event)
    return unless key
    console.log("key to watch -> #{this.watchkey}")
    if ( (RegExp('^'+ this.watchkey + '$').test key) &&
         (this.watchmodifier == null) ) ||
       ( (RegExp('^'+ this.watchkey + '$').test key) &&
         (RegExp('^'+ this.watchmodifier + '$').test modifiers) )
      console.log("#{this.watchkey} key pressed")
      callback(parent_this)
      # @callback.call()

  keystrokeForKeyboardEvent: (event) ->
    keyIdentifier = event.originalEvent.keyIdentifier
    if keyIdentifier.indexOf('U+') is 0
      hexCharCode = keyIdentifier[2..]
      charCode = parseInt(hexCharCode, 16)
      charCode = event.which if not @isAscii(charCode) and @isAscii(event.which)
      key = @keyFromCharCode(charCode)
    else
      key = keyIdentifier.toLowerCase()

    modifiers = []
    modifiers.push 'ctrl' if event.ctrlKey
    modifiers.push 'alt' if event.altKey
    if event.shiftKey
      # Don't push 'shift' when modifying symbolic characters like '{'
      modifiers.push 'shift' unless /^[^A-Za-z]$/.test(key)
      # Only upper case alphabetic characters like 'a'
      key = key.toUpperCase() if /^[a-z]$/.test(key)
    else
      key = key.toLowerCase() if /^[A-Z]$/.test(key)

    modifiers.push 'cmd' if event.metaKey

    key = null if key in ['meta', 'shift', 'control', 'alt']

    {key, modifiers}

  keyFromCharCode: (charCode) ->
    switch charCode
      when 8 then 'backspace'
      when 9 then 'tab'
      when 13 then 'enter'
      when 27 then 'escape'
      when 32 then 'space'
      when 127 then 'delete'
      else String.fromCharCode(charCode)

  isAscii: (charCode) ->
    0 <= charCode <= 127

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
{Subscriber} = require 'emissary'
{$, View} = require 'atom'

module.exports =
  class StatusView extends View
    Subscriber.includeInto(this)

    @content = (params) ->
      @div class: 'git-review overlay from-bottom', =>
        @div class: "#{params.type} message", params.message

    initialize: ->
      @subscribe $(window), 'core:cancel', => @detach()
      atom.workspaceView.append(this)
      setTimeout =>
        @detach()
      , atom.config.get('git-review.messageTimeout') * 1000

    detach: ->
      super
      @unsubscribe()

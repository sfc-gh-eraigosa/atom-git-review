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

Path = require 'path'
fs = require 'fs-plus'

{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'


module.exports =
class ReviewSubmitView extends SelectListView

  initialize: (@data, @onlyCurrentFile) ->
    super
    @addClass 'overlay from-top'
    @parseData()

  parseData: ->
    @data = @data.split("\n")[...-1]
    @setItems(
      for item in @data when item != ''
        {hash: item}
        # tmp = item.match /([\w\d]{7});\|(.*);\|(.*);\|(.*)/
        # {hash: tmp?[1], author: tmp?[2], title: tmp?[3], time: tmp?[4]}
    )
    atom.workspaceView.append this
    @focusFilterEditor()

  getFilterKey: -> 'title'

  viewForItem: (commit) ->
    $$ ->
      @li =>
        @div class: '', "#{commit.hash}"
        # @div class: 'text-highlight text-huge', commit.title
        # @div class: '', "#{commit.hash} by #{commit.author}"
        # @div class: 'text-info', commit.time

  confirmed: ({hash}) ->
    @cancel()

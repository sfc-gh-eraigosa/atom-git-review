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

{$$, BufferedProcess, SelectListView} = require 'atom'

review = require '../review'
StatusView = require './status-view'
ReviewDownloadSelectChange = require './review-download-select-change'

module.exports =
class CherryPickSelectBranch extends SelectListView

  initialize: (items, @currentHead) ->
    super
    @addClass 'overlay from-top'
    @setItems items

    atom.workspaceView.append this
    @focusFilterEditor()

  viewForItem: (item) ->
    $$ ->
      @li item

  confirmed: (item) ->
    @cancel()
    args = [
      'log'
      '--cherry-pick'
      '-z'
      '--format=%H%n%an%n%ar%n%s'
      "#{@currentHead}...#{item}"
    ]

    git.cmd
      args: args
      stdout: (data) ->
        @save ?= ''
        @save += data
      exit: (exit) ->
        if exit is 0 and @save?
          new CherryPickSelectCommits(@save.split('\0')[...-1])
          @save = null
        else
          new StatusView(type: 'warning', message: "No commits available to cherry-pick.")

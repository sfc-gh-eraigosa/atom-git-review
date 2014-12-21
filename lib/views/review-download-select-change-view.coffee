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

{$, $$, EditorView} = require 'atom'

git = require '../git'
OutputView = require './output-view'
StatusView = require './status-view'
SelectListMultipleView = require './select-list-multiple-view'

module.exports =
class CherryPickSelectCommits extends SelectListMultipleView

  initialize: (data) ->
    super
    @addClass('overlay from-top')
    @setItems(
      for item in data
        item = item.split('\n')
        {hash: item[0], author: item[1], time: item[2], subject: item[3]}
    )
    atom.workspaceView.append(this)
    @focusFilterEditor()

  getFilterKey: ->
    'hash'

  addButtons: ->
    viewButton = $$ ->
      @div class: 'buttons', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-error inline-block-tight btn-cancel-button', 'Cancel'
        @span class: 'pull-right', =>
          @button class: 'btn btn-success inline-block-tight btn-pick-button', 'Cherry-Pick!'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      @complete() if $(target).hasClass('btn-pick-button')
      @cancel() if $(target).hasClass('btn-cancel-button')

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        @div class: 'text-highlight inline-block pull-right', style: 'font-family: monospace', =>
          if matchedStr? then @raw(matchedStr) else @span item.hash
        @div class: 'text-info', "#{item.author}, #{item.time}"
        @div class: 'text-warning', item.subject

  completed: (items) ->
    @cancel()
    commits = (item.hash for item in items)
    git.cmd
      args: ['cherry-pick'].concat(commits),
      stdout: (data) ->
        new StatusView(type: 'success', message: data)

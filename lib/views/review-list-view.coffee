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

Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{$$, SelectListView} = require 'atom-space-pen-views'

notifier = require '../notifier'
review = require '../review'

module.exports=
class ReviewListView extends SelectListView

  viewForItem: ({id, branch, title}) ->
    $$ ->
      @li =>
        @div class: 'pull-right highlight',
             style: 'white-space: pre-wrap; font-family: monospace', =>
               @span id
               @span branch
               @span title

  initialize:(@repo, @data) ->
    super
    @show()
    @parseData()
    @currentPane = atom.workspace.getActivePane()
    console.log("initialize ReviewListView")

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.destroy()

  parseData: ->
    items = @data.split("\n")
    changes = []
#    for line in items when line != '' && /^(.*)\[0m\s(.*)\[0m\s(.*)/.test line
    for item in items when item != ''
      item = item.replace(/\[[1-9]+m/g,'')
      parse_data = item.match(/^([0-9]+)\s+(\w+)\s+(.*)/)
      if parse_data != null && parse_data.length > 0
        changes.push {
          id: parse_data[1].replace(/\[0m/,''),
          branch: parse_data[2].replace(/\[0m/,''),
          title: parse_data[3]
        }
    @setItems changes
    @focusFilterEditor()

  confirmed: (item) ->
    console.log "item -> #{item.id} selected"
    @reviewpull item
    @cancel()

  reviewpull: (item) ->
    # clean id
    if typeof(item.id) == 'undefined' ||
       item.id == null ||
       item.id == ''
      console.log "nothing to download for id => #{item.id}"
      return
    item.id = item.id.replace(RegExp(String.fromCharCode(27),'g'),'')

    review.download
      id: item.id
      patch: null
      cwd: @repo.getWorkingDirectory()
      stdout: (data) ->
        notifier.addSuccess data
        atom.project.setPath(atom.project.getPath())
      stderr: (data) =>
        notifier.addSuccess data.toString()
        atom.workspace.observeTextEditors (editor) =>
          if filepath = editor.getPath()
            fs.exists filepath, (exists) =>
              editor.destroy() if not exists
        @currentPane.activate()

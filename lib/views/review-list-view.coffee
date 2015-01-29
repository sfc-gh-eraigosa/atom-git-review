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

{$$, SelectListView} = require 'atom'
StatusView = require './status-view'
review = require '../review'

module.exports=
class ReviewListView extends SelectListView
  constructor: ->
    super

  viewForItem: ({id, branch, title}) ->
    $$ ->
      @li =>
        @div
          class: 'pull-right highlight'
          style: 'white-space: pre-wrap; font-family: monospace'
        @span id
        @span branch
        @span title

  initialize:(data) ->
    super
    @addClass 'overlay from-top'
    @setItems @parseData data
    atom.workspaceView.append this
    @focusFilterEditor()
    console.log("initialize ReviewListView")

  parseData: (lines) ->
    for line in lines when line != '' && /^(.*)\[0m\s(.*)\[0m\s(.*)/.test line
      line = line.replace(/\[[1-9]+m/g,'')
      parse_data = line.match /^(.*)\[0m\s(.*)\[0m\s(.*)/
      if parse_data.length > 0
        {
          id: parse_data[1].replace(/\[0m/,''),
          branch: parse_data[2].replace(/\[0m/,''),
          title: parse_data[3]
        }

  confirmed: (item) ->
    console.log "item -> #{item.id} selected"
    @cancel()
    if typeof(item.id) == 'undefined' ||
       item.id == null ||
       item.id == ''
      console.log "nothing to download for id => #{item.id}"
      return
    # clean id
    item.id = item.id.replace(RegExp(String.fromCharCode(27),'g'),'')
    review.download
      id: item.id,
      patch: null,
      stdout: (data) ->
        new StatusView(type: 'success', message: data)
        atom.project.setPath(atom.project.getPath())

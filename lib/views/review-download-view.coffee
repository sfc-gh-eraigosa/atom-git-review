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

{$, BufferedProcess, EditorView, View} = require 'atom'
StatusView = require './status-view'
review = require '../review'

module.exports=
class ReviewDownloadView extends View

  @content: ->
    @div class: 'overlay from-top', =>
      @div class: 'block', =>
        @subview 'gerritChange', new EditorView(mini: true, placeholderText: 'Gerrit change request')
      @div class: 'block', =>
        @subview 'gerritPatch', new EditorView(mini: true, placeholderText: '(optional) Patch Number')
      @div class: 'block', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-success inline-block-tight gp-confirm-button', click: 'downloadChange', 'pull change'
        @span class: 'pull-right', =>
          @button class: 'btn btn-error inline-block-tight gp-cancel-button', click: 'abort', 'Cancel'

  initialize: ->
    atom.workspaceView.append this
    @gerritChange.focus()
    @on 'core:cancel', => @abort()

  abort: ->
    @detach()

  downloadChange: ->
    change = id: @gerritChange.text(), patch: @gerritPatch.text()
    if /\(optional\) Patch Number/.test(change.patch)
      change.patch = null
    # check for bad input, both id and patch should be a integer
    if !review.isInt(change.id)
      new StatusView(type: 'alert', message: "change id should be an integer, got #{change.id}")
      return
    if typeof(change.patch) != 'undefined' &&
       change.patch != null &&
       !review.isInt(change.patch)
      new StatusView(type: 'alert', message: "patch should be an integer, got #{change.patch}")
      return
    review.download
      id: change.id,
      patch: change.patch,
      stdout: (data) ->
        new StatusView(type: 'success', message: data)
        atom.project.setPath(atom.project.getPath())
    @detach()

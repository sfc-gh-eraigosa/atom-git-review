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
KeyWatcher = require '../models/keywatcher'

module.exports=
class ReviewDownloadView extends View
  constructor: ->
    @keyready = false
    @gerritChange = null
    @gerritPatch = null
    @keywatcher1 = null
    @keywatcher2 = null
    super

  @content: ->
    @div class: 'overlay from-top', =>
      @div class: 'block', =>
        @subview 'gerritChange', new EditorView(mini: true, placeholderText: 'Gerrit change request')
      @div class: 'block', =>
        @subview 'gerritPatch', new EditorView(mini: true, placeholderText: '(optional) Patch Number')
      @div class: 'block', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-error inline-block-tight gr-cancel-button', click: 'abort', outlet: 'grCancel', 'Cancel'
        @span class: 'pull-right', =>
          @button class: 'btn btn-success inline-block-tight gr-confirm-button', click: 'downloadChange', outlet: 'grConfirm', 'pull change'

  initialize: ->
    atom.workspaceView.append this
    @gerritChange.focus()
    @on 'core:cancel', => @abort()
    @keywatcher1 = new KeyWatcher()
    @keywatcher1.keybind $(document), 'enter', null, this, @downloadChange
    @keywatcher2 = new KeyWatcher()
    @keywatcher2.keybind $(document), 'esc', null, this, @abort
    @keyready = true

  removeKeyWatchers:(instance_this) ->
    if ( typeof @keywatcher1 != 'undefined' ) &&
       ( @keywatcher1 != null )
      @keywatcher1.unsubscribe()
      @keywatcher1 = null

    if ( typeof instance_this != 'undefined' ) &&
       ( typeof instance_this.keywatcher1 != 'undefined' ) &&
       (instance_this.keywatcher1 != null) &&
       (typeof this.keywatcher1) == 'undefined'
      instance_this.keywatcher1.unsubscribe()
      instance_this.keywatcher1 = null

    if ( typeof @keywatcher2 != 'undefined' ) &&
       ( @keywatcher2 != null )
      @keywatcher2.unsubscribe()
      @keywatcher2 = null

    if ( typeof instance_this != 'undefined' ) &&
       ( typeof instance_this.keywatcher2 != 'undefined' ) &&
       (instance_this.keywatcher2 != null) &&
       (typeof this.keywatcher2) == 'undefined'
      instance_this.keywatcher2.unsubscribe()
      instance_this.keywatcher2 = null

  downloadChange:(instance_this) ->
    change = null
    patch  = null
    ready  = null
    remove_method = null
    parent_instance = null
    # this isn't ideal, but currently im not
    # sure how to pass the parent class instance variables
    # from event keys.
    if (typeof instance_this) != 'undefined' &&
       (typeof this.gerritChange) == 'undefined'
      change = instance_this.gerritChange.text()
      patch  = instance_this.gerritPatch.text()
      ready  = instance_this.keyready
      remove_method = instance_this.removeKeyWatchers
      parent_instance = instance_this

    if (typeof this.gerritChange) != 'undefined'
      change = @gerritChange.text()
      patch  = @gerritPatch.text()
      ready  = @keyready
      remove_method = @removeKeyWatchers
      parent_instance = this

    return if change == null
    change = id: change, patch: patch
    console.log("change => #{change}")
    return if /Gerrit change request/.test(change.id)

    # handel the change
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

    # cleanup
    remove_method.call(parent_instance)
    parent_instance.detach()
    console.log('clicked download change')

  abort:(instance_this) ->
    ready = null
    remove_method = null
    parent_instance = null
    # this isn't ideal, but currently im not
    # sure how to pass the parent class instance variables
    # from event keys.
    if (typeof instance_this) != 'undefined'
      ready  = instance_this.keyready
      remove_method = instance_this.removeKeyWatchers
      parent_instance = instance_this

    if (typeof this.keyready) != 'undefined'
      ready  = @keyready
      remove_method = @removeKeyWatchers
      parent_instance = this

    return if ready == null
    remove_method.call(parent_instance)
    parent_instance.detach()
    console.log('clicked abort')

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
_ = require 'underscore-plus'
{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'

review = require '../review'
ReviewCommands = require '../git-review-commands'
fuzzy = require('../models/fuzzy').filter

module.exports =
class ReviewPaletteView extends SelectListView

  initialize: ->
    super
    @addClass('git-review')
    @toggle()

  getFilterKey: ->
    'description'

  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else
      @show()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

  attach: ->
#    @storeFocusedElement()
#
#    if @previouslyFocusedElement[0] and @previouslyFocusedElement[0] isnt document.body
#      @commandElement = @previouslyFocusedElement
#    else
#      @commandElement = atom.workspaceView
#    @keyBindings = atom.keymap.findKeyBindings(target: @commandElement[0])
#
#    commands = []
#    for command in ReviewCommands()
#      commands.push({name: command[0], description: command[1], func: command[2]})
#    commands = _.sortBy(commands, 'name')
#    @setItems(commands)
#
#    @focusFilterEditor()

  populateList: ->
    return unless @items?

    filterQuery = @getFilterQuery()
    if filterQuery.length
      options =
        pre: '<span class="text-warning" style="font-weight:bold">'
        post: "</span>"
        extract: (el) => if @getFilterKey()? then el[@getFilterKey()] else el
      filteredItems = fuzzy(filterQuery, @items, options)
    else
      filteredItems = @items

    @list.empty()
    if filteredItems.length
      @setError(null)
      for i in [0...Math.min(filteredItems.length, @maxItems)]
        item = filteredItems[i].original ? filteredItems[i]
        itemView = $(@viewForItem(item, filteredItems[i].string ? null))
        itemView.data('select-list-item', item)
        @list.append(itemView)

      @selectItemView(@list.find('li:first'))
    else
      @setError(@getEmptyMessage(@items.length, filteredItems.length))

  hide: ->
    @panel?.hide()

  viewForItem: ({name, description}, matchedStr) ->
    $$ ->
      @li class: 'command', 'data-command-name': name, =>
        if matchedStr? then @raw(matchedStr) else @span description

  confirmed: ({func}) ->
    @cancel()
    func()

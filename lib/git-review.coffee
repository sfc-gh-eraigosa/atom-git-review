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

{$} = require 'atom'
review = require './review'
ReviewPaletteView = require './views/review-palette-view'

module.exports =
  config:
    includeStagedDiff:
      title: 'Include staged diffs?'
      type: 'boolean'
      default: true
    openInPane:
      type: 'boolean'
      default: true
      description: 'Allow commands to open new panes'
    splitPane:
      title: 'Split pane direction'
      type: 'string'
      default: 'right'
      description: 'Where should new panes go?(right or left)'
    wordDiff:
      type: 'boolean'
      default: true
      description: 'Should word diffs be highlighted in diffs?'
    amountOfCommitsToShow:
      type: 'integer'
      default: 25
    reviewPath:
      type: 'string'
      default: 'git-review'
      description: 'Where is your git-review?'
    messageTimeout:
      type: 'integer'
      default: 5
      description: 'How long should success/error messages be shown?'

  activate: (state) ->
    ReviewInit             = require './models/review-init'
    ReviewSubmit           = require './models/review-submit'

    atom.workspaceView.command 'git-review:init', -> ReviewInit()
    atom.workspaceView.command 'git-review:menu', -> new ReviewPaletteView()
    atom.workspaceView.command 'git-review:submit', -> ReviewSubmit()

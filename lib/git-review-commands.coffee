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

review = require './review'

getCommands = ->
  ReviewInit             = require './models/review-init'
  ReviewSubmit           = require './models/review-submit'
  # ReviewDownload         = require './models/review-download'
  # ReviewTopic            = require './models/review-topic'
  # ReviewSetupRemote      = require './models/review-setup-remote'

  commands = []
  if atom.project.getRepo()?
    review.refresh()
    # if atom.workspace.getActiveEditor()?.getPath()?
    #   commands.push ['git-plus:checkout-current-file', 'Checkout Current File', -> GitCheckoutCurrentFile()]

    commands.push ['git-review:submit', 'Review Submit', -> ReviewSubmit()]
    # commands.push ['git-review:download-change', 'Review Download', -> GitAdd(true)]
    # commands.push ['git-review:topic', 'Review Topic', -> GitAdd(true)]
    # commands.push ['git-review:setup-remote', 'Review Setup', -> GitAdd(true)]

    # TODO: need to implement these
    # "git-review:download-patch",
    # "git-review:submit-branch",
    # "git-review:submit-remote",
    # "git-review:submit-branch-remote",
    # "git-review:compare-patch",
  else
    commands.push ['git-review:init', 'Init', -> ReviewInit()]

  commands

module.exports = getCommands

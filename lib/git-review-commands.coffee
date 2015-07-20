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
  ReviewVersion            = require './models/review-version'
  ReviewSubmit             = require './models/review-submit'
  ReviewDownload           = require './models/review-download'
  ReviewList               = require './models/review-list'
  # ReviewTopic            = require './models/review-topic'
  # ReviewSetupRemote      = require './models/review-setup-remote'

  review.getRepo()
    .then (repo) ->
      commands = []
      commands.push ['git-review:version', 'Version', -> ReviewVersion(repo)]
      commands.push ['git-review:submit', 'Review Submit', -> ReviewSubmit(repo)]
      commands.push ['git-review:download', 'Review Download', -> ReviewDownload(repo)]
      commands.push ['git-review:list', 'Review List', -> ReviewList(repo)]

      # TODO: need to implement these
      # "git-review:submit-branch",
      # "git-review:submit-remote",
      # "git-review:submit-branch-remote",
      # "git-review:compare-patch",
      return commands

module.exports = getCommands

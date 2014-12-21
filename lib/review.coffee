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

{BufferedProcess} = require 'atom'
StatusView = require './views/status-view'

# Public: Execute git-review command line
#
# options - An {Object} with the following keys:
#   :args    - The {Array} containing the arguments to pass.
#   :options - The {Object} with options to pass.
#     :cwd  - Current working directory as {String}.
#   :stdout  - The {Function} to pass the stdout to.
#   :exit    - The {Function} to pass the exit code to.
#
# Returns nothing.
reviewCmd = ({args, options, stdout, stderr, exit}={}) ->
  command = _getReviewPath()
  options ?= {}
  options.cwd ?= dir()
  stderr ?= (data) -> new StatusView(type: 'alert', message: data.toString())

  if stdout? and not exit?
    c_stdout = stdout
    stdout = (data) ->
      @save ?= ''
      @save += data
    exit = (exit) ->
      c_stdout @save ?= ''
      @save = null

  new BufferedProcess
    command: command
    args: args
    options: options
    stdout: stdout
    stderr: stderr
    exit: exit

reviewDownload = ({change, stdout, stderr, exit} = {}) ->
  exit ?= (code) ->
    if code is 0
      new StatusView(type: 'success',
                     message: 'Git Review downloaded change: #{change}.')
  reviewCmd
    args: ['-d']
    stdout: (data) -> stdout(if data.length > 2 then data.split('\0') else [])
    stderr: stderr if stderr?
    exit: exit

reviewSubmit = ({stdout, stderr, exit} = {}) ->
  exit ?= (code) ->
    if code is 0
      new StatusView(type: 'success', message: 'Git Review submitted change.')
  reviewCmd
    args: []
    stdout: (data) -> stdout(if data.length > 2 then data.split('\0') else [])
    stderr: stderr if stderr?
    exit: exit

reviewSetupRemote = ({stdout, stderr, exit} = {}) ->
  exit ?= (code) ->
    if code is 0
      new StatusView(type: 'success', message: 'Git setup remote set.')
  reviewCmd
    args: ['-s']
    stdout: (data) -> stdout(if data.length > 2 then data.split('\0') else [])
    stderr: stderr if stderr?
    exit: exit

reviewTopic = ({stdout, stderr, exit} = {}) ->
  exit ?= (code) ->
    if code is 0
      new StatusView(type: 'success', message: 'Git topic set.')
  reviewCmd
    args: ['-t']
    stdout: (data) -> stdout(if data.length > 2 then data.split('\0') else [])
    stderr: stderr if stderr?
    exit: exit

_getReviewPath = ->
  atom.config.get('git-review.getReviewPath') ? 'git-review'

_prettify = (data) ->
  data = data.split('\0')[...-1]
  files = [] = for mode, i in data by 2
    {mode: mode, path: data[i+1]}

_prettifyUntracked = (data) ->
  return [] if not data?
  data = data.split('\0')[...-1]
  files = [] = for file in data
    {mode: '?', path: file}

_prettifyDiff = (data) ->
  data = data.split(/^@@(?=[ \-\+\,0-9]*@@)/gm)
  data[1..data.length] = ('@@' + line for line in data[1..])
  data

# Returns the root directory for a git repo.
# Will search for submodule first if currently
#   in one or the project root
#
# @param submodules boolean determining whether to account for submodules
dir = (submodules=true) ->
  found = false
  if submodules
    if submodule = getSubmodule()
      found = submodule.getWorkingDirectory()
  if not found
    found = atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()
  found

# returns filepath relativized for either a submodule, repository or a project
relativize = (path) ->
  getSubmodule(path)?.relativize(path) ? atom.project.getRepo()?.relativize(path) ? atom.project.relativize(path)

# returns submodule for given file or undefined
getSubmodule = (path) ->
  path ?= atom.workspace.getActiveEditor()?.getPath()
  atom.project.getRepo()?.repo.submoduleForPath(path)

module.exports.cmd = reviewCmd
module.exports.reviewDownload = reviewDownload
module.exports.reviewSubmit = reviewSubmit
module.exports.reviewSetupRemote = reviewSetupRemote
module.exports.reviewTopic = reviewTopic
module.exports.dir = dir
module.exports.relativize = relativize
module.exports.getSubmodule = getSubmodule

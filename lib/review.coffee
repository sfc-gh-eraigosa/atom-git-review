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

{BufferedProcess, GitRepository} = require 'atom'
notifier = require './notifier'

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
  stderr ?= (data) -> notifier.addError data.toString()

  if stdout? and not exit?
    c_stdout = stdout
    stdout = (data) ->
      @save ?= ''
      @save += data
    exit = (exit) ->
      c_stdout @save ?= ''
      @save = null
  console.log(" executing command -> #{command}")
  console.log(" args              -> #{args}")
  console.log(" options           -> #{options}")
  console.log(" options.cwd       -> #{options.cwd}")
  new BufferedProcess
    command: command
    args: args
    options: options
    stdout: stdout
    stderr: stderr
    exit: exit

# download a change request from gerrit
#
reviewDownload =({id, patch, options, stdout, stderr, exit} = {}) ->
  command = _getReviewPath()
  change = "#{id}"
  change = "#{change},#{patch}" if typeof(patch) != 'undefined' && patch != null
  args = ['-d', change]
  options ?= {}
  options.cwd ?= dir()
  stderr ?= (data) -> notifier.addError data.toString()

  if stdout? and not exit?
    c_stdout = stdout
    stdout = (data) ->
      @save ?= ''
      @save += data
    exit = (exit) ->
      c_stdout @save ?= ''

  console.log(" executing command -> #{command}")
  console.log(" args              -> #{args}")
  console.log(" options           -> #{options}")
  console.log(" options.cwd       -> #{options.cwd}")
  new BufferedProcess
    command: command
    args: args
    options: options
    stdout: stdout
    stderr: stderr
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

# check if integer
isInt = (value) ->
  # console.log("checking isInt for #{value}")
  # console.log("isNaN => #{!isNaN(value)}")
  # console.log("parseInt => #{parseInt(Number(value))}")
  # console.log("parseInt => #{parseInt(Number(value)) == value}")
  # console.log("isNaN parseInt => #{!isNaN(parseInt(value, 10))}")
  # is_int = !isNaN(value) && parseInt(Number(value)) == value && !isNaN(parseInt(value, 10))
  # console.log("got is_int => #{is_int}")
  !isNaN(value)

# Returns the working directory for a git repo.
# Will search for submodule first if currently
#   in one or the project root
#
# @param andSubmodules boolean determining whether to account for submodules
dir = (andSubmodules=true) ->
  new Promise (resolve, reject) ->
    if andSubmodules and submodule = getSubmodule()
      resolve(submodule.getWorkingDirectory())
    else
      getRepo().then (repo) -> resolve(repo.getWorkingDirectory())

# returns filepath relativized for either a submodule or repository
#   otherwise just a full path
relativize = (path) ->
  getSubmodule(path)?.relativize(path) ? atom.project.getRepositories()[0]?.relativize(path) ? path

# returns submodule for given file or undefined
getSubmodule = (path) ->
  path ?= atom.workspace.getActiveTextEditor()?.getPath()
  repo = GitRepository.open(atom.workspace.getActiveTextEditor()?.getPath(), refreshOnWindowFocus: false)
  submodule = repo?.repo.submoduleForPath(path)
  repo?.destroy?()
  submodule

# Public: Get the repository of the current file or project if no current file
# Returns a {Promise} that resolves to a repository like object
getRepo = ->
  new Promise (resolve, reject) ->
    getRepoForCurrentFile().then (repo) -> resolve(repo)
    .catch (e) ->
      repos = atom.project.getRepositories().filter (r) -> r?
      if repos.length is 0
        reject("No repos found")
      else if repos.length > 1
        resolve(new RepoListView(repos).result)
      else
        resolve(repos[0])

getRepoForCurrentFile = ->
  new Promise (resolve, reject) ->
    project = atom.project
    path = atom.workspace.getActiveTextEditor()?.getPath()
    directory = project.getDirectories().filter((d) -> d.contains(path))[0]
    if directory?
      project.repositoryForDirectory(directory).then (repo) ->
        submodule = repo.repo.submoduleForPath(path)
        if submodule? then resolve(submodule) else resolve(repo)
      .catch (e) ->
        reject(e)
    else
      reject "no current file"

module.exports.cmd = reviewCmd
module.exports.download = reviewDownload
module.exports.dir = dir
module.exports.relativize = relativize
module.exports.getSubmodule = getSubmodule
module.exports.getRepo = getRepo
module.exports.isInt = isInt

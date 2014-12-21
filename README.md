# git-review package for atom

# Introduction
  I recently started using atom allot because of it's light weight and super configurable nature.  I'm a big gerrit user too, and most of my interactions are with git-review (another awesome tool from Openstack).

  Enter git-review for atom.   The goal for this project is simple.  Lets enable git-review usage within atom so we don't have to switch back and forth between the command prompt and atom for normal developer workflow.

  Visit the project on github to learn more about  [git-review](https://github.com/openstack-infra/git-review).

## Usage

### Git-Review Palette
>- `Cmd-Shift-Alt-R` on MacOS
>- `Ctrl-Shift-Alt-R` on Windows + Linux
>- `Git Review: Menu` on the atom command palette.

### Commands
1. `Review download [change]`

  Download a change request from gerrit review system.  This is equivalent to `git-review -d [change]`.
  Default key binding: `Cmd-Shift-Alt-D`

2. `Review submit`

  Submit a review to gerrit change control system.  This is the same as `git-review`.Will pull up a commit message file.
  Default key binding: `Cmd-Shift-Alt-S`

3. `Review setup`

  This will setup a remote for the current git project.

4. `Reiew topic [name]`

  Configure a topic for the current review.  This is the same as `git-review -t [name]`

## Contributing

- Fork it and hack on it with github
- Pull request will only be accepted using gerrit review process on review.forj.io  [Learn more](http://docs.forj.io/en/latest/dev/contribute.html)

## Developing
Here are a few shortcuts to help developers get started with adding to this plugin with atom.
- Clone the project
```shell
  git clone https://github.com/wenlock/atom-git-review.git
```
- Link the source folder to your ~/.atom/packages
```shell
  cd atom-git-review
  apm ln . --dev
```
- Install native node modules for your plugin.
```shell
  cd atom-git-review
  npm install
```
## Credits
- Another great adon for atom, [git-plus](https://atom.io/packages/git-plus).  Credit for much of the structure & framework for this addon can be contributed to that project.

## Project Status

- This project is far from ready, and only experimental at the moment.  I'm
  doing it as a fun project over the holidays to get more familliar with
  atom and what you can do with it.

## TODO
- still need to implement these functions:
  "git-review:download-patch",
  "git-review:submit-branch",
  "git-review:submit-remote",
  "git-review:submit-branch-remote",
  "git-review:topic",
  "git-review:compare-patch",
  "git-review:setup-remote",

    "activationEvents": [
      "git-review:init",
      "git-review:menu",
      "git-review:download-change",
      "git-review:submit"

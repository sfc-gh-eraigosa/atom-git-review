# git-review package for atom

# Introduction
  I recently started using atom allot because of it's light weight and super configurable nature.  I'm a big gerrit user too, and most of my interactions are with git-review (another awesome tool from Openstack).

  Enter git-review for atom.   The goal for this project is simple.  Lets enable git-review usage within atom so we don't have to switch back and forth between the command prompt and atom for normal developer workflow.

  Visit the project on github to learn more about  [git-review](https://github.com/openstack-infra/git-review).


  ![A screenshot git-review in](https://raw.githubusercontent.com/wenlock/atom-git-review/master/commit.gif)

## Usage

### Git-Review Palette
>- `Cmd-Shift-R R` on MacOS
>- `Ctrl-Shift-R R` on Windows + Linux
>- `Git Review: Menu` on the atom command palette.

### Commands
1. `Review download`

  Download a change request from gerrit review system.  This is equivalent to `git-review -d [change]`.
  Default key binding: `Cmd-Shift-R D`

2. `Review submit`

  Submit a review to gerrit change control system.  This is the same as `git-review`.Will pull up a commit message file.
  Default key binding: `Cmd-Shift-R S`

3. `Review version`

  This will setup a remote for the current git project.
  Default key binding: `Cmd-Shift-R V`

## Contributing

- Fork it and hack on it with github

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

- This is a fun project and will only be developed as I find time and when the need is truly required for work.
- This project is very basic in that it provides very bare integration, and requires the user to install git-review with pip.
- I welcome other to contribute and help improve it, please checkout the TODO's.

## TODO
- create a topic for the review: git-review:topic
- compare a patch: git-review:compare-patch
- install git-review with pip, if pip found.
- git-review setup

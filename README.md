# Captain
[![Build Status](https://travis-ci.org/yanamura/Captain.svg?branch=master)](https://travis-ci.org/yanamura/Captain)

Captain makes easy to manage git hooks

## Install

### Using [Mint](https://github.com/yonaskolb/Mint)

```
$ mint install yanamura/Captain
```

## Usage

### Configuration
create `Captain.config.json` onproject root directory.

```
/ProjectDir
  /.git
  .gitignore
  Captain.config.json
```
.git directory and Captain.config.json file should be in same location.

#### Captain.config.json

```
{
  "pre-commit": "swiftformat ."
}
```

or

```
{
  "pre-commit": [
    "swiftformat .",
    "git add ."
  ]
}
```

#### supported hooks

- applypatch-msg
- pre-applypatch
- post-applypatch
- pre-commit
- prepare-commit-msg
- commit-msg
- post-commit
- pre-rebase
- post-checkout
- post-merge
- pre-push
- pre-receive
- update
- post-receive
- post-update
- push-to-checkout
- pre-auto-gc
- post-rewrite
- sendemail-validat

### Set Git Hooks

run this script

#### Using [Mint](https://github.com/yonaskolb/Mint)
```
$ mint run yanamura/Captain "captain install"
```

# Captain

<p>
  <a href="https://travis-ci.org/yanamura/Captain">
    <img src="https://travis-ci.org/yanamura/Captain.svg?branch=master" alt="travis">
  </a>
  <a href="https://swift.org">
    <img src="http://img.shields.io/badge/swift-4.2-brightgreen.svg" alt="Swift 4.2">
  </a>
  <a href="https://swift.org">
    <img src="http://img.shields.io/badge/swift-5.0-brightgreen.svg" alt="Swift 5.0">
  </a>
</p>

Captain makes easy to manage git hooks

## Install

### Using Mint
if you want to install globally, use [Mint](https://github.com/yonaskolb/Mint)
```
$ mint install yanamura/Captain
```
### build yourself
```
$ git clone https://github.com/yanamura/Captain
$ cd Captain
$ swift build -c release
```
executable binary will be created to ./build/release/captain

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
```
$ captain install
```

#### Using [Mint](https://github.com/yonaskolb/Mint)
```
$ mint run yanamura/Captain "captain install"
```

#### Using cloned repository
```
$ git clone https://github.com/yanamura/Captain
$ cd Captain
$ swift run captain install
```

### Unset Git Hooks
```
$ captain uninstall
```

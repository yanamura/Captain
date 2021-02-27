# Captain

<p>
  <a href="https://travis-ci.org/yanamura/Captain">
    <img src="https://travis-ci.org/yanamura/Captain.svg?branch=master" alt="travis">
  </a>
  <a href="https://swift.org">
    <img src="http://img.shields.io/badge/swift-5.1-brightgreen.svg" alt="Swift 5.1">
  </a>
</p>

Captain makes easy to manage git hooks

## Install

### Using Mint
if you want to install globally, use [Mint](https://github.com/yonaskolb/Mint)
```
$ mint install yanamura/Captain
```
### Using SwiftPackageManager
```
/// Package.swift
    dependencies: [
        ...
        .package(url: "https://github.com/yanamura/Captain"),
    ]
```

```
$ swift build --package-path <path to Package.swift>  -c release
```

executable binary will be created to ./build/release/captain

## Usage

### Configuration
create `.captain` onproject root directory.

```
/ProjectDir
  /.git
  .gitignore
  .captain
```
.git directory and .captain file should be in same location.

#### .captain

```
{
  "pre-commit": "swift-format -r Sources -i"
}
```

or

```
{
  "pre-commit": [
    "swift-format -r Sources -i",
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

### Using Swift Package Manager

```
/// Package.swift
    dependencies: [
        ...
        .package(url: "https://github.com/yanamura/Captain"),
    ]
```

```
$ swift run --package-path <path to Package.swift>  -c release captain install
```

#### Using [Mint](https://github.com/yonaskolb/Mint)
```
$ mint run yanamura/Captain captain install
```

### Unset Git Hooks
```
$ captain uninstall
```

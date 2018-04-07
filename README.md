# Captain

Captain makes easy to manage git hooks

## Install

### Using [Mint](https://github.com/yonaskolb/Mint)

```
$ mint install yanamura3/Captain
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

- pre-commit

### Set Git Hooks

run this script

#### Using [Mint](https://github.com/yonaskolb/Mint)
```
$ mint run yanamura3/Captain "captain install"
```

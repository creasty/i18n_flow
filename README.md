![](https://user-images.githubusercontent.com/1695538/36350808-d0cf8afe-14e1-11e8-8afb-34a316f98f80.png)

i18n_flow (beta)
================

[![Build Status](https://travis-ci.org/creasty/i18n_flow.svg?branch=master)](https://travis-ci.org/creasty/i18n_flow)
[![License](https://img.shields.io/github/license/creasty/i18n_flow.svg)](./LICENSE)

**Manage translation status in YAML file.**  
With an official [tag](http://www.yaml.org/spec/1.2/spec.html#id2784064) feature, `i18n_flow` enables you to annotate status information directly in YAML file.

![](https://user-images.githubusercontent.com/1695538/36359417-6a976054-155e-11e8-914b-d6a10a8287fc.png)

- [Lint rules](./doc/rules.md)
- [Tags](./doc/tags.md)


Setup
-----

### Installation

Add this line to your Gemfile:

```ruby
gem 'i18n_flow', github: 'creasty/i18n_flow'
```

### Configuration

Create a configuration file at your project's root directory.

```sh-session
$ cat > i18n_flow.yml
base_path: config/locales
glob_patterns:
  - '**/*.yml'
valid_locales:
  - en
  - ja
locale_pairs:
  - ['en', 'ja']
^D
```


CLI
---

```sh-session
$ i18n_flow
Manage translation status in yaml file

Usage:
    i18n_flow COMMAND [args...]
    i18n_flow [options]

Options:
    -v, --version    Show version
    -h               Show help

Commands:
    lint       Validate files
    search     Search contents and keys
    copy       Copy translations and mark as todo
    split      Split a file into proper-sized files
    version    Show version
    help       Show help
```


Configuration file
------------------

```yaml
# Base directory
# Default: pwd
base_path: config/locales

# Patterns for locale YAML files
# Default: ['*.en.yml']
glob_patterns:
  - '**/*.yml'

# List of all supporting locales
# May want to sync with `I18n.available_locales`
# Default: ['en']
valid_locales:
  - en
  - ja

# List of master-foreign pairs
# Used by the linter to check symmetry
# Default: []
locale_pairs:
  - ['en', 'ja']

# Enabled linters
# Default
linters:
  - file_scope
  - symmetry
```

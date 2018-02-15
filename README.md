i18n_flow
=========

[![Build Status](https://travis-ci.org/creasty/i18n_flow.svg?branch=master)](https://travis-ci.org/creasty/i18n_flow)

Manage translation status in yaml file.

- [Lint rules](./doc/rules.md)

Tags
----

### `!ignore:VIOLATION`

Suppress an error on a certain key.

`VIOLATION` is either `args` or `key`. e.g., `!ignore:args`

### `!only`, `!only:LOCALES`

`LOCALES` can be a comma-separated values of multiple locales. e.g., `!only`, `!only:en,ja`

### `!todo`, `!todo:LOCALES`

`LOCALES` can be a comma-separated values of multiple locales. e.g., `!todo`, `!todo:en,ja`

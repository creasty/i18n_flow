Lint rules
==========

File-scope linter
-----------------

File-scope linter checks consistency between file content and a file path of each file, without comparing with others.

A file-scope for a file `models/user.en.yml` is `en.models.user`.

:+1: Starting with a file-scope

```yaml
en:
  models:
    user:
      ...
```

### A file must start with scopes that derive from its file path (which we call a 'file-scope')

:-1: Not starting with a file-scope (yields `missing_key`)

```yaml
ja: # should be `en`
  models:
    user:
      ...
```

```yaml
en:
  controller: # should be `models`
    user:
      ...
```

```yaml
ja:
  models:
    client: # should be `user`
      ...
```

### Having an extra key at anywhere upper-or-same level than a file-scope

:-1: yields `extra_key`

```yaml
en:
  models:
    user:
      ...
  controllers: # not allowed
    ...
```

### A file-scope itself must not have a scalar value

:-1: yields `invalid_type`

```yaml
en:
  models:
    user: 'User'  # must be a mapping or a sequence
```


Symmetry linter
---------------

Symmetry linter compares a pair of files and checks their symmetry.
As a pair, one is 'master' and another is 'foreign'.

If your primary language is English and going to support Japanese as secondary, you may want to lint Japanese (foreign) locale file based on English locale file (master).

```yaml
# master
en:
  follower_count:
    one: '1 follower'
    other: '%{count} followers'
```

### Keys in a foreign file must be exhaustive and exclusive

:+1:

```yaml
# foreign
ja:
  follower_count:
    one: '1 フォロワー'
    other: '%{count} フォロワー'
```

:-1: Missing key (yields `missing_key`)

```diff
 # foreign
 ja:
   follower_count:
-    one: '1 フォロワー'
     other: '%{count} フォロワー'
```

:-1: Extra key (yields `extra_key`)

```diff
 # foreign
 ja:
+  greeting: 'こんにちは世界'
   follower_count:
     one: '1 フォロワー'
     other: '%{count} フォロワー'
```

### Structure must match exactly

:-1: yields `invalid_type`

```yaml
# foreign
ja:
  follower_count: '%{count} フォロワー'  # follower_count is a mapping in `en` whereas here is a scalar
```

### Interpolation arguments must match exactly

```yaml
# foreign
ja:
  follower_count:
    one: '%{count} フォロワー'  # en: no args, ja: [count]
    other: '%{name} さん他、%{count}人のフォロワー' # en: [count], ja: [count, name]
```


Lint rules
==========

File-scope linter
-----------------

File-scope linter checks consistency between file content and a file path of each file, without comparing with others.

'File-scope' is a sort of namespace that derives from a file path.
For `models/user.en.yml`, a file-scope is `en.models.user`.

```yaml
en:
  models:
    user:
      ...
```

### A file must start with scopes that derive from its file path

<details><summary>:cross: Bad cases</summary>

**models/user.en.yml**

```yaml
ja:        # should be `en`
  models:
    user:
      ...
```

**controllers/admin/accounts\_controller.en.yml**

```yaml
en:
  controllers:
    nimda:      # should be `admin`
      accounts_controller:
        ...
```

</details>

### Having extra key at anywhere upper-or-same level than a file-scope

<details><summary>:cross: Bad case</summary>

**models/user.en.yml**

```yaml
en:
  models:
    user:
      ...

  controllers: # not allowed
    ...
```

</details>

### A file-scope itself must not have a scalar value

<details><summary>:cross: Bad case</summary>

**models/user.en.yml**

```yaml
en:
  models:
    user: 'User'  # must be a mapping or a sequence
```

</details>


Symmetry linter
---------------

Symmetry linter compares a pair of files and checks their symmetry.
As a pair, one is 'master' and another is 'foreign'.

If your primary language is English and going to support Japanese as secondary, you may want to lint Japanese (foreign) locale file based on English locale file (master).

### Keys in a foreign file must be exhaustive and exclusive

**master**

```yaml
en:
  title: 'I18nFlow'
  description: 'Manage translation status in yaml file'
```

**foreign**

```yaml
ja:
  title: 'I18nFlow'
  description: '翻訳の状態管理を YAML 内で'
```

<details><summary>:cross: Missing key</summary>

**master**

```yaml
en:
  title: 'I18nFlow'
  description: 'Manage translation status in yaml file'
```

**foreign**

```yaml
ja:
  # missing `title`
  description: '翻訳の状態管理を YAML 内で'
```

</details><br>

<details><summary>:cross: Extra key</summary>

**master**

```yaml
en:
  title: 'I18nFlow'
  description: 'Manage translation status in yaml file'
```

**foreign**

```yaml
ja:
  title: 'I18nFlow'
  description: '翻訳の状態管理を YAML 内で'
  lead_text: 'こんにちは'  # extra key
```

</details>

### Structure must match exactly

<details><summary>:cross: Bad case</summary>

**master**

```yaml
en:
  follower_count:
    one: '1 follower'
    other: '%{count} followers'
```

**foreign**

```yaml
ja:
  follower_count: '%{count} フォロワー'  # It's a mapping in `en` whereas here is a scalar
```

</details>

### Interpolation arguments must match exactly

<details><summary>:cross: Bad case</summary>

**master**

```yaml
en:
  follower_count:
    one: '1 follower'
    other: '%{count} followers'
```

**foreign**

```yaml
ja:
  follower_count:
    one: '%{count} フォロワー'  # en: no args, ja: [count]
    other: '%{name} さん他、%{count}人のフォロワー' # en: [count], ja: [count, name]
```

</details>


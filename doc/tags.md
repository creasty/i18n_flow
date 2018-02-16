Tags
====

Justify violations
------------------

<details><summary>✅ Missing key with `!only`</summary>

```yaml
# master

en:
  title: !only 'I18nFlow'  # tell linter that the key only exists in master
  description: 'Manage translation status in yaml file'
```

```yaml
# foreign

ja:
  # missing `title`
  description: '翻訳の状態管理を YAML 内で'
```

</details><br>

<details><summary>✅ Extra key with `!only`</summary>

```yaml
# master

en:
  title: 'I18nFlow'
  description: 'Manage translation status in yaml file'
```

```yaml
# foreign

ja:
  title: 'I18nFlow'
  description: '翻訳の状態管理を YAML 内で'
  lead_text: !only 'こんにちは'  # tell linter that the key only exists in master
```

</details>

<details><summary>✅ Extra key with `!ignore`</summary>

```yaml
# master

en:
  title: 'I18nFlow'
  description: 'Manage translation status in yaml file'
```

```yaml
# foreign

ja:
  title: 'I18nFlow'
  description: '翻訳の状態管理を YAML 内で'
  lead_text: !only 'こんにちは'  # extra key
```

</details>


Lint rules
==========

File-scope linter
-----------------

File-scope linter checks consistency between file content and a file path of each file, without comparing with others.

'File-scope' is a sort of namespace that derives from a file path.
For `models/user.en.yml`, a file-scope is `en.models.user`.

```yaml
```

### A file must start with scopes that derive from its file path

<table><thead><tr>
  <th></th>
  <th>models/user.en.yml</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  models:
    user:
      ...
```

</td></tr><tr><td colspan=2>

Starts with `en.models.user`

</td></tr></tbody></table>

<table><thead><tr>
  <th></th>
  <th>models/user.en.yml</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
ja:
  models:
    user:
      ...
```

</td></tr><tr><td colspan=2>

Starts with `ja`

</td></tr></tbody></table>

<table><thead><tr>
  <th></th>
  <th>controllers/admin/accounts_controller.en.yml</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  controllers:
    nimda:
      accounts_controller:
        ...
```

</td></tr><tr><td colspan=2>

Starts with `en.controllers.nimda`

</td></tr></tbody></table>


### Having extra key at anywhere upper-or-same level than a file-scope

<table><thead><tr>
  <th></th>
  <th>models/user.en.yml</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  models:
    user:
      ...

  foo: ...
```

</td></tr><tr><td colspan=2>

`en.foo` and `en.models` coexist

</td></tr></tbody></table>


### A file-scope itself must not have a scalar value

<table><thead><tr>
  <th></th>
  <th>models/user.en.yml</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  models:
    user: 'User'
```

</td></tr><tr><td colspan=2>

`user` must be either a mapping or a sequence

</td></tr></tbody></table>


Symmetry linter
---------------

Symmetry linter compares a pair of files and checks their symmetry.
As a pair, one is 'master' and another is 'foreign'.

If your primary language is English and going to support Japanese as secondary, you may want to lint Japanese (foreign) locale file based on English locale file (master).

### Keys in a foreign file must be exhaustive and exclusive

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  title: 'Non zero sum'
  description: 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  description: '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

Every keys exist on both files. No asymmetric keys

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  title: 'Non zero sum'
  description: 'A situation in...'
```

</td><td>

```yaml
ja:

  description: '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

A missing `title` key in foreign

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  title: 'Non zero sum'
  description: 'A situation in...'
  
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  description: '複数の人が相互...'
  concept: '概念'
```

</td></tr><tr><td colspan=3>

An extra `concept` key in foreign

</td></tr></tbody></table>


### Structure must match exactly

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  follower_count:
    one: '1 follower'
    other: '%{count} followers'
```

</td><td>

```yaml
ja:
  follower_count: '%{count} フォロワ'
  
  
```

</td></tr><tr><td colspan=3>

`follower_count` is a mapping in master, whereas it's a scalar in foreign

</td></tr></tbody></table>


### Interpolation arguments must match exactly

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  key: '%{alpha} %{beta} %{beta}'
```

</td><td>

```yaml
ja:
  key: '%{beta} %{alpha}'
```

</td></tr><tr><td colspan=3>

It's insensitive of arguments order and repetition

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  key: '%{alpha}'
```

</td><td>

```yaml
ja:
  key: 'alpha'
```

</td></tr><tr><td colspan=3>

No arguments exist in foreign

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  key: '%{alpha}'
```

</td><td>

```yaml
ja:
  key: '%{gamma}'
```

</td></tr><tr><td colspan=3>

A set of arguments is different from master

</td></tr></tbody></table>

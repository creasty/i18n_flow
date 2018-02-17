Tags
====

!only
-----

With `!only`, you can explicitly claim that a key *may* not exist on both files.  
Linter won't complain even if a key *does* exist. If you don't prefer this behavior, use stricter `!only:LOCALES`.

It comes in handy when you have texts that don't need to be translated into another language, still want to manage in a locale file.

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  title: 'Non zero sum'
  desc: 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  
```

</td></tr><tr><td colspan=3>

Missing `ja.desc`

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  title: 'Non zero sum'
  desc: !only 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  
```

</td></tr><tr><td colspan=3>

Linter won't complain about `ja.desc` even if it doesn't exist

</td></tr></tbody></table>

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  title: 'Non zero sum'
  desc: !only 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  desc: '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

Linter won't complain about `ja.desc` even if it does exist

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  title: 'Non zero sum'
  
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  desc: '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

Having the extra `ja.desc`

</td></tr></tbody></table>

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  title: 'Non zero sum'
  
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  desc: !only '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

Linter won't complain about `ja.desc`

</td></tr></tbody></table>

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  title: 'Non zero sum'
  desc: 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  desc: !only '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

Linter won't complain about `ja.desc`

</td></tr></tbody></table>


!only:LOCALES
-------------

It's similar to `!only`, but is stricter.  
It can take comma-separated locales as a parameter just like `!only:en` or `!only:en,ja,zh-HK`, and ensures that a key only exists in files of the specified locales.

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  title: 'Non zero sum'
  desc: !only:en 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  desc: '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

Linter will complain about `ja.desc`, because the key is supposed to exist only in `en`.

</td></tr></tbody></table>

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>👎</th><td>

```yaml
en:
  title: 'Non zero sum'
  desc: 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  desc: !only:ja '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

Linter will complain about `en.desc`, because the key is supposed to exist only in `ja`.

</td></tr></tbody></table>

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  title: 'Non zero sum'
  desc: !only:en,ja 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  desc: '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

The key can exist in the specified locales `en,ja`

</td></tr></tbody></table>

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  title: 'Non zero sum'
  desc: !only:en,ja 'A situation in...'
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  
```

</td></tr><tr><td colspan=3>

Note that it doesn't mean to ensure existance of the key.

</td></tr></tbody></table>


!ignore:key
-----------

With `!ignore:key`, you can suppress any error on a certain key.

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  title: 'Non zero sum'
  
```

</td><td>

```yaml
ja:
  title: '非ゼロ和'
  desc: !ignore:key '複数の人が相互...'
```

</td></tr><tr><td colspan=3>

Linter won't complain about an asymmetric key

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  follower_count:
    one: '1 follower'
    other: '%{count} followers'
```

</td><td>

```yaml
ja:
  follower_count: !ignore:key '%{count} フォロワ'
  
  
```

</td></tr><tr><td colspan=3>

Linter won't complain about a structural mismatch

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  key: !ignore:key '%{alpha}'
```

</td><td>

```yaml
ja:
  key: '%{gamma}'
```

</td></tr><tr><td colspan=3>

Linter won't complain about a difference in interpolation arguments

</td></tr></tbody></table>


!ignore:args
------------

With `!ignore:args`, you can suppress an error of asymmetric interpolation arguments.

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  key: '%{alpha}'
```

</td><td>

```yaml
ja:
  key: !ignore:args '%{gamma}'
```

</td></tr><tr><td colspan=3>

Linter won't complain about a difference in interpolation arguments

</td></tr></tbody></table>


!todo
-----

With `!todo`, you can annotate that a key needs to be translated in the future.  
It can be only annotated on scalar values, mappings and sequences are not accepted.

<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  follower_count:
    one: '1 follower'
    other: '%{count} followers'
```

</td><td>

```yaml
ja:
  follower_count:
    one: !todo '1 follower'
    other: !todo '%{count} followers'
```

</td></tr><tr><td colspan=3>

Two keys need to be translated

</td></tr></tbody></table>

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
  follower_count: !todo
    one: '1 follower'
    other: '%{count} followers'
```

</td></tr><tr><td colspan=3>

You can't annotate on a mapping or a sequence.

</td></tr></tbody></table>


<table><thead><tr>
  <th></th>
  <th>master</th>
  <th>foreign</th>
</tr></thead><tbody><tr><th>✅</th><td>

```yaml
en:
  follower_count:
    one: 'a follower'
    other: '%{count} followers'
```

</td><td>

```yaml
ja:
  follower_count:
    one: !todo '1 follower'
    other: !todo '%{count} followers'
```

</td></tr><tr><td colspan=3>

Linter will complain `ja.follower_count.one` has different content.  
This usually indicates that there has been updates on the master file, or that it has been translated but forgotten to remove `!todo`.

</td></tr></tbody></table>

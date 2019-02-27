## Feeds

複数のRSS/Atomフィードを合成し，1つのWebページにまとめて表示する．

## How to generate html

### Create feeds.toml

`crawler/feeds.toml` を作成し，ブログフィードを登録する．

```
$ vim crawler/feeds.toml
```

`feeds.toml` の例：

```feeds.toml
[hoge1]
feed_url = "https://dawn.hateblo.jp/feed"

[hoge2]
feed_url = "https://dawn.hateblo.jp/rss"
```

### Build html

`build.sh` を実行すると，Webサイトが生成される．

```
$ ./build.sh
$ open dist/index.html
$ cat dist/feeds.json
```

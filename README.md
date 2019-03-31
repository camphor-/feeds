## Feeds

複数のRSS/Atomフィードを合成し，1つのJSONファイルにまとめる．

## How to generate json

### Create feeds.toml

`feeds.toml` の例：

```feeds.toml
[hoge1]
feed_url = "https://dawn.hateblo.jp/feed"

[hoge2]
feed_url = "https://dawn.hateblo.jp/rss"
```

### Build json
#### Locally
```
$ bundle install --path vendor/bundle
$ cat feeds.toml | bundle exec ruby crawl.rb | bundle exec ruby generate.rb > dist/feeds.json
```

#### With [docker image](https://cloud.docker.com/u/camphor/repository/docker/camphor/feeds)
```
$ docker run \
    -v $PWD/feeds.toml:/apps/feeds.toml:ro \
    -v $PWD/dist:/apps/dist \
    camphor/feeds:latest
```

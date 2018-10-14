## setup

### 環境変数

環境変数 `APP_ENV` に何も指定されていない場合は、development環境であると判定され `.env.development` が読み込まれます。

それ以外の場合は `.env.development` と同様の環境変数を設定した状態で、各種スクリプトやWebサーバーなどを起動する必要があります。

### database

postgresqlを起動し、マイグレーションを走らせます。

```
./scripts/launch_db.sh # dockerでpostgresqlが立ち上がる
bundle exec rake db:migrate
```

### feedを登録する

```
bundle exec rake source:add http://blog.someone.com/feed http://blog.someone.com/blog-icon.png
```

### feedをクロールする

登録されたfeedをクロールする。
これを定期的に実行することでフィードが更新される。

```
bundle exec rake source:crawl
```

## 起動

```
bundle exec puma config.ru # open http://localhost:9292
```


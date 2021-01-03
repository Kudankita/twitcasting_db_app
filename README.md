# twitcasting_db_app

## 各種コマンドまとめ

### 依存のアップデート

`bundle update`

### テスト

`bundle exec rspec`

### Lint

`bundle exec rubocop -a`

### キャッシュ無しでイメージをビルド

docker-composeにおける実行（production環境での実行になる）には`production.env`をプロジェクトルートに、`master.key`を`config`ディレクトリにそれぞれ配置する必要がある。（以下のコマンドも同様）

`docker-compose build --no-cache`

### キャッシュ無しでイメージをビルドして立ち上げ

`docker-compose up --build -d`

コンテナを立ち上げたあとは正常な動作には下記のアセットのコンパイル、DBのマイグレーション、初期データの投入を`twitcasting_db_app_web_1`コンテナ内で行う必要がある。（基本的に初回のみ。ボリュームが保存されていればDBスキーマなどに変更がない限り毎回行う必要はない）

### アセットのコンパイル

`bundle exec rake assets:precompile`

### DBのマイグレーション

`bundle exec rake db:migrate`

production環境で実施  
`bundle exec rake db:migrate RAILS_ENV=production`

### DBヘ初期データの投入

`bundle exec rake db:seed`  

production環境で実施  
`bundle exec rake db:seed RAILS_ENV=production`

初期データの投入には`db`ディレクトリに`developer.csv`、`users.csv`を配置する必要がある。

## その他

DBなどのパスワードは`production.env`に記載  
twitcastingのAPIは[TwitCasting APIv2](https://apiv2-doc.twitcasting.tv/ "TwitCasting APIv2")を参照。

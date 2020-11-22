# twitcasting_db_app

## 各種コマンドまとめ

### 依存のアップデート

`bundle update`

### テスト

`bundle exec rspec`

### Lint

`bundle exec rubocop -a`

### キャッシュ無しでイメージをビルド

`docker-compose build --no-cache`

### キャッシュ無しでイメージをビルドして立ち上げ

`docker-compose up --build -d`

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

## その他

DBなどのパスワードは``production.env`に記載  
twitcastingのAPIは[TwitCasting APIv2](https://apiv2-doc.twitcasting.tv/ "TwitCasting APIv2")を参照。

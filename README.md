# README
Ruby on Rails の学習のために作成したWebアプリ。  
「Ruby on Rails チュートリアル」相当の基本動作をなるべく盛り込むこと、テストを十分に用意すること、に注意しながら進めた。  
ライブ配信サイトであるTwitCastingのAPIを利用し、配信を録画する機能を持つ。  
また、録画対象のユーザーの情報をDBに登録し、管理することもできるようにする。  

## 録画の仕組み
TwitCastingはライブ開始を通知するWebHookを特定のURLに送信してくれる機能がある。  
WebHookの登録はTwitCasting APIへのPOSTリクエストで行う。これで設定した配信者が配信を開始した際にWebHookが送信される。（同様の手順で登録解除も可能。）  
この通知をRailsアプリで受信し、配信の録画とコメントの取得を行う。  
録画とコメントの取得はActive Jobによって非同期に行う。
## ユーザー情報管理
ここでのユーザーとはTwitCastingの配信者のことで、アプリのログイン後の画面からテーブルへのユーザーの新規登録、詳細確認、更新、削除を可能とする。  
この際、テーブルのデータを操作するだけでなく、TwitCastingのAPIを利用してTwitCasting側の登録状況も変更する。  
つまり、
* テーブルに登録する際は同時にWebHookを登録
* テーブルから削除する際は同時にWebHookを解除
* 更新時にはテーブルだけでなく、WebHookの登録状況も更新可能

上記のような機能を実現させる。  
（この実装によってRailsによるCRUDを網羅する。）  
なお、TwitCastingのAPIの利用は60秒で60回までという制限があるので、これに配慮し、前回のAPI利用日時をテーブルに保存し、一定間隔を開けて利用できるようにする。

 参考：[TwitCasting APIv2](https://apiv2-doc.twitcasting.tv/ "TwitCasting APIv2")

## デプロイ
- デプロイ先
    - VPS
- ウェブサーバー
    - nginx
        - ログイン機能を設けているのでHTTPSで通信する。
- Jenkins
    - VPSに導入し、自動デプロイを実施する。
        - masterブランチにPUSHされた際にGithubからソースを取得し、アプリを更新する。
- Docker
    - アプリはDockerコンテナ上で動作させる。

## 使用技術
- 言語/フレームワーク
    - ruby 2.5.5 / Rails 5.2.3
- テスト
    - RSpec 3.8
    - capybara (統合テスト)
    - fakefs (ファイル操作関連の試験用)
    - vcr (Webアクセスを実施する機能の試験用)
    - factory_bot_rails (初期データの投入)
    - simplecov (カバレッジ測定)
- エディタ
    - Visual Studio Code
    - RubyMine
- その他
    - httpclient (APIの利用)
    - streamio-ffmpeg (web上での動画配信の録画)
    - bootstrap (CSSフレームワーク)
    - rubycritic (静的解析)

## 未実装部分、今後の課題
「DBに登録されたユーザーのWebHookを受信したら配信を録画する」という機能がとりあえず動作することを優先した。その結果、後回しになっている機能、問題が複数ある。
- テーブルに使われていないカラムがある。（更新画面で更新することもできるが使われていない。）
- バグ、レイアウトの崩れ、リファクタリングの必要な箇所がある、など

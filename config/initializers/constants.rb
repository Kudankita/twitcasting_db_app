# frozen_string_literal: true

module Constants
  # ツイキャスのAPIを叩く間隔を定義（60秒に60回を超えるとペナルティ）
  API_INTERVAL = if Rails.env.production?
                   10
                 else
                   1
                 end

  # ツイキャスAPIのURI　これにパスなどをつなげてhttps://apiv2.twitcasting.tv/users/twitcasting_jpのようにして使う
  SERVER_NAME = 'https://apiv2.twitcasting.tv'

  # TIMERテーブルのうちAPIに関する行を参照させるための指定
  # 基本的に1固定だが、今後増えたときに備える
  TIMER_ID = 1
end

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
end

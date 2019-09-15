# frozen_string_literal: true

class User < ApplicationRecord
  validates :screen_id, presence: true, uniqueness: true

  # webhook新規登録前の待機時間
  # メソッド中に二度APIを利用するのでほぼ確実に待機時間が発生する。したがってここは他と違って間隔を短くする
  REGISTER_WEBHOOK_WAIT = 1

  def register_and_save_user
    wait_api Constants::API_INTERVAL
    user_info_response = get_user_info
    logger.debug user_info_response.body
    unless [200, 201].include? user_info_response.status_code
      set_api_errormessage user_info_response
      return user_info_response
    end
    user_info_hash = JSON.parse user_info_response.body
    self.attributes = { user_id: user_info_hash['user']['id'], name: user_info_hash['user']['name'] }
    wait_api REGISTER_WEBHOOK_WAIT
    register_webhook_response = register_webhook user_id
    logger.debug register_webhook_response.body
    set_api_errormessage register_webhook_response unless [200, 201].include? register_webhook_response.status_code
    register_webhook_response
  end

  def wait_api(wait_interval)
    loop do
      if Timer.where('updated_at < ?', Time.current - wait_interval.second).where(id: Constants::TIMER_ID).update(created_at: Time.current).empty?
        # 一定秒以上待機し、待機時間にランダム性を持たせるために下記のようにする
        sleep rand(wait_interval + 1) + wait_interval
      else
        break
      end
    end
  end

  def get_user_info
    http_client = HTTPClient.new
    header = { Accept: 'application/json', 'X-Api-Version': '2.0',
               Authorization: "Bearer #{Rails.application.credentials.dig(:twitcasting, :access_token)}" }
    user_info_uri = URI("#{Constants::SERVER_NAME}/users/#{screen_id}")
    http_client.get user_info_uri, header: header
  end

  def register_webhook(id)
    http_client = HTTPClient.new
    http_client.debug_dev = STDOUT
    headers = { Accept: 'application/json', 'X-Api-Version': '2.0',
                Authorization: "Basic #{Rails.application.credentials.dig(:twitcasting, :basic_access_token)}" }
    register_webhook_uri = URI('https://apiv2.twitcasting.tv/webhooks')
    params = { user_id: id, events: %w[livestart liveend] }.to_json
    http_client.post(register_webhook_uri, body: params, header: headers)
  end

  def set_api_errormessage(api_response)
    response_hash = JSON.parse api_response.body
    errors.add(screen_id, response_hash['error']['message'])
  end
end

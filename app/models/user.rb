# frozen_string_literal: true

class User < ApplicationRecord
  validates :user_id, presence: true
  validates :screen_id, presence: true, uniqueness: true
  validates :name, presence: true

  # webhook新規登録前の待機時間
  # メソッド中に二度APIを利用するのでほぼ確実に待機時間が発生する。したがってここは他と違って間隔を短くする
  REGISTER_WEBHOOK_WAIT = 1

  # webhookの新規登録、削除時のリクエストヘッダー
  SET_WEBHOOK_HEADERS = { Accept: 'application/json', 'X-Api-Version': '2.0',
                          Authorization: "Basic #{Rails.application.credentials.dig(:twitcasting, :basic_access_token)}" }.freeze

  # webhook新規登録・解除APIのURI文字列
  REGISTER_WEBHOOK_URI = "#{Constants::SERVER_NAME}/webhooks"

  def register_and_save_user
    wait_api Constants::API_INTERVAL
    user_info_response = get_user_info
    logger.debug user_info_response.body
    unless Constants::REGISTER_WEBHOOK_OK_RESPONSE.include? user_info_response.status_code
      set_api_errormessage user_info_response
      return user_info_response
    end
    user_info_hash = JSON.parse user_info_response.body
    self.attributes = { user_id: user_info_hash['user']['id'], name: user_info_hash['user']['name'] }
    return unless valid?

    wait_api REGISTER_WEBHOOK_WAIT
    register_webhook_response = register_webhook
    logger.debug register_webhook_response.body
    set_api_errormessage register_webhook_response unless Constants::REGISTER_WEBHOOK_OK_RESPONSE.include? register_webhook_response.status_code
    register_webhook_response
  end

  def update_webhook_status(param_recordable)
    wait_api Constants::API_INTERVAL
    if param_recordable
      register_webhook_response = register_webhook
      logger.debug register_webhook_response.body
      set_api_errormessage register_webhook_response unless Constants::REGISTER_WEBHOOK_OK_RESPONSE.include? register_webhook_response.status_code
    else
      remove_webhook_response = remove_webhook
      logger.debug remove_webhook_response.body
      set_api_errormessage remove_webhook_response unless Constants::REGISTER_WEBHOOK_OK_RESPONSE.include? remove_webhook_response.status_code
    end
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

  def register_webhook
    http_client = build_http_client
    params = { user_id: user_id, events: %w[livestart liveend] }.to_json
    http_client.post(URI(REGISTER_WEBHOOK_URI), body: params, header: SET_WEBHOOK_HEADERS)
  end

  def remove_webhook
    http_client = build_http_client
    remove_webhook_uri = URI(REGISTER_WEBHOOK_URI)
    remove_webhook_uri.query = { user_id: user_id, events: %w[livestart liveend] }.to_param
    # webhook削除は対象ユーザーがツイキャスに存在しなくても200 OKになる模様
    http_client.delete(remove_webhook_uri, header: SET_WEBHOOK_HEADERS)
  end

  def set_api_errormessage(api_response)
    response_hash = JSON.parse api_response.body
    if screen_id.blank?
      errors.add('screen_id', "can't be blank")
    else
      errors.add(screen_id, response_hash['error']['message'])
    end
  end

  private

  def build_http_client
    http_client = HTTPClient.new
    http_client.debug_dev = STDOUT
    http_client
  end
end

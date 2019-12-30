# frozen_string_literal: true

# User
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
    user_info_response = user_info
    unless Constants::REGISTER_WEBHOOK_OK_RESPONSE.include? user_info_response.status_code
      add_api_errormessage user_info_response
      return user_info_response
    end
    user_info_hash = JSON.parse user_info_response.body
    self.attributes = { user_id: user_info_hash['user']['id'], name: user_info_hash['user']['name'] }
    return unless valid?

    register_webhook
  end

  def update_webhook_status(param_recordable)
    wait_api Constants::API_INTERVAL
    if param_recordable
      register_webhook_response = register_webhook
      add_api_errormessage register_webhook_response unless Constants::REGISTER_WEBHOOK_OK_RESPONSE.include? register_webhook_response.status_code
    else
      remove_webhook_response = remove_webhook
      add_api_errormessage remove_webhook_response unless Constants::REGISTER_WEBHOOK_OK_RESPONSE.include? remove_webhook_response.status_code
    end
  end

  def wait_api(wait_interval)
    loop do
      break unless Timer.where('updated_at < ?', Time.current - wait_interval.second).where(id: Constants::TIMER_ID).update(created_at: Time.current).empty?

      sleep rand(wait_interval + 1) + wait_interval
    end
  end

  def user_info
    wait_api Constants::API_INTERVAL
    http_client = HTTPClient.new
    header = { Accept: 'application/json', 'X-Api-Version': '2.0',
               Authorization: "Bearer #{Rails.application.credentials.dig(:twitcasting, :access_token)}" }
    user_info_uri = URI("#{Constants::SERVER_NAME}/users/#{screen_id}")
    get_response = http_client.get user_info_uri, header: header
    logger.debug get_response.body
    get_response
  end

  def register_webhook
    wait_api REGISTER_WEBHOOK_WAIT
    http_client = build_http_client
    params = { user_id: user_id, events: %w[livestart liveend] }.to_json
    post_response = http_client.post(URI(REGISTER_WEBHOOK_URI), body: params, header: SET_WEBHOOK_HEADERS)
    logger.debug post_response.body
    add_api_errormessage post_response unless Constants::REGISTER_WEBHOOK_OK_RESPONSE.include? post_response.status_code
    post_response
  end

  def remove_webhook
    http_client = build_http_client
    remove_webhook_uri = URI(REGISTER_WEBHOOK_URI)
    remove_webhook_uri.query = { user_id: user_id, events: %w[livestart liveend] }.to_param
    # webhook削除は対象ユーザーがツイキャスに存在しなくても200 OKになる模様
    delete_response = http_client.delete(remove_webhook_uri, header: SET_WEBHOOK_HEADERS)
    logger.debug delete_response.body
    delete_response
  end

  private

  def add_api_errormessage(api_response)
    response_hash = JSON.parse api_response.body
    if screen_id.blank?
      errors.add('screen_id', "can't be blank")
    else
      errors.add(screen_id, response_hash['error']['message'])
    end
  end

  def build_http_client
    http_client = HTTPClient.new
    http_client.debug_dev = STDOUT
    http_client
  end
end

# frozen_string_literal: true

# GetCommentsJob
class GetCommentsJob < ApplicationJob
  queue_as :default

  # 追記中のJSONファイルの配置場所
  TMP_FILE_DIR = 'movies/tmp/'
  # 完成したJSONファイルの配置場所
  SAVED_FILE_DIR = 'movies/target/'

  # rubocop:disable all
  # @param [String] movie_id
  # @param [String] screen_id
  # @param [String] comment_json_name コメントを追記する対象ファイル名
  def perform(movie_id, screen_id, comment_json_name)
    logger.info "#{screen_id}のコメント取得開始"
    File.open("#{TMP_FILE_DIR}#{comment_json_name}", 'w') do |file|
      hash = { comments: [] }
      JSON.dump hash, file
    end

    slice_id = nil
    get_count = 0
    while Movie.find(movie_id).is_live && (get_count < 2000)
      # while文が何回実行されたかをカウントする。liveendのwebhookを受信できず永遠に取得し続けることを防ぐ
      # 2000だと3時間以上は取得を続行
      get_count += 1
      logger.debug "#{screen_id}のコメント取得　#{get_count}回目の実行"

      # timerテーブルを確認し前回のAPI利用が一定秒より前だった場合にAPIを利用
      if !Timer.where('updated_at < ?', Time.current - Constants::API_INTERVAL.second).where(id: Constants::TIMER_ID).update(created_at: Time.current).empty?
        comments_response = get_comments movie_id, slice_id
        logger.debug comments_response.body
        response_hash = JSON.parse(comments_response.body)
        if (comments_response.status_code != 200) || response_hash['comments'].empty?
          sleep rand(Constants::API_INTERVAL + 1) + Constants::API_INTERVAL
          next
        end
        slice_id = response_hash['comments'][0]['id']
        write_response "#{TMP_FILE_DIR}#{comment_json_name}", response_hash
      else
        # 一定秒以上待機し、待機時間にランダム性を持たせるために下記のようにする
        sleep rand(Constants::API_INTERVAL + 1) + Constants::API_INTERVAL
        next
      end
      # 一度コメントを取得した後一定秒待機
      sleep rand(Constants::API_INTERVAL + 1) + Constants::API_INTERVAL
    end

    File.rename "#{TMP_FILE_DIR}#{comment_json_name}", "movies/target/#{screen_id}/#{comment_json_name}"
    logger.info "#{screen_id}のコメント取得終了"
  end

  # rubocop:enable all

  private

  # @param [String] movie_id
  # @param [Integer] slice_id
  # @return [HTTP::Message] コメント取得APIのレスポンス
  def get_comments(movie_id, slice_id)
    comments_uri = URI("#{Constants::SERVER_NAME}/movies/#{movie_id}/comments")
    comments_uri.query = { limit: 50, slice_id: slice_id }.to_param
    # 最終的にhttps://apiv2.twitcasting.tv/movies/564514963/comments?limit=50&slice_id=16733943101のようなURLになる

    http_client = HTTPClient.new
    header = { Accept: 'application/json', 'X-Api-Version': '2.0',
               Authorization: "Basic #{Rails.application.credentials.dig(:twitcasting, :basic_access_token)}" }
    comments_response = http_client.get(comments_uri, header: header)
    logger.debug comments_response.body
    comments_response
  end

  # @param [String] file_name 取得したコメントを書き込むJSONファイル
  # @param [Hash] response_hash コメント取得APIのレスポンスをパースしたHASH
  def write_response(file_name, response_hash)
    response_hash['comments'].each { |comment| comment['comment_time'] = Time.zone.at comment['created'] }
    File.open(file_name) do |io|
      written_hash = JSON.parse io.read
      written_hash['comments'] = written_hash['comments'] | response_hash['comments']
      written_hash['comments'].sort_by { |a| a[:id] }
      File.open(file_name, 'w') do |io2|
        JSON.dump written_hash, io2
      end
    end
  end
end

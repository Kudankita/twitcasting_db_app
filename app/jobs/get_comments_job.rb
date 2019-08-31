# frozen_string_literal: true

class GetCommentsJob < ApplicationJob
  queue_as :default2

  # 追記中のJSONファイルの配置場所
  TMP_FILE_DIR = 'movies/tmp/'
  # 完成したJSONファイルの配置場所
  SAVED_FILE_DIR = 'movies/target/'
  # TIMERテーブルのうちAPIに関する行を参照させるための指定
  # 基本的に1固定だが、今後増えたときに備える
  TIMER_ID = 1

  def perform(movie_id, screen_id, comment_json_name)
    File.open("#{TMP_FILE_DIR}#{comment_json_name}", 'w') do |file|
      hash = { coments: [] }
      JSON.dump hash, file
    end

    while Movie.find(movie_id).is_live
      # timerテーブルを確認し前回のAPI利用が一定秒より前だった場合にAPIを利用
      if !Timer.where('updated_at < ?', Time.current - Constants::API_INTERVAL.second).where(id: TIMER_ID).update(created_at: Time.current).empty?
        #TODO: あとで消す
        slice_id = nil
        get_comments(movie_id, slice_id)
      else
        # 一定秒以上待機し、待機時間にランダム性を持たせるために下記のようにする
        sleep rand(Constants::API_INTERVAL + 1) + Constants::API_INTERVAL
        next
      end

      # 一度コメントを取得した後一定秒待機
      sleep rand(Constants::API_INTERVAL + 1) + Constants::API_INTERVAL
    end

    File.rename "movies/tmp/#{comment_json_name}", "movies/target/#{screen_id}/#{comment_json_name}"
  end

  private

  def get_comments(movie_id, slice_id)
    comments_uri = URI("#{Constants::SERVER_NAME}/movies/#{movie_id}/comments")
    comments_uri.query = {
        limit: 50, slice_id: slice_id
    }.to_param
    # 最終的にhttps://apiv2.twitcasting.tv/movies/564514963/comments?limit=50&slice_id=16733943101のようなURLになる

    clnt = HTTPClient.new
    header = { Accept: 'application/json', 'X-Api-Version': '2.0',
               Authorization: "Bearer #{Rails.application.credentials.dig(:twitcasting, :access_token)}" }
    comments_response = clnt.get(comments_uri, header: header)
    logger.debug comments_response.body

  end
end

# frozen_string_literal: true

class MoviesController < ApplicationController
  # 外部からのpostを受けたときにCSRF対策をしないようにするために設定
  protect_from_forgery with: :null_session

  # 動画の拡張子
  MOVIE_EXTENSION = '.mp4'

  def new
    # ライブ終了のwebhook受信時に録画する必要はないのでその場合終了する
    # ただし、コメントの取得終了のために今後実装を変更する必要はある
    if params[:movie][:is_live] == 'false'
      logger.info "screen_id: #{params[:movie][:screen_id]}の放送終了"
      return
    end
    user = User.find_by user_id: params[:movie][:user_id]
    if user.nil?
      logger.info "user_id: #{params[:movie][:user_id]}がテーブルに登録されていません"
      return
    elsif !user.is_recordable
      logger.info "screen_id: #{params[:movie][:screen_id]}は録画対象ではありません"
      return
    end
    # 「:」がファイル名に含まれているとWindowsで困るので置換
    fixed_screen_id = user.screen_id.gsub(':', '_')
    movie_file_name = "#{fixed_screen_id}(#{Time.zone.now.to_s :custom})#{MOVIE_EXTENSION}"
    RecordMovieJob.perform_later params[:movie][:hls_url], movie_file_name
  end
end

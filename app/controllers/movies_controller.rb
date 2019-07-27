# frozen_string_literal: true

class MoviesController < ApplicationController
  # 外部からのpostを受けたときにCSRF対策をしないようにするために設定
  protect_from_forgery with: :null_session

  # 動画の拡張子
  MOVIE_EXTENSION = '.mp4'

  def new
    user = User.find_by user_id: params[:movie][:user_id]
    if user.nil?
      logger.info "user_id: #{params[:movie][:user_id]}がテーブルに登録されていません"
      return
    elsif !user.is_recordable
      logger.info "screen_id: #{params[:movie][:screen_id]}は録画対象ではありません"
      return
    end
    movie_file_name = "#{user.screen_id}(#{Time.zone.now.to_s :custom})#{MOVIE_EXTENSION}"
    RecordMovieJob.perform_later params[:movie][:hls_url], movie_file_name
  end
end

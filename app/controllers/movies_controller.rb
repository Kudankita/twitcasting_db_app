# frozen_string_literal: true

class MoviesController < ApplicationController
  # 外部からのpostを受けたときにCSRF対策をしないようにするために設定
  protect_from_forgery with: :null_session

  # 動画の拡張子
  MOVIE_EXTENSION = '.mp4'

  def new
    # ライブ終了のwebhook受信時に録画する必要はないのでその場合終了する
    # ただし、コメントの取得終了のために今後実装を変更する必要はある
    if params[:event] == 'liveend'
      logger.info "screen_id: #{params[:movie][:user_id]}の放送終了"
      Movie.find_or_initialize_by(id: params[:movie][:id]).update(user_id: movie_params[:user_id],
                                                                  title: movie_params[:title],
                                                                  subtitle: movie_params[:subtitle],
                                                                  last_owner_comment: movie_params[:last_owner_comment],
                                                                  category: movie_params[:category],
                                                                  link: movie_params[:link],
                                                                  is_live: movie_params[:is_live],
                                                                  is_recorded: movie_params[:is_recorded],
                                                                  comment_count: movie_params[:comment_count],
                                                                  large_thumbnail: movie_params[:large_thumbnail],
                                                                  small_thumbnail: movie_params[:small_thumbnail],
                                                                  country: movie_params[:country],
                                                                  duration: movie_params[:duration],
                                                                  created: movie_params[:created],
                                                                  is_collabo: movie_params[:is_collabo],
                                                                  is_protected: movie_params[:is_protected],
                                                                  max_view_count: movie_params[:max_view_count],
                                                                  current_view_count: movie_params[:current_view_count],
                                                                  total_view_count: movie_params[:total_view_count],
                                                                  hls_url: movie_params[:hls_url])
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

    Movie.create movie_params

    # 「:」がファイル名に含まれているとWindowsで困るので置換
    fixed_screen_id = user.screen_id.gsub(':', '_')
    movie_file_name = "#{fixed_screen_id}(#{Time.zone.now.to_s :custom})#{MOVIE_EXTENSION}"
    RecordMovieJob.perform_later params[:movie][:hls_url], movie_file_name
  end

  private

  def movie_params
    params.require(:movie).permit(:id, :user_id, :title, :subtitle, :last_owner_comment, :category,
                                  :link, :is_live, :is_recorded, :comment_count, :large_thumbnail, :small_thumbnail, :country,
                                  :duration, :created, :is_collabo, :is_protected, :max_view_count, :current_view_count,
                                  :total_view_count, :hls_url)
  end
end

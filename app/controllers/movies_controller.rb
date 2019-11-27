# frozen_string_literal: true

class MoviesController < ApplicationController
  before_action :authenticate_user, only: [:index]
  # 外部からのpostを受けたときにCSRF対策をしないようにするために設定
  protect_from_forgery with: :null_session

  # 動画の拡張子
  MOVIE_EXTENSION = '.mp4'

  def new
    user = User.find_by user_id: params[:movie][:user_id]
    user&.update(last_cas: Time.zone.at(movie_params[:created].to_i).to_s(:datetime), is_casting: movie_params[:is_live],
                 comment_count: movie_params[:comment_count], max_view_count: movie_params[:max_view_count],
                 current_view_count: movie_params[:current_view_count],
                 total_view_count: movie_params[:total_view_count])
    # ライブ終了のwebhook受信時に録画する必要はないのでその場合終了する
    # ただし、コメントの取得終了のために今後実装を変更する必要はある
    if params[:event] == 'liveend'
      logger.info "user_id: #{params[:movie][:user_id]}の放送終了"
      movie = Movie.find_or_initialize_by(id: params[:movie][:id])
      movie.assign_attributes movie_params
      movie.save
      return
    end
    if user.nil?
      logger.info "user_id: #{params[:movie][:user_id]}がテーブルに登録されていません"
      return
    elsif !user.is_recordable
      logger.info "screen_id: #{user.screen_id}は録画対象ではありません"
      return
    end

    Movie.create movie_params

    # 「:」がファイル、ディレクトリ名に含まれているとWindowsで困るので置換
    fixed_screen_id = user.screen_id.gsub(':', '_')

    FileUtils.mkdir_p "movies/target/#{fixed_screen_id}" unless Dir.exist? "movies/target/#{fixed_screen_id}"

    movie_file_name = "#{fixed_screen_id}(#{Time.zone.now.to_s :custom})#{MOVIE_EXTENSION}"
    # Job起動はこの順番でないと2つ目のJobが起動しない
    GetCommentsJob.perform_later params[:movie][:id], user.screen_id.gsub(':', '_'),
                                 "#{fixed_screen_id}(#{Time.zone.now.to_s :custom}).json"
    RecordMovieJob.perform_later params[:movie][:hls_url], movie_file_name, fixed_screen_id
  end

  def index
    @movies = Movie.joins('inner join users on movies.user_id = users.user_id').page(params[:page]).per(10)
                  .select('movies.updated_at,users.name,movies.title,users.is_recordable').order(updated_at: 'DESC')
  end

  private

  def movie_params
    params.require(:movie).permit(:id, :user_id, :title, :subtitle, :last_owner_comment, :category,
                                  :link, :is_live, :is_recorded, :comment_count, :large_thumbnail, :small_thumbnail, :country,
                                  :duration, :created, :is_collabo, :is_protected, :max_view_count, :current_view_count,
                                  :total_view_count, :hls_url)
  end
end

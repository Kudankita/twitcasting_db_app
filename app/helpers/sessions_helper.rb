# frozen_string_literal: true

module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(developer)
    session[:developer_id] = developer.id
  end

  # 現在ログインしているユーザーを返す (ユーザーがログイン中の場合のみ)
  def current_developer
    @current_developer ||= Developer.find_by(id: session[:developer_id])
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_developer.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    session.delete(:developer_id)
    @current_developer = nil
  end

  def authenticate_user
    current_developer
    if @current_developer.nil?
      flash[:notice] = 'ログインが必要です'
      redirect_to(login_url)
    end
  end
end

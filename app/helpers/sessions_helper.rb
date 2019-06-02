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
    p 'this is logged_in?'
    p current_developer
    !current_developer.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    session.delete(:developer_id)
    @current_developer = nil
  end
end

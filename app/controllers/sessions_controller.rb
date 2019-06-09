# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    developer = Developer.find_by(email: params[:session][:email].downcase)
    if developer&.authenticate(params[:session][:password])
      log_in developer
      redirect_to users_path
    else
      flash.now[:danger] = 'Invalid email/password combination'
      # エラーメッセージを作成する
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to login_url
  end
end

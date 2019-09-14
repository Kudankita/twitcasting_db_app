# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user].permit(:screen_id, :is_compression, :remark))
    if @user.valid? and [200, 201].include?(@user.register_and_save_user.status_code) and @user.save
      flash[:info] = 'ユーザーの新規登録に完了しました。'
      redirect_to users_path
    else
      render 'new'
    end
  end
end

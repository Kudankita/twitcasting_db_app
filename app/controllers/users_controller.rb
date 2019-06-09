# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user

  def index
    @message = 'test'
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user].permit(:screen_id, :is_compression, :remark))
    @user.save
    redirect_to users_path
  end
end

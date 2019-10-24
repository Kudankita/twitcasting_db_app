# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user

  def index
    @users = User.page(params[:page])
                 .per(10).select('id, screen_id, name, last_cas, is_recordable, is_casting').order(:screen_id)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user].permit(:screen_id, :is_compression, :remark))
    if Constants::REGISTER_WEBHOOK_OK_RESPONSE.include?(@user.register_and_save_user.status_code) and @user.save
      redirect_to users_path, flash: { info: 'ユーザーの新規登録に完了しました。' }
    else
      render 'new'
    end
  end

  def edit
    logger.debug 'delete'
    @user = User.find(params[:id])
  end

  def update
    logger.debug params
    @user = User.find(params[:id])
    before_recordable = @user.is_recordable
    @user.assign_attributes update_user_params
    @user.update_webhook_status @user.is_recordable if @user.valid? and @user.is_recordable != before_recordable
    unless @user.errors.empty?
      render 'edit'
      return
    end
    if @user.save
      redirect_to users_path, flash: { info: 'ユーザー情報の更新を完了しました。' }
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.update_webhook_status false
    unless @user.errors.empty?
      render 'edit'
      return
    end
    @user.destroy
    redirect_to users_path, flash: { info: 'ユーザー情報の削除を完了しました。' }
  end

  private

  def update_user_params
    params.require(:user).permit(:user_id, :screen_id, :name, :is_recordable, :remark, :is_compression, :is_deleted)
  end
end

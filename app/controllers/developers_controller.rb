# frozen_string_literal: true

# DevelopersController
class DevelopersController < ApplicationController
  def new
    @developer = Developer.new unless Rails.env.production?
  end

  def create
    # 実際には新規登録機能は不要なためproduction環境では機能を無効化
    return if Rails.env.production?

    @developer = Developer.new(user_params)
    if @developer.save
      log_in @developer
      flash[:success] = 'Welcome to the Sample App!'
    end
    render 'new'
  end

  private

  def user_params
    params.require(:developer).permit(:name, :email, :password,
                                      :password_confirmation)
  end
end

# frozen_string_literal: true

class DevelopersController < ApplicationController
  def new
    @developer = Developer.new
  end

  def create
    @developer = Developer.new(user_params)
    if @developer.save
      # TODO: 実際には新規ユーザ作成機能は不要。最後に削除
      log_in @developer
      flash[:success] = 'Welcome to the Sample App!'
      render 'new'
    else
      render 'new'
    end
  end

  private

  def user_params
    params.require(:developer).permit(:name, :email, :password,
                                      :password_confirmation)
  end
end

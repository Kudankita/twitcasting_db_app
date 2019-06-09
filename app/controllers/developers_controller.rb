# frozen_string_literal: true

class DevelopersController < ApplicationController
  def new
    @developer = Developer.new
    # if @developer.save
    #   # Handle a successful save.
    # else
    #   render 'new'
    # end
  end

  def create
    @developer = Developer.new(user_params)
    if @developer.save
      # TODO: flashが必要かも含めて遷移先を今後変更する
      # Handle a successful save.
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

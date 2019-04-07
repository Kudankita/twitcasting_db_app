# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @message = 'test'
    @users = User.all
  end
end

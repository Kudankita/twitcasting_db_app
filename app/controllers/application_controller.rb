# frozen_string_literal: true

# ApplicationController
# Controller全体でログインの確認を行うためSessionsHelperをinclude
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
end

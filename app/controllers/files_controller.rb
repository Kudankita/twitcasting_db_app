# frozen_string_literal: true

# FilesController
class FilesController < ApplicationController
  before_action :authenticate_user

  def delete
    Pathname.glob('movies/target/*/*').each do |file|
      logger.info "「#{file}」を削除"
      FileUtils.rm file
    end
  end
end

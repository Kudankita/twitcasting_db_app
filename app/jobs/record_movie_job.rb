# frozen_string_literal: true

class RecordMovieJob < ApplicationJob
  queue_as :default

  def perform(m3u8_url, movie_file_name)
    movie = Movie.new m3u8_url
    options = { custom: %w[-movflags faststart -c copy -bsf:a aac_adtstoasc] }
    movie.transcode movie_file_name, options
  end
end

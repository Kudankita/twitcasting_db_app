# frozen_string_literal: true

require 'net/http'

class RecordMovieJob < ApplicationJob
  queue_as :default

  def perform(m3u8_url, movie_file_name, screen_id)
    movie = ffmpeg_recorder m3u8_url
    options = { custom: %w[-movflags faststart -c copy -bsf:a aac_adtstoasc] }
    movie.transcode "movies/tmp/#{movie_file_name}", options
    File.rename("movies/tmp/#{movie_file_name}", "movies/target/#{screen_id}/#{movie_file_name}")
  end

  def ffmpeg_recorder(m3u8_url)
    FFMPEG::Movie.new m3u8_url
  end
end

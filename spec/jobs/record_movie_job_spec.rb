# frozen_string_literal: true

require 'rails_helper'
require 'fakefs/spec_helpers'

RSpec.describe RecordMovieJob, type: :job do
  include ActiveJob::TestHelper
  include FakeFS::SpecHelpers

  let(:movie_file_name) { 'twitcasting_jp(2004年11月24日11時44分44秒).mp4' }
  let(:screen_id) { 'twitcasting_jp' }

  before do
    # 本来controllerで作られるディレクトリ
    FileUtils.mkdir_p("movies/target/#{screen_id}")
    # tmpディレクトリは最初から存在するはずだがfakeFSを使っているとまず作成しなければならないようなので作成
    FileUtils.mkdir_p('movies/tmp')
    ffmpeg_mock = class_double('FFMPEG_mock')
    allow(ffmpeg_mock).to receive(:transcode) { FileUtils.touch "movies/tmp/#{movie_file_name}" }
    allow_any_instance_of(described_class).to receive(:ffmpeg_recorder).and_return(ffmpeg_mock)

    described_class.perform_now 'url', movie_file_name, screen_id
  end

  it '録画終了後動画ファイルがtargetフォルダ以下に移動すること' do
    expect(File).to exist("movies/target/#{screen_id}/#{movie_file_name}")
    expect(File).not_to exist("movies/tmp/#{movie_file_name}")
  end
end

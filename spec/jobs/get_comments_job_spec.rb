# frozen_string_literal: true

require 'rails_helper'
require 'fakefs/spec_helpers'

RSpec.describe GetCommentsJob, type: :job do
  include ActiveJob::TestHelper
  include FakeFS::SpecHelpers

  let(:comment_json_name) { 'twitcasting_jp(2004年11月24日11時44分44秒).json' }
  let(:saved_file_dir) { 'movies/target/' }
  let(:screen_id) { 'twitcasting_jp' }

  before do
    # 本来controllerで作られるディレクトリ
    FileUtils.mkdir_p("#{saved_file_dir}#{screen_id}")
    # tmpディレクトリは最初から存在するはずだがfakeFSを使っているとまず作成しなければならないようなので作成
    FileUtils.mkdir_p('movies/tmp')
  end

  context 'ジョブ開始後timerテーブルのcreated_timeが十分前で、一定時間後is_castingがfalseになりliveが終了した場合' do
    # 2回GET Commentを実行して1回目でid:1のコメント、2回めでid:2のコメントを取得したイメージ
    let(:spec_json) do
      { comments: [{ id: '1', message: 'メッセージ1', created: 1_555_330_964,
                     from_user: { screen_id: 'ユーザー1', name: 'ユーザー名1', image: 'http1',
                                  profile: 'プロフィール1', level: 1, last_movie_id: '1',
                                  is_live: false, supporter_count: 0, supporting_count: 0, created: 0 } },
                   { id: '2', message: 'メッセージ2', created: 1_555_330_964,
                     from_user: { screen_id: 'ユーザー2', name: 'ユーザー名2', image: 'http2',
                                  profile: 'プロフィール2', level: 2, last_movie_id: '2',
                                  is_live: false, supporter_count: 0, supporting_count: 0, created: 0 } }] }
    end
    # is_liveがtrueのMovieを登録（本来controllerで登録される）
    let(:ok_movie) { FactoryBot.create(:movie) }

    before do
      FactoryBot.create(:timer)
      p 'job start'
      GetCommentsJob.perform_now ok_movie.id, screen_id, comment_json_name
      sleep 20.seconds
      Movie.find(ok_movie.id).update(is_live: false)
    end
    xit 'コメントが書き込まれたJSONが保存されていること' do
      File.open("#{saved_file_dir}#{screen_id}/#{comment_json_name}") do |file|
        hash = JSON.load file
        expect(hash).to eq(spec_json)
      end

    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  describe 'POST /movies' do
    include ActiveJob::TestHelper
    ActiveJob::Base.queue_adapter = :test
    before do
      # 録画動画ファイルのファイル名を特定するために時間を固定
      clear_enqueued_jobs
      travel_to Time.zone.local(2004, 11, 24, 11, 44, 44)
      @movie_params = { signature: '09',
                        movie: {
                            id: '189037369',
                            user_id: '182224938',
                            title: 'ライブ',
                            subtitle: 'ライブ',
                            last_owner_comment: 'もいもい',
                            category: 'girls',
                            link: 'http://twitcasting.tv/twitcasting_jp/movie/189037369',
                            is_live: true,
                            is_recorded: false,
                            comment_count: 2124,
                            large_thumbnail: 'http',
                            small_thumbnail: 'http',
                            country: 'jp',
                            duration: 1186,
                            created: 1_438_500_282,
                            is_collabo: false,
                            is_protected: false,
                            max_view_count: 1675,
                            current_view_count: 20_848,
                            total_view_count: 20_848,
                            hls_url: 'm3u8'
                        },
                        broadcaster: {
                            id: '182224938',
                            screen_id: 'twitcasting_jp',
                            name: 'ツイキャス公式',
                            image: 'http',
                            profile: 'ツイキャス',
                            level: 24,
                            last_movie_id: '189037369',
                            is_live: false,
                            supporter_count: 0,
                            supporting_count: 0,
                            created: 0
                        } }
    end
    after do
      travel_back
    end
    context '録画する必要のあるIDのPOSTを受信したとき' do
      before do
        @user_to_record = User.create user_id: '182224938', screen_id: 'twitcasting_jp', is_recordable: true
        post movie_path, params: @movie_params
      end
      it '録画ジョブの引数にURLとファイル名が渡されて起動される' do
        expect(RecordMovieJob).to have_been_enqueued.with('m3u8', "#{@user_to_record.screen_id}(#{Time.zone.now.to_s :custom}).mp4")
      end
      it '正常なレスポンスを返す' do
        expect(response).to be_successful
      end
    end

    context '録画終了のPOSTを受信したとき' do
      before do
        @user_to_record = User.create user_id: '182224938', screen_id: 'twitcasting_jp', is_recordable: true
        # is_live(ライブ配信中かどうか)がfalseのボディを作成
        movie_params_live_false = @movie_params
        movie_params_live_false[:movie][:is_live] = 'false'
        post movie_path, params: movie_params_live_false
      end
      it '録画ジョブが起動しない' do
        expect(RecordMovieJob).not_to have_been_enqueued
      end
      it '正常なレスポンスを返す' do
        expect(response).to be_successful
      end
    end

    context '録画はしないIDのPOSTを正常に受信したとき' do
      before do
        # is_recordableがfalseなレコードを登録
        @user_to_record = User.create user_id: '182224938', screen_id: 'twitcasting_jp', is_recordable: false
        post movie_path, params: @movie_params
      end
      it '録画ジョブが起動しない' do
        expect(RecordMovieJob).not_to have_been_enqueued
      end
      it '正常なレスポンスを返す' do
        expect(response).to be_successful
      end
    end
    context 'DBで見つからないIDのPOSTを正常に受信したとき' do
      before do
        # Userを登録しないでpostを実施
        post movie_path, params: @movie_params
      end
      it '録画ジョブが起動しない' do
        expect(RecordMovieJob).not_to have_been_enqueued
      end
      it '正常なレスポンスを返す' do
        expect(response).to be_successful
      end
    end

    context '録画する必要のあるIDのPOSTを受信し、そのscreen_idに:が含まれていたとき' do
      before do
        @user_to_record = User.create user_id: '182224938', screen_id: 'twitcasting:jp', is_recordable: true
        post movie_path, params: @movie_params
      end
      it '録画ジョブの引数にURLとscreen_idが変換されたファイル名が渡されて起動される' do
        expect(RecordMovieJob).to have_been_enqueued.with('m3u8', 'twitcasting_jp(2004年11月24日11時44分44秒).mp4')
      end
      it '正常なレスポンスを返す' do
        expect(response).to be_successful
      end
    end
  end
end

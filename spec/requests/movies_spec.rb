# frozen_string_literal: true

require 'rails_helper'
require 'fakefs/spec_helpers'

RSpec.describe 'Movies', type: :request do
  describe 'POST /movies' do
    include ActiveJob::TestHelper
    include FakeFS::SpecHelpers
    ActiveJob::Base.queue_adapter = :test
    before do
      # 録画動画ファイルのファイル名を特定するために時間を固定
      clear_enqueued_jobs
      travel_to Time.zone.local(2004, 11, 24, 11, 44, 44)
      @movie_params = { signature: '09',
                        event: 'livestart',
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

    shared_examples 'レスポンス' do
      it '正常なレスポンスを返すこと' do
        expect(response).to be_successful
      end
    end

    context '録画する必要のあるIDのPOSTを受信したとき' do
      before do
        @user_to_record = FactoryBot.create(:user)
      end
      context '保存先のディレクトリが存在しないとき' do
        before do
          post movie_path, params: @movie_params
        end

        it '録画ジョブの引数にURLとファイル名が渡されて起動される' do
          expect(RecordMovieJob).to have_been_enqueued.with('m3u8', "#{@user_to_record.screen_id}(#{Time.zone.now.to_s :custom}).mp4", @user_to_record.screen_id)
        end

        it 'コメント取得ジョブの引数にmovie_id、screen_id, ファイル名が渡されて起動される' do
          expect(GetCommentsJob).to have_been_enqueued.with('189037369', @user_to_record.screen_id, "#{@user_to_record.screen_id}(#{Time.zone.now.to_s :custom}).json")
        end

        it 'Movieテーブルに受信したデータが登録される' do
          expect(Movie.find_by(id: '189037369')).to have_attributes(user_id: '182224938', title: 'ライブ',
                                                                    subtitle: 'ライブ', last_owner_comment: 'もいもい',
                                                                    category: 'girls',
                                                                    link: 'http://twitcasting.tv/twitcasting_jp/movie/189037369',
                                                                    is_live: true, is_recorded: false,
                                                                    comment_count: 2124, large_thumbnail: 'http',
                                                                    small_thumbnail: 'http', country: 'jp',
                                                                    duration: 1186, created: 1_438_500_282,
                                                                    is_collabo: false, is_protected: false,
                                                                    max_view_count: 1675, current_view_count: 20_848,
                                                                    total_view_count: 20_848, hls_url: 'm3u8')
        end

        it_behaves_like 'レスポンス'

        it 'ディレクトリが作成されること' do
          expect(Dir).to exist('movies/target/twitcasting_jp')
        end
      end

      context '保存先のディレクトリがすでに存在する場合' do
        before do
          # すでにディレクトリが存在する状況をつくる
          FileUtils.mkdir_p 'movies/target/twitcasting_jp'
          post movie_path, params: @movie_params
        end

        it 'ディレクトリが存在すること' do
          expect(Dir).to exist('movies/target/twitcasting_jp')
        end
      end
    end

    context '録画終了のPOSTを受信したとき' do
      context '録画開始時にMovieの情報を保存していた場合' do
        before do
          @user_to_record = FactoryBot.create(:user)
          # livestart受信時にデータを保存したイメージ
          Movie.create id: '189037369', user_id: '182224938', comment_count: 2124
          # event webhook送信の契機をライブ終了を意味するliveendにして試験
          movie_params_live_false = @movie_params
          movie_params_live_false[:event] = 'liveend'
          # 更新されていることを確認するためにcomment_countを変更
          movie_params_live_false[:movie][:comment_count] = 5000
          post movie_path, params: movie_params_live_false
        end

        it '録画ジョブが起動しない' do
          expect(RecordMovieJob).not_to have_been_enqueued
        end

        it 'コメント取得ジョブが起動しない' do
          expect(GetCommentsJob).not_to have_been_enqueued
        end

        it 'Movieテーブルのデータが受信したデータで更新される' do
          expect(Movie.find_by(id: '189037369')).to have_attributes(user_id: '182224938', comment_count: 5000)
        end

        it 'Movieテーブルのデータ登録数は1である' do
          expect(Movie.count).to eq(1)
        end

        it_behaves_like 'レスポンス'
      end
      context '録画開始時はアプリが正常動作しておらずMovieの情報が保存されていなかった場合' do
        before do
          @user_to_record = FactoryBot.create(:user)
          # event webhook送信の契機をライブ終了を意味するliveendにして試験
          movie_params_live_false = @movie_params
          movie_params_live_false[:event] = 'liveend'
          post movie_path, params: movie_params_live_false
        end

        it '録画ジョブが起動しない' do
          expect(RecordMovieJob).not_to have_been_enqueued
        end

        it 'コメント取得ジョブが起動しない' do
          expect(GetCommentsJob).not_to have_been_enqueued
        end

        it 'Movieテーブルに受信したデータが登録される' do
          expect(Movie.find_by(id: '189037369')).to have_attributes(user_id: '182224938', title: 'ライブ',
                                                                    subtitle: 'ライブ', last_owner_comment: 'もいもい',
                                                                    category: 'girls',
                                                                    link: 'http://twitcasting.tv/twitcasting_jp/movie/189037369',
                                                                    is_live: true, is_recorded: false,
                                                                    comment_count: 2124, large_thumbnail: 'http',
                                                                    small_thumbnail: 'http', country: 'jp',
                                                                    duration: 1186, created: 1_438_500_282,
                                                                    is_collabo: false, is_protected: false,
                                                                    max_view_count: 1675, current_view_count: 20_848,
                                                                    total_view_count: 20_848, hls_url: 'm3u8')
        end

        it 'Movieテーブルのデータ登録数は1である' do
          expect(Movie.count).to eq(1)
        end

        it_behaves_like 'レスポンス'
      end
    end

    context '録画はしないIDのPOSTを正常に受信したとき' do
      before do
        @user_to_record = FactoryBot.create(:record_false_user)
        post movie_path, params: @movie_params
      end

      it '録画ジョブが起動しない' do
        expect(RecordMovieJob).not_to have_been_enqueued
      end

      it 'コメント取得ジョブが起動しない' do
        expect(GetCommentsJob).not_to have_been_enqueued
      end

      it 'Movieテーブルに受信したデータが登録されない' do
        expect(Movie.count).to eq(0)
      end

      it_behaves_like 'レスポンス'
    end

    context 'DBで見つからないIDのPOSTを正常に受信したとき' do
      before do
        # Userを登録しないでpostを実施
        post movie_path, params: @movie_params
      end

      it '録画ジョブが起動しない' do
        expect(RecordMovieJob).not_to have_been_enqueued
      end

      it 'コメント取得ジョブが起動しない' do
        expect(GetCommentsJob).not_to have_been_enqueued
      end

      it 'Movieテーブルに受信したデータが登録されない' do
        expect(Movie.count).to eq(0)
      end

      it_behaves_like 'レスポンス'
    end

    context '録画する必要のあるIDのPOSTを受信し、そのscreen_idに:が含まれていたとき' do
      before do
        @user_to_record = FactoryBot.create(:user)
      end

      context '保存先のディレクトリが存在しないとき' do
        before do
          post movie_path, params: @movie_params
        end

        it '録画ジョブの引数にURLとscreen_idが変換されたファイル名が渡されて起動される' do
          expect(RecordMovieJob).to have_been_enqueued.with('m3u8', 'twitcasting_jp(2004年11月24日11時44分44秒).mp4', 'twitcasting_jp')
        end

        it 'コメント取得ジョブの引数にscreen_idが変換されて渡される' do
          expect(GetCommentsJob).to have_been_enqueued.with('189037369', 'twitcasting_jp', 'twitcasting_jp(2004年11月24日11時44分44秒).json')
        end

        it 'Movieテーブルに受信したデータが登録される' do
          # screen_idの変換はMovieテーブルには関係しない
          expect(Movie.find_by(id: '189037369')).to have_attributes(user_id: '182224938', title: 'ライブ',
                                                                    subtitle: 'ライブ', last_owner_comment: 'もいもい',
                                                                    category: 'girls',
                                                                    link: 'http://twitcasting.tv/twitcasting_jp/movie/189037369',
                                                                    is_live: true, is_recorded: false,
                                                                    comment_count: 2124, large_thumbnail: 'http',
                                                                    small_thumbnail: 'http', country: 'jp',
                                                                    duration: 1186, created: 1_438_500_282,
                                                                    is_collabo: false, is_protected: false,
                                                                    max_view_count: 1675, current_view_count: 20_848,
                                                                    total_view_count: 20_848, hls_url: 'm3u8')
        end

        it '変換後のscreen_idでディレクトリが作成されること' do
          expect(Dir).to exist('movies/target/twitcasting_jp')
        end

        it_behaves_like 'レスポンス'
      end
      context '保存先のディレクトリがすでに存在する場合' do
        before do
          # すでにディレクトリが存在する状況をつくる
          FileUtils.mkdir_p 'movies/target/twitcasting_jp'
          post movie_path, params: @movie_params
        end

        it 'ディレクトリが存在すること' do
          expect(Dir).to exist('movies/target/twitcasting_jp')
        end
      end
    end
  end
end

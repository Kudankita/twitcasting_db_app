# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Files', type: :request do
  let(:developer) { FactoryBot.create(:developer) }

  describe 'GET /delete' do
    context 'ログインしていないとき' do
      it 'ログインページへリダイレクトする' do
        get files_delete_path, xhr: true
        expect(response).to redirect_to login_path
      end

      it 'リダイレクト後エラーメッセージが表示される' do
        get files_delete_path, xhr: true
        expect(flash[:notice]).to eq 'ログインが必要です'
      end
    end

    context 'ログインしているとき' do
      it '正常なレスポンスを返す' do
        post login_path, params: { session: { email: developer.email, password: developer.password } }
        get files_delete_path, xhr: true
        expect(response).to have_http_status '200'
      end
    end

    context '削除対象ファイルが存在するとき' do
      let(:directories) { %w[movies/target/twitcasting_jp movies/target/ruby] }
      let(:files_to_delete) do
        %w(movies/target/twitcasting_jp/twitcasting_jp(2004年11月24日11時44分44秒).mp4
           movies/target/twitcasting_jp/twitcasting_jp(2004年11月24日11時44分44秒).json
           movies/target/ruby/ruby(2004年11月24日11時44分44秒).json)
      end

      before do
        FileUtils.mkdir_p(directories)
        FileUtils.touch(files_to_delete)
      end

      after do
        directories.each do |directory|
          FileUtils.remove_dir(directory)
        end
      end

      it 'ファイルが削除されること' do
        post login_path, params: { session: { email: developer.email, password: developer.password } }
        get files_delete_path, xhr: true
        files_to_delete.each do |file|
          expect(File).not_to exist(file)
        end
      end
    end
  end
end

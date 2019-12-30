# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:developer) { FactoryBot.create(:developer) }

  describe 'GET /index' do
    context 'ログインしていないとき' do
      it 'ログインページへリダイレクトする' do
        get users_path
        expect(response).to redirect_to login_path
      end

      it 'リダイレクト後エラーメッセージが表示される' do
        get users_path
        expect(flash[:notice]).to eq 'ログインが必要です'
      end
    end

    context 'ログインしているとき' do
      it '正常なレスポンスを返す' do
        post login_path, params: { session: { email: developer.email, password: developer.password } }
        get users_path
        expect(response).to have_http_status '200'
      end
    end
  end

  describe 'GET /users/new' do
    context 'ログインしていないとき' do
      it 'ログインページへリダイレクトする' do
        get new_user_path
        expect(response).to redirect_to login_path
      end

      it 'リダイレクト後エラーメッセージが表示される' do
        get new_user_path
        expect(flash[:notice]).to eq 'ログインが必要です'
      end
    end

    context 'ログインしているとき' do
      it '正常なレスポンスを返す' do
        post login_path, params: { session: { email: developer.email, password: developer.password } }
        get users_path
        expect(response).to have_http_status '200'
      end
    end
  end

  describe 'GET /users/:id/edit' do
    let(:user) { FactoryBot.create(:user) }

    context 'ログインしていないとき' do
      before do
        get edit_user_path user
      end

      it 'ログインページへリダイレクトする' do
        expect(response).to redirect_to login_path
      end

      it 'リダイレクト後エラーメッセージが表示される' do
        expect(flash[:notice]).to eq 'ログインが必要です'
      end
    end

    context 'ログインしているとき' do
      before do
        post login_path, params: { session: { email: developer.email, password: developer.password } }
        get edit_user_path user
      end

      it '正常なレスポンスを返す' do
        expect(response).to have_http_status '200'
      end

      it 'user_idが表示される' do
        expect(response.body).to include('182224938')
      end

      it 'screen_idが表示される' do
        expect(response.body).to include 'twitcasting_jp'
      end

      it 'nameが表示される' do
        expect(response.body).to include 'ツイキャス公式'
      end
      # checkboxの状態はrequest specでは確認が難しいのでここでは確認しない
    end
  end
end

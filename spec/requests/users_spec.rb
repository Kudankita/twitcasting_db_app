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
        get users_new_path
        expect(response).to redirect_to login_path
      end
      it 'リダイレクト後エラーメッセージが表示される' do
        get users_new_path
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
end

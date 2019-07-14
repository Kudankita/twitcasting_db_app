# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /sessions' do
    it 'ログインページに遷移すると正常なレスポンスが帰ってくる' do
      get login_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /sessions' do
    let(:developer) { FactoryBot.create(:developer) }
    context '正常なデータがログインページからPOSTされたとき' do
      it '正常にログインできてユーザー一覧画面に遷移する' do
        post login_path, params: { session: { email: developer.email, password: developer.password } }
        expect(response).to redirect_to users_path
      end

      it '正常にログインできてセッションにIDが保存されている' do
        post login_path, params: { session: { email: developer.email, password: developer.password } }
        # developerは一人しか登録されていないので毎回IDは１になるはず
        expect(session[:developer_id]).to eq 1
      end
    end

    context '何も入力されないままPOSTされたとき' do
      it 'ログインできず再度同じページがレンダリングされてflashにエラーメッセージが表示される' do
        post login_path, params: { session: { email: '', password: '' } }
        expect(flash.now[:danger]).to eq 'Invalid email/password combination'
      end

      it 'sessionにIDが保存されない' do
        post login_path, params: { session: { email: '', password: '' } }
        expect(session[:developer_id]).to eq nil
      end
    end
    context 'テーブルに登録されているのと違う情報がPOSTされたとき' do
      it 'ログインできずflashにエラーメッセージが表示される' do
        post login_path, params: { session: { email: 'b' * 6, password: 'b' * 6 } }
        expect(flash.now[:danger]).to eq 'Invalid email/password combination'
      end

      it 'sessionにIDが保存されない' do
        post login_path, params: { session: { email: 'b' * 6, password: 'b' * 6 } }
        expect(session[:developer_id]).to eq nil
      end
    end
  end

  describe 'DELETE /logout' do
    context 'ログアウトした場合' do
      it 'sessionが削除される' do
        delete logout_path
        expect(session[:developer_id]).to eq nil
      end
      it 'ログインページにリダイレクトする' do
        delete logout_path
        expect(response).to redirect_to login_url
      end
    end
  end
end

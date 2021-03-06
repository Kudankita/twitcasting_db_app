# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Developers', type: :system do
  # 単純なログイン機能に関してはdevelopers_specでも実施しているのでここではしないことにする
  context '正常なログイン' do
    before do
      # まずログインする
      FactoryBot.create(:developer)
      visit login_path
      fill_in 'Email', with: 'rspec@test.com'
      fill_in 'Password', with: 'a' * 6
      click_button 'Log in'
    end

    it 'ログインしてからログアウトするとログインページ以外が閲覧できなくなる' do
      click_link 'サインアウト'
      expect(page).to have_current_path login_path, ignore_query: true
      # サインアウト後にUser一覧画面に遷移しようとするとログインページにリダイレクトしエラーメッセージが表示
      visit users_path
      expect(page).to have_current_path login_path, ignore_query: true
      expect(page).to have_content 'ログインが必要です'
      # User新規作成ページも同様
      visit new_user_path
      expect(page).to have_current_path login_path, ignore_query: true
      expect(page).to have_content 'ログインが必要です'
    end
  end
end

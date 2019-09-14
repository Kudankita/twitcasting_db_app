# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :system do
  before do
    FactoryBot.create(:timer)
    # まずログインする
    FactoryBot.create(:developer)
    visit login_path
    fill_in 'Email', with: 'rspec@test.com'
    fill_in 'Password', with: 'a' * 6
    click_button 'Log in'
  end
  it '正常に新しいUserを登録して一覧ページへ遷移する', :vcr do
    click_link '新規登録'
    # 登録に成功してデータが一つ増えていること
    expect do
      fill_in 'ID', with: 'a'
      check '圧縮する'
      fill_in '備考', with: 'a'
      click_button '登録'
    end.to change(User, :count).by(1)
    # 一覧ページへ遷移すること
    expect(current_path).to eq users_path
  end

  it 'screen_idを入力しないで登録しようとして失敗' do
    # 現在inputタグにrequireが指定されているので通常このパターンが発生することはない
    click_link '新規登録'
    expect do
      fill_in 'ID', with: ''
      check '圧縮する'
      fill_in '備考', with: 'a'
      click_button '登録'
    end.to change(User, :count).by(0)
    # 現状失敗時にusers_pathへ遷移するのでそれを検証する
    expect(current_path).to eq users_path
    # 空欄ではいけない、というエラーメッセージが出ていること
    expect(page).to have_content("Screen can't be blank")
  end

  it 'ツイキャスに存在しないIDを登録しようとして失敗', :vcr do
    click_link '新規登録'
    expect do
      fill_in 'ID', with: 'not_found'
      check '圧縮する'
      fill_in '備考', with: 'a'
      click_button '登録'
    end.to change(User, :count).by(0)
    # 現状失敗時にusers_pathへ遷移するのでそれを検証する
    expect(current_path).to eq users_path
    # Userがみつからない、というエラーメッセージが出ていること
    expect(page).to have_content('Not Found')
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Developers', type: :system do
  before do
    # まずログインする
    FactoryBot.create(:developer)
    visit login_path
    fill_in 'Email', with: 'rspec@test.com'
    fill_in 'Password', with: 'a' * 6
    click_button 'Log in'
  end
  it '正常に新しいUserを登録して一覧ページへ遷移する' do
    click_link '新規登録'
    # 登録に成功してデータが一つ増えていること
    expect do
      fill_in 'Screen', with: 'a'
      check 'Is compression'
      fill_in 'Remark', with: 'a'
      click_button 'Create User'
    end.to change(User, :count).by(1)
    # 一覧ページへ遷移すること
    expect(current_path).to eq users_path
  end

  it 'screen_idを入力しないで登録しようとして失敗' do
    click_link '新規登録'
    expect do
      fill_in 'Screen', with: ''
      check 'Is compression'
      fill_in 'Remark', with: 'a'
      click_button 'Create User'
    end.to change(User, :count).by(0)
    # 現状失敗時にusers_pathへ遷移するのでそれを検証する
    expect(current_path).to eq users_path
    # 空欄ではいけない、というエラーメッセージが出ていること
    expect(page).to have_content("Screen can't be blank")
  end
end

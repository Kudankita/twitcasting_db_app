# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Developers', type: :system do
  before do
    visit login_path
    click_link 'Sign up now!'
  end

  it '新規登録画面でログインできるユーザを新規登録する' do
    expect do
      fill_in 'Name', with: 'test'
      fill_in 'Email', with: 'system@test.com'
      fill_in 'Password', with: 'a' * 6
      fill_in 'Confirmation', with: 'a' * 6
      click_button 'Create my account'
    end.to change(Developer, :count).by(1)
  end

  it '名前が未入力のままボタンを押してエラーになる' do
    expect do
      fill_in 'Name', with: ''
      fill_in 'Email', with: 'system@test.com'
      fill_in 'Password', with: 'a' * 6
      fill_in 'Confirmation', with: 'a' * 6
      click_button 'Create my account'
    end.to change(Developer, :count).by(0)
    expect(page).to have_content("can't be blank")
  end
end

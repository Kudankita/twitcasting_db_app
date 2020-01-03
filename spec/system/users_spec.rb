# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :system do
  vcr_options = { match_requests_on: %i[method uri body] }
  let!(:user) { FactoryBot.create(:user) }
  let!(:user2) { FactoryBot.create(:user2) }
  let!(:user3) { FactoryBot.create(:user3) }

  before do
    FactoryBot.create(:timer)
    # まずログインする
    FactoryBot.create(:developer)
    visit login_path
    fill_in 'Email', with: 'rspec@test.com'
    fill_in 'Password', with: 'a' * 6
    click_button 'Log in'
  end

  it '正常に新しいUserを登録して一覧ページへ遷移する', vcr: vcr_options do
    click_link '新規登録'
    # 登録に成功してデータが一つ増えていること
    expect do
      fill_in 'ID', with: 'a'
      check '圧縮する'
      fill_in '備考', with: 'a'
      click_button '登録'
    end.to change(User, :count).by(1)
    # 一覧ページへ遷移すること
    expect(page).to have_current_path users_path, ignore_query: true
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
    expect(page).to have_current_path users_path, ignore_query: true
    # 空欄ではいけない、というエラーメッセージが出ていること
    expect(page).to have_content("Screen can't be blank")
  end

  it 'ツイキャスに存在しないIDを登録しようとして失敗', vcr: vcr_options do
    click_link '新規登録'
    expect do
      fill_in 'ID', with: 'not_found'
      check '圧縮する'
      fill_in '備考', with: 'a'
      click_button '登録'
    end.to change(User, :count).by(0)
    # 現状失敗時にusers_pathへ遷移するのでそれを検証する
    expect(page).to have_current_path users_path, ignore_query: true
    # Userがみつからない、というエラーメッセージが出ていること
    expect(page).to have_content('Not Found')
  end

  context 'ユーザーの一覧機能' do
    it 'ユーザー一覧ページにユーザーの情報がscreen_idでソートされて表示されている' do
      screen_ids = all('td:nth-child(1)').map(&:text)
      expect(screen_ids).to eq [user2.screen_id, user.screen_id, user3.screen_id]
      expect(page).to have_current_path users_path, ignore_query: true
    end
  end

  context 'ユーザーの詳細情報閲覧機能' do
    it 'リンクをクリックしたユーザーの詳細情報が表示されている' do
      click_link user.name
      expect(page).to have_current_path user_path user
      expect(page).to have_content(user.user_id)
      expect(page).to have_content(user.screen_id)
      expect(page).to have_content(user.name)
    end
  end

  context 'あるユーザーの更新、削除機能' do
    context '更新機能' do
      let(:not_found_user) { FactoryBot.create(:not_found_user, name: 'not_found', is_recordable: false) }
      let(:changed_name) { '変更後の名前' }
      let(:changed_remark) { '備考入力' }

      it 'ユーザーの情報を更新' do
        visit edit_user_path user
        fill_in 'ユーザー名', with: changed_name
        fill_in '備考', with: changed_remark
        click_button '登録'
        expect(user.reload.name).to eq changed_name
        expect(user.reload.remark).to eq changed_remark
        expect(page).to have_current_path users_path, ignore_query: true
        expect(page).to have_content(changed_name)
      end

      it '録画をするように更新したユーザーがツイキャスに存在せずエラー', vcr: vcr_options do
        visit edit_user_path not_found_user
        check '録画する'
        click_button '登録'
        expect(not_found_user.reload.is_recordable).to be_falsey
        expect(page).to have_content('Bad Request')
      end
    end

    context '削除機能' do
      it '削除ボタンのをクリックするとユーザーが削除', vcr: vcr_options do
        visit user_path user
        expect do
          click_link '削除'
        end.to change(User, :count).by(-1)
        expect(page).to have_current_path users_path, ignore_query: true
        expect(page).to have_content('ユーザー情報の削除を完了しました。')
        expect(page).not_to have_content('twitcasting_jp')
      end
    end
  end
end

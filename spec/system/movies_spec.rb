# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MyBehavior', type: :system do
  before do
    # まずログインする
    FactoryBot.create(:developer)
    visit login_path
    fill_in 'Email', with: 'rspec@test.com'
    fill_in 'Password', with: 'a' * 6
    click_button 'Log in'
  end

  context 'ログ一覧機能' do
    context '表示するログが１件の場合' do
      before do
        FactoryBot.create(:user)
        FactoryBot.create(:movie)
      end

      it 'ログ一覧ページに動画の情報が1件表示されること' do
        visit movies_path
        expect(page).to have_content '2016年05月29日00時55分00秒'
        expect(page).to have_content 'ツイキャス公式'
        expect(page).to have_content 'MyString'
        expect(page).to have_content '◯'
      end
    end

    context '表示するログが2件の場合' do
      before do
        FactoryBot.create(:user)
        FactoryBot.create(:movie)
        FactoryBot.create(:movie2)
      end

      it 'updated_atでソートされて新しいものが上に表示されていること' do
        visit movies_path
        titles = all('td:nth-child(3)').map(&:text)
        expect(titles).to eq %w[NewerMyString MyString]
      end
    end
  end
end

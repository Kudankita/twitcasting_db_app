# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'userの内容は正常な場合' do
    let(:user) { FactoryBot.build(:user) }

    describe '正常系' do
      context 'screen_idが存在し、テーブルに他のデータが登録されていない場合' do
        it '正常なデータと判定される' do
          expect(user).to be_valid
        end
      end
    end

    describe 'すでに同じscreen_idのデータがテーブルに登録されている場合' do
      it '不正なデータと判定される' do
        FactoryBot.create(:user)
        expect(user).to be_invalid
      end
    end
  end

  describe 'userの内容が不正な場合' do
    describe 'screen_idがない場合' do
      it '不正なデータと判定される' do
        expect(User.new).to be_invalid
      end
    end
  end
end

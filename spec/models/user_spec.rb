# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    FactoryBot.create(:timer)
  end
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

  describe '#register_and_save_user' do
    context 'webhookに登録されていないが、ツイキャスには存在する正しいIDを登録する場合' do
      let(:user) { FactoryBot.build(:user) }
      let(:success_response_code) { 201 }
      vcr_options = { match_requests_on: %i[method uri body] }
      it 'Register WebHookへのrequestの正常なresponseがメソッドの返り値になること', vcr: vcr_options do
        expect(user.register_and_save_user.status_code).to eq success_response_code
      end
    end

    context 'ツイキャスには存在しないIDを登録する場合' do
      let(:user) { FactoryBot.build(:not_found_user) }
      let(:not_found_response_code) { 404 }
      vcr_options = { match_requests_on: %i[method uri body] }
      it 'Get User InfoのAPIの結果が404のエラーであること', vcr: vcr_options do
        expect(user.register_and_save_user.status_code).to eq not_found_response_code
      end
    end
  end
end

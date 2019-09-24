# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  vcr_options = { match_requests_on: %i[method uri body] }
  before do
    FactoryBot.create(:timer)
  end
  describe 'バリデーション' do
    describe '正常系' do
      context 'screen_idが存在し、テーブルに他のデータが登録されていない場合' do
        let(:user) { FactoryBot.build(:user) }
        it '正常なデータと判定される' do
          expect(user).to be_valid
        end
      end
    end

    describe 'すでに同じscreen_idのデータがテーブルに登録されている場合' do
      let(:user) { FactoryBot.build(:user) }
      it '不正なデータと判定される' do
        FactoryBot.create(:user)
        expect(user).to be_invalid
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

  describe '#register_and_save_user' do
    let(:success_response_code) { 201 }
    let(:not_found_response_code) { 404 }
    context 'webhookに登録されていないが、ツイキャスには存在する正しいIDを登録する場合' do
      let(:user) { FactoryBot.build(:user) }
      vcr_options = { match_requests_on: %i[method uri body] }
      it 'Register WebHookへのrequestの正常なresponseがメソッドの返り値になること', vcr: vcr_options do
        expect(user.register_and_save_user.status_code).to eq success_response_code
      end
    end

    context 'ツイキャスには存在しないIDを登録する場合' do
      let(:user) { FactoryBot.build(:not_found_user) }
      it 'Get User InfoのAPIの結果が404のエラーであること', vcr: vcr_options do
        expect(user.register_and_save_user.status_code).to eq not_found_response_code
      end
    end

    context 'screen_idが未入力で登録する場合' do
      let(:user) { User.new }
      it 'Get User InfoのAPIの結果が404のエラーであること', vcr: vcr_options do
        expect(user.register_and_save_user.status_code).to eq not_found_response_code
      end
    end
  end

  describe '#update_webhook_status' do
    context 'ツイキャスに存在するID' do
      let(:user) { FactoryBot.build(:user) }
      context 'webhookに登録する場合', vcr: vcr_options do
        it 'errorsが存在しないこと' do
          user.update_webhook_status true
          expect(user.errors).to be_blank
        end
      end

      context 'webhookから削除する場合' do
        it 'errorsが存在しないこと', vcr: vcr_options do
          user.update_webhook_status false
          expect(user.errors).to be_blank
        end
      end
    end

    context 'ツイキャスに存在しないID' do
      let(:user) { FactoryBot.build(:not_found_user) }
      context 'webhookに登録する場合' do
        it 'errorsが存在すること', vcr: vcr_options do
          user.update_webhook_status true
          expect(user.errors[:not_found]).to include('Bad Request')
        end
      end

      context 'webhookから削除する場合' do
        it 'errorsが存在しないこと', vcr: vcr_options do
          user.update_webhook_status false
          expect(user.errors).to be_blank
        end
      end
    end
  end
end

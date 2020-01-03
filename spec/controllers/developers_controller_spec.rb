# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevelopersController, type: :controller do
  let(:developer) { FactoryBot.build(:developer) }

  describe '#new' do
    it '正常にレスポンスを返すこと' do
      get :new
      expect(response).to be_successful
    end
  end

  describe '#create' do
    context '正常なデータが入力されたとき' do
      it '正常に登録できること' do
        post :create, params: { developer: { name: developer.name, email: developer.email, password: developer.password,
                                             password_confirmation: developer.password_confirmation } }
        expect(response).to be_successful
      end
    end
  end
end

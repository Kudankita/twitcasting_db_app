# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Developer, type: :model do
  before do
    @developer = FactoryBot.build(:developer)
  end
  describe '正常系' do
    context '名前、アドレス、パスワードすべてが問題ない場合' do
      it '正常なデータと判定される' do
        expect(@developer).to be_valid
      end
    end
  end

  describe 'nameのvalidation' do
    context '名前が存在しない場合' do
      it '不正なデータと判定される' do
        expect(FactoryBot.build(:developer, name: '')).to be_invalid
      end
    end
    context '名前の長さが50文字の場合' do
      it '正常なデータと判定される' do
        expect(FactoryBot.build(:developer, name: 'a' * 50)).to be_valid
      end
    end
    context '名前の長さが51文字の場合' do
      it '不正なデータと判定される' do
        expect(FactoryBot.build(:developer, name: 'a' * 51)).to be_invalid
      end
    end
  end

  describe 'emailのvalidation' do
    context 'emailが存在しない場合' do
      it '不正なデータと判定されること' do
        expect(FactoryBot.build(:developer, email: '')).to be_invalid
      end
    end
    context 'emailの長さが255文字のとき' do
      it '正常なデータと判定されること' do
        expect(FactoryBot.build(:developer, email: 'a' * 246 + '@test.com')).to be_valid
      end
    end
    context 'emailの長さが256文字のとき' do
      it '不正なデータと判定されること' do
        expect(FactoryBot.build(:developer, email: 'a' * 247 + '@test.com')).to be_invalid
      end
    end
    context '正しい形式のメールアドレスのとき' do
      it '正常なデータと判定されること' do
        valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                             first.last@foo.jp alice+bob@baz.cn]
        valid_addresses.each do |valid_address|
          expect(FactoryBot.build(:developer, email: valid_address)).to be_valid, "#{valid_address.inspect} should be valid"
        end
      end
    end
    context '異常な形式のメールアドレスのとき' do
      it '不正なデータと判定されること' do
        invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                               foo@bar_baz.com foo@bar+baz.com user@example..com]
        invalid_addresses.each do |invalid_address|
          expect(FactoryBot.build(:developer, email: invalid_address)).to be_invalid, "#{invalid_address.inspect} should be invalid"
        end
      end
    end
    context '同じメールアドレスが登録されたとき' do
      it '不正なデータと判定されること' do
        FactoryBot.create(:developer)
        expect(FactoryBot.build(:developer)).to be_invalid
      end
    end
    context '大文字小文字の違いがあるが同じメールアドレスが登録されたとき' do
      it '不正なデータと判定されること' do
        email = 'user@example.com'
        FactoryBot.create(:developer, email: email)
        expect(FactoryBot.build(:developer, email: email.upcase)).to be_invalid
      end
    end
  end
  describe 'passwordのvalidation' do
    context 'パスワードの長さが5文字のとき' do
      it '不正なデータと判定されること' do
        invalid_password = 'a' * 5
        expect(FactoryBot.build(:developer, password: invalid_password, password_confirmation: invalid_password)).to be_invalid
      end
    end
    context 'passwordとpassword_confirmationが異なるとき' do
      it '不正なデータと判定されること' do
        expect(FactoryBot.build(:developer, password: 'a' * 6, password_confirmation: 'b' * 6)).to be_invalid
      end
    end
  end
end

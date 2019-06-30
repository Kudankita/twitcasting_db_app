FactoryBot.define do
  factory :developer do
    name {'test'}
    email {'test@test.com'}
    password {'a' * 6}
    password_confirmation {'a' * 6}
  end
end

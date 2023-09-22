FactoryBot.define do
  factory :account do
    name { 'Test Account' }
    authentication_token { 'test-token' }
  end
end

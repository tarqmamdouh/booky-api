require 'faker'

FactoryBot.define do
  factory :user do
    password { Faker::Lorem.characters(number: 10) }
    email { Faker::Internet.email }
  end
end

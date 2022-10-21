require 'faker'

FactoryBot.define do
  factory :booking do
    name { Faker::Lorem.question }
    description { Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4) }
    user_id { FactoryBot.create(:user).id }
    start { DateTime.now }
    self.end { DateTime.now + 15.minutes }
  end
end

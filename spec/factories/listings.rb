FactoryGirl.define do
  factory :listing do
    title { Faker::Lorem.characters(15) }
    img { Faker::Lorem.characters(15) }
    price { Faker::Number.number(6)}
  end

end

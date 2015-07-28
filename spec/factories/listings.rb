FactoryGirl.define do
  factory :listing do
    title { Faker::Lorem.characters(15) }
    img { Faker::Lorem.characters(15) }
    price { Faker::Number.number(6)}
    link {'http://www.gallito.com.uy/gran-oportunidad-impecable-inmuebles-8801267'}
  end

end

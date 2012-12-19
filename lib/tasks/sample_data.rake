namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Ric",
                 email: "ricardocarballo@gmail.com",
                 password: "123456",
                 password_confirmation: "123456",
                 vote: true)
    admin.toggle!(:admin)
    10.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@gmail.com"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
    users = User.all(limit: 6)
    5.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.microposts.create!(content: content,
                                                  votes_round1: 0,
                                                  votes_round2: 0) 
                  }
    end
  end
end
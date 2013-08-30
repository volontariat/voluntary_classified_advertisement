def r_str
  SecureRandom.hex(3)
end

def resource_has_many(resource, association_name)
  association = if resource.send(association_name).length > 0
    nil
  elsif association_name.to_s.classify.constantize.count > 0
    association_name.to_s.classify.constantize.last
  else
    Factory.create association_name.to_s.singularize.to_sym
  end
  
  resource.send(association_name).send('<<', association) if association
end

FactoryGirl.define do
  # Core factories begin
  factory :user do
    sequence(:name) { |n| "user#{n}#{r_str}" }
    sequence(:email) { |n| "user#{n}#{r_str}@volontari.at" }
    first_name 'Mister'
    last_name { |u| u.name.humanize }
    country 'Germany'
    language 'en'
    interface_language 'en'
    password 'password'
    password_confirmation { |u| u.password }
    
    #after_create do |user|
    #  User.confirm_by_token(user.confirmation_token)
    #end
  end
  
  factory :area do
    sequence(:name) { |n| "area #{n}" }
  end
  # Core factories end 
  
  factory :product do
    name 'Dummy'
    user_id FactoryGirl.create(:user, password: 'password', password_confirmation: 'password').id
    area_ids [Area.first.try(:id) || FactoryGirl.create(:area).id]
    text Faker::Lorem.sentences(5).join(' ')
    
    after_build do |product|
      product.id = product.name.to_s.parameterize
    end
    
    factory :classified_advertising_product, class: Product::ClassifiedAdvertising do
      name 'Classified Advertising'
    end
  end
  
  factory :project do
    association :user
    sequence(:name) { |n| "project #{n}#{r_str}" }
    text Faker::Lorem.sentences(20).join(' ')
    
    after_build do |project|
      resource_has_many(project, :areas) 
    end
    
    factory :classified_advertising_project do
      association :product, factory: :classified_advertising_product
      
      factory :classified_advertising_project_with_story do
        after_create do |project|
          project.stories << Factory.create(:classified_advertising_story, project: project)
        end
      end
    end
  end

  factory :story do
    association :project, factory: :project
    sequence(:name) { |n| "story#{n}#{r_str}" }
    text Faker::Lorem.sentences(10).join(' ')
    event 'initialization'
    state_before 'new'
    state 'initialized'
    
    #after_build do |story|
    #  story.tasks << Factory.build(:task)
    #end
    
    factory :classified_advertising_story, class: Product::ClassifiedAdvertising::Story do
      association :project, factory: :classified_advertising_project
    end
  end
  
  factory :task do
    sequence(:name) { |n| "task#{n}#{r_str}" }
    text Faker::Lorem.sentences(10).join(' ')
    
    factory :classified_advertising_task, class: Product::ClassifiedAdvertising::Task do
    end
  end
  
  factory :vacancy do
    association :project
    association :resource, factory: :user
    sequence(:name) { |n| "vacancy #{n}" }
    text Faker::Lorem.sentences(20).join(' ')
    limit 1
    state 'open'
    
    factory :classified_advertising_vacancy, class: Product::ClassifiedAdvertising::Vacancy do
      association :task
    end
  end
end

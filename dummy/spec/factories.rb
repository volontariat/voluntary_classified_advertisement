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
  Voluntary::Test::RspecHelpers::Factories.code.call(self)
  
  factory :classified_advertisement_product, parent: :product, class: Product::ClassifiedAdvertisement do
    name 'Classified Advertisement'
  end
  
  factory :classified_advertisement_project, parent: :project do
    association :product, factory: :classified_advertisement_product
    
    factory :classified_advertisement_project_with_story do
      after_create do |project|
        project.stories << Factory.create(:classified_advertisement_story, project: project, task_factory: nil)
      end
    end
  end
  
  factory :classified_advertisement_story, parent: :story, class: Product::ClassifiedAdvertisement::Story do
    association :project, factory: :classified_advertisement_project
      
    ignore { task_factory :classified_advertisement_task }
  end
  
  factory :classified_advertisement_task, parent: :task, class: Product::ClassifiedAdvertisement::Task do
    factory :classified_advertisement_task_with_one_vacancy do
      after_create do |task|
        tasks.vacancies << Factory.create(:classified_advertisement_vacancy, task: task)
      end
    end
  end
  
  factory :classified_advertisement_vacancy, parent: :vacancy, class: Product::ClassifiedAdvertisement::Vacancy do
    association :task, factory: :classified_advertisement_task
  end
end

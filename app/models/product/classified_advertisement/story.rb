class Product::ClassifiedAdvertisement::Story < Story
  has_many :tasks, dependent: :destroy, class_name: 'Product::ClassifiedAdvertisement::Task', inverse_of: :story
  
  field :address, type: String
  field :lat, type: String
  field :lon, type: String
  field :address_description, type: String
  
  attr_accessible :address, :lat, :lon, :address_description
  
  def after_creation_path
    Rails.application.routes.url_helpers.story_tasks_path(self)
  end
  
  def custom_tasks
    tasks.order('from ASC, to ASC')
  end
end
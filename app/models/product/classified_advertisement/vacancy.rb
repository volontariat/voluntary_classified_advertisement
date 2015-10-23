class Product::ClassifiedAdvertisement::Vacancy < ::Vacancy
  has_many :candidatures, dependent: :destroy, class_name: 'Product::ClassifiedAdvertisement::Candidature', inverse_of: :vacancy
  
  attr_accessible :task_id, :task
  
  after_initialize :set_defaults
  after_update :set_cached_task_attributes
  
  def task
    @task ||= task_class.where(id: task_id).first
  end
  
  def task=(value)
    self.task_id = value.try(:id).try(:to_s)
    @task = value
  end
  
  def task_class
    if product.present?
      "#{product.class.name}::Task".constantize rescue Task
    else
      Task
    end
  end
  
  def candidature_class
    if product.present?
      "#{product.class.name}::Candidature".constantize rescue Candidature
    else
      Candidature
    end
  end
  
  def product
    @product ||= project.product if project
  end
  
  def calculate_accepted_candidatures_amount
    candidatures.accepted.sum('amount')
  end
  
  def create_project_user?
    false
  end
  
  protected
  
  def set_defaults
    self.project ||= task.try(:story).try(:project)
    
    super
  end
  
  private
  
  def set_cached_task_attributes
    task.update_attributes(from: from, to: to, resource_type: resource_type)
  end
end
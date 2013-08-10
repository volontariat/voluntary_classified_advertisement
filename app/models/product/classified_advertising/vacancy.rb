class Product::ClassifiedAdvertising::Vacancy < ::Vacancy
  attr_accessible :task_id, :task
  
  validates :task_id, presence: true
  
  def product
    task.try(:product)
  end
  
  def task
    @task ||= task_id ? Task.find(task_id) : nil
  end
  
  def task=(value)
    task_id = value.try(:id)
    @task = value
  end
  
  protected
  
  def set_defaults
    self.project ||= task.try(:story).try(:project)
    
    super
  end
end
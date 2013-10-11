class Product::ClassifiedAdvertising::Vacancy < ::Vacancy
  attr_accessible :task_id, :task

=begin
  has_many :candidatures, -> do
    order(%Q{
      CASE 
        WHEN candidatures.state='new' THEN 1 
        WHEN candidatures.state='accepted' THEN 2 
        WHEN candidatures.state='denied' THEN 3 
        ELSE 4 
      END
    })
  end
=end

  validates :task, presence: true
  
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
  
  #def new_or_accepted_candidature
  #  candidatures.where(state: ['new', 'accepted']).first
  #end
  
  #def denied_candidatures
  #  candidatures.where(state: 'denied')
  #end
  
  protected
  
  def set_defaults
    self.project ||= task.try(:story).try(:project)
    
    super
  end
end
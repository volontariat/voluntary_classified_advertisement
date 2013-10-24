class Product::ClassifiedAdvertisement::Vacancy < ::Vacancy
  has_many :candidatures, dependent: :destroy, class_name: 'Product::ClassifiedAdvertisement::Candidature', inverse_of: :vacancy
  
  attr_accessible :task_id, :task
  
  after_initialize :set_defaults

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
  
  def candidatures_attributes=(attributes)
    self.candidatures ||= []
    
    attributes.each do |index, candidature_attributes|
      destroy = candidature_attributes.delete :_destroy
      
      if candidature_attributes[:id].present? && destroy.to_i == 1
        begin; candidature_class.destroy(candidature_attributes[:id]); rescue ActiveRecord::RecordNotFound; end
        @candidatures.select!{|v| v.id != candidature_attributes[:id]}
        next
      end
      
      candidature_attributes[:vacancy] = self
      candidature = nil
      
      if candidature_attributes[:id].present?
        begin; candidature = candidature_class.find(candidature_attributes[:id]); rescue ActiveRecord::RecordNotFound; end
        
        candidature_attributes.delete(:id)
        
        candidature.attributes = candidature_attributes if candidature.present?
      else
        candidature = candidature_class.new(candidature_attributes)
      end
      
      next unless candidature.present?
      
      if candidature_attributes[:id].present?
        self.candidatures.each_with_index do |current_candidature, candidatures_index|
          if current_candidature.id.to_s == candidature_attributes[:id]
            self.candidatures[candidatures_index] = candidature
          end
        end
      else
        self.candidatures << candidature
      end
    end
  end
  
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
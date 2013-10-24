class Product::ClassifiedAdvertisement::Task < ::Task
  belongs_to :story, class_name: 'Product::ClassifiedAdvertisement::Story', inverse_of: :task
  
  attr_accessible :vacancies_attributes
  attr_writer :vacancies
  
  validates :text, presence: true
  
  validate :at_least_one_vacancy
  
  after_save :save_dependencies
  after_destroy :destroy_non_mongodb_records
  
  state_machine :state, initial: :new do
    state :under_supervision do
      validate :new_candidature_present?
    end
  end
  
  def vacancies
    @vacancies ||= new_record? ? [vacancy_class.new(task: self)] : vacancy_class.where(task_id: id.to_s)
  end
  
  def vacancies_attributes=(attributes = {})
    self.vacancies = [] if self.vacancies.length == 1 && self.vacancies.first.new_record?
    
    attributes.select{|k,v| (v[:name].present? && v[:text].present?) || v[:id].present? }.each do |index, vacancy_attributes|
      destroy = vacancy_attributes.delete :_destroy
      vacancy_attributes[:task] = self
      vacancy = nil
      
      if vacancy_attributes[:id].present? && destroy.to_i == 1
        begin; vacancy_class.destroy(vacancy_attributes[:id]); rescue ActiveRecord::RecordNotFound; end
        @vacancies.select!{|v| v.id != vacancy_attributes[:id]}
      elsif vacancy_attributes[:id].present?
        begin; vacancy = vacancy_class.find(vacancy_attributes[:id]); rescue ActiveRecord::RecordNotFound; end
        
        vacancy_id = vacancy_attributes.delete(:id)
        
        vacancy.update_attributes(vacancy_attributes) if vacancy.present?
        
        vacancy_attributes[:id] = vacancy_id
      else
        vacancy = vacancy_class.new(vacancy_attributes)
      end
      
      next unless vacancy.present?
      
      if vacancy_attributes[:id].present?
        self.vacancies.each_with_index do |current_vacancy, vacancies_index|
          if current_vacancy.id.to_s == vacancy_attributes[:id]
            self.vacancies[vacancies_index] = vacancy
          end
        end
      else
        self.vacancies << vacancy
      end
    end
  end
  
  def vacancies_attributes
    @vacancies_attributes ||= (vacancies.empty? ? [vacancy_class.new(task: self)] : vacancies).map{|v| v.attributes}
  end
  
  def vacancy_class
    if product_id.present?
      "#{product.class.name}::Vacancy".constantize rescue ::Product::ClassifiedAdvertisement::Vacancy
    else
      ::Product::ClassifiedAdvertisement::Vacancy
    end
  end
  
  def with_result?
    false
  end
  
  def after_transition(transition)
    case transition.event
    when :follow_up
      vacancies.each do |vacancy|
        vacancy.candidatures.select{|c| c.state == 'new' || c.state == 'accepted'}.map(&:deny!)
      end
    when :complete
      vacancies.each do |vacancy|
        vacancy.candidatures.select{|c| c.state == 'new'}.map(&:accept!)
      end
    end
    
    super(transition)
  end
  
  private
  
  def at_least_one_vacancy
    unless vacancies.select(&:valid?).any?
      errors.add(:base, I18n.t('activerecord.errors.models.task.attributes.base.no_vacancies'))
    end
  end
  
  def save_dependencies
    vacancies.select(&:new_record?).each do |vacancy|
      vacancy.task = self
      vacancy.do_open
    end
  end
  
  def new_candidature_present?
    vacancies.each do |vacancy|
      new_candidatures = vacancy.candidatures.select{|c| c.state == 'new'}
      
      if new_candidatures.none?
        errors.add(
          :base, 
          I18n.t(
            'activerecord.errors.models.task.attributes.base.' + 
            'only_one_new_candidature'
          )
        )
      elsif new_candidatures.length == 1 && !new_candidatures.first.resource.valid?
        errors.add(
          :base, 
          I18n.t(
            'activerecord.errors.models.task.attributes.base.' + 
            'candidature_resource_invalid'
          )
        )  
      elsif new_candidatures.length != 1
        errors.add(
          :base, 
          I18n.t(
            'activerecord.errors.models.task.attributes.base.' + 
            'only_one_new_candidature'
          )
        )
      end
    end
  end
  
  def destroy_non_mongodb_records
    vacancies.destroy_all
  end
end
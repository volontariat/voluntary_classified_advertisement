class Product::ClassifiedAdvertising::Task < ::Task
  belongs_to :story, class_name: 'Product::ClassifiedAdvertising::Story', inverse_of: :task
  
  #accepts_nested_attributes_for :vacancies, allow_destroy: true, reject_if: ->(v) { v['name'].blank? && v['text'].blank? }
  attr_accessible :vacancies_attributes
  attr_writer :vacancies
  
  validate :at_least_one_vacancy
  
  #after_initialize :initialize_vacancies
  after_save :save_dependencies
  
  def vacancies
    @vacancies ||= new_record? ? [vacancy_class.new(task: self)] : vacancy_class.where(task_id: id)
  end
  
  def vacancies_attributes=(attributes)
    self.vacancies ||= []
    
    attributes.each do |index, vacancy_attributes|
      destroy = vacancy_attributes.delete :_destroy
      vacancy_attributes[:task] = self
      
      vacancy = if vacancy_attributes[:id].present?
        vacancy_class.find(vacancy_attributes[:id]).update_attributes(vacancy_attributes)
      else
        vacancy_class.new(vacancy_attributes)
      end
      
      if destroy && !vacancy.new_record?
        vacancy_class.destroy(vacancy.id)
      else
        self.vacancies << vacancy
      end
    end
  end
  
  #def vacancies_attributes
  #  @vacancies_attributes ||= (vacancies.empty? ? [vacancy_class.new(task: self)] : vacancies).map{|v| v.attributes}
  #end
  
  def vacancy_class
    if product_id.present?
      "#{product.class.name}::Vacancy".constantize rescue ::Product::ClassifiedAdvertising::Vacancy
    else
      ::Product::ClassifiedAdvertising::Vacancy
    end
  end
  
  #def initialize_vacancies
  #  vacancies_attributes 
  #end
  
  private
  
  def at_least_one_vacancy
    unless vacancies.select(&:valid?).any?
      errors.add(:base, I18n.t('activerecord.errors.models.task.attributes.base.no_vacancies'))
    end
  end
  
  def save_dependencies
    puts "save_dependencies: " + [@vacancies.try(:length), vacancies.try(:length)].inspect
    vacancies.select(&:new_record?).map(&:save)
  end
end
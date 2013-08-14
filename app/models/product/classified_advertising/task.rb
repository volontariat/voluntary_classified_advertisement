class Product::ClassifiedAdvertising::Task < ::Task
  belongs_to :story, class_name: 'Product::ClassifiedAdvertising::Story', inverse_of: :task
  
  attr_accessible :vacancies_attributes
  attr_writer :vacancies
  
  validates :text, presence: true
  
  validate :at_least_one_vacancy
  
  after_save :save_dependencies
  after_destroy :destroy_non_mongodb_records
  
  def vacancies
    @vacancies ||= new_record? ? [vacancy_class.new(task: self)] : vacancy_class.where(task_id: id.to_s)
  end
  
  def vacancies_attributes=(attributes = {})
    self.vacancies = [] if self.vacancies.length == 1 && self.vacancies.first.new_record?
    
    attributes.select{|k,v| v[:name].present? && v[:text].present? }.each do |index, vacancy_attributes|
      destroy = vacancy_attributes.delete :_destroy
      vacancy_attributes[:task] = self
      vacancy = nil
      
      if vacancy_attributes[:id].present? && destroy.to_i == 1
        begin; vacancy_class.destroy(vacancy_attributes[:id]); rescue ActiveRecord::RecordNotFound; end
        @vacancies.select!{|v| v.id != vacancy_attributes[:id]}
      elsif vacancy_attributes[:id].present?
        begin; vacancy = vacancy_class.find(vacancy_attributes[:id]); rescue ActiveRecord::RecordNotFound; end
        vacancy.update_attributes(vacancy_attributes) if vacancy.present?
      else
        vacancy = vacancy_class.new(vacancy_attributes)
      end
      
      self.vacancies << vacancy if vacancy.present? && !self.vacancies.include?(vacancy)
    end
  end
  
  def vacancies_attributes
    @vacancies_attributes ||= (vacancies.empty? ? [vacancy_class.new(task: self)] : vacancies).map{|v| v.attributes}
  end
  
  def vacancy_class
    if product_id.present?
      "#{product.class.name}::Vacancy".constantize rescue ::Product::ClassifiedAdvertising::Vacancy
    else
      ::Product::ClassifiedAdvertising::Vacancy
    end
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
  
  def destroy_non_mongodb_records
    vacancies.destroy_all
  end
end
class Product::ClassifiedAdvertisement::Task < ::Task
  belongs_to :story, class_name: 'Product::ClassifiedAdvertisement::Story', inverse_of: :task
  
  validates :text, presence: true
  
  attr_accessible :vacancy_attributes
  attr_writer :vacancy
  
  field :vacancy_id, type: Integer
  field :address, type: String
  field :lat, type: String
  field :lon, type: String
  field :address_description, type: String
  field :from, type: DateTime
  field :to, type: DateTime
  field :resource_type, type: String
  
  attr_accessible :address, :lat, :lon, :address_description, :from, :to, :resource_type
  
  after_create :set_vacancy_task_association
  after_destroy :destroy_non_mongodb_records
  
  def vacancy_attributes=(value)
    vacancy.update value
  end
  
  def vacancy
    @vacancy ||= new_record? ? vacancy_class.new(task: self) : vacancy_class.find(vacancy_id)
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
  
  def sign_up(current_user_id, amount = nil)
    amount = vacancy.resource_type == 'User' ? 1 : amount
    user_candidature = vacancy.candidatures.where(user_id: current_user_id).first
    
    if amount == user_candidature.try(:amount)
      return I18n.t('tasks.sign_up.already_signed_up')
    elsif vacancy.calculate_accepted_candidatures_amount == vacancy.limit && amount > user_candidature.try(:amount)
      return I18n.t('tasks.sign_up.limit_reached')
    end
    
    candidature = user_candidature ? user_candidature : vacancy.candidatures.new
    candidature.user_id = current_user_id
    candidature.resource_type = vacancy.resource_type
    candidature.resource_id = current_user_id if vacancy.resource_type == 'User'
    candidature.amount = amount
    user_candidature ? candidature.save : candidature.accept
    
    nil
  end
  
  def sign_out(current_user_id)
    user_candidature = vacancy.candidatures.where(user_id: current_user_id).first
    
    return I18n.t('tasks.sign_out.not_signed_up') unless user_candidature
      
    user_candidature.destroy
    
    nil
  end
  
  private
  
  def set_vacancy_task_association
    vacancy.do_open
    vacancy.task_id = id
    vacancy.save!
    update_attribute :vacancy_id, vacancy.id
  end
  
  def destroy_non_mongodb_records
    vacancy.destroy
  end
end
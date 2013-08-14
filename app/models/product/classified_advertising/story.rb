class Product::ClassifiedAdvertising::Story < Story
  has_many :tasks, dependent: :destroy, class_name: 'Product::ClassifiedAdvertising::Task', inverse_of: :story
  
  def tasks_attributes=(attributes)
    self.tasks ||= []
    
    attributes.each do |index, task_attributes|
      destroy = task_attributes.delete :_destroy
      
      if task_attributes[:id].present? && destroy.to_i == 1
        self.tasks.where(id: task_attributes[:id]).destroy_all
      elsif task_attributes[:id].present?
        tasks.find(task_attributes[:id]).update_attributes(task_attributes)
      else
        self.tasks.build(task_attributes)
      end
    end
  end
end
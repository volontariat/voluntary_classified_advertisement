class Product::ClassifiedAdvertising::Story < Story
  has_many :tasks, dependent: :destroy, class_name: 'Product::ClassifiedAdvertising::Task', inverse_of: :story
  
  def tasks_attributes=(attributes)
    self.tasks ||= []
    
    attributes.each do |index, task_attributes|
      destroy = task_attributes.delete :_destroy
      
      task = if task_attributes[:id].present?
        tasks.find(task_attributes[:id]).update_attributes(task_attributes)
      else
        tasks.create(task_attributes)
      end
      
      if destroy && !task.new_record?
        tasks.destroy(task.id)
      else
        self.tasks << task
      end
    end
  end
end
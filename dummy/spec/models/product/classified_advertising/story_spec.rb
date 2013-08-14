require 'spec_helper'

describe Product::ClassifiedAdvertising::Story do
  describe '#tasks_attributes=' do
    it 'creates, updates and destroys tasks' do
      project = FactoryGirl.create(:classified_advertising_project_with_story)
      subject = project.stories.first
      
      # create
      subject.attributes = {
        tasks_attributes: {
          '0' => {
            name: 'Task 1', text: 'Dummy', 
            vacancies_attributes: {
              '0' => {name: 'Vacancy CA 1', text: 'Dummy', _destroy: '0'}
            }
          }
        }
      }
      subject.setup_tasks; task = subject.tasks.first
      
      task.new_record?.should(be_false)
      task.vacancies.first.is_a?(Product::ClassifiedAdvertising::Vacancy)
  
      task_attributes = { id: task.id.clone, name: 'Task 1.1', text: 'Dummy 2' }
      
      # update
      subject.update_attributes tasks_attributes: { '0' => task_attributes }; task.reload
      
      subject.tasks.count.should == 1
      subject.tasks.first.vacancies.count.should == 1
      task_attributes.each {|attribute, value| task.send(attribute).should == value }
      
      # destroy
      subject.update_attributes tasks_attributes: { '0' => task_attributes.merge(_destroy: '1') }
      
      Task.count.should == 0
      Vacancy.count.should == 0
    end
  end
end

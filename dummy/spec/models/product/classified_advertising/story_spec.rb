require 'spec_helper'

describe Product::ClassifiedAdvertising::Story do
  describe 'assign vacancies through nested tasks' do
    it 'principally works' do
      project = FactoryGirl.create(:classified_advertising_project_with_story)
      subject = project.stories.first
      
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
      subject.save!
      
      subject.tasks.first.is_a?(Product::ClassifiedAdvertising::Task)
      subject.tasks.first.vacancies.first.is_a?(Product::ClassifiedAdvertising::Vacancy)
    end
  end
end

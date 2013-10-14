require 'spec_helper'

describe Product::ClassifiedAdvertisement::Task do
  describe 'validations' do
    describe '#at_least_one_vacancy' do
      before :each do
        subject = FactoryGirl.build(:classified_advertisement_task)
        @message = I18n.t('activerecord.errors.models.task.attributes.base.no_vacancies')
      end
      
      context 'task without vacancy' do
        it 'is invalid' do
          subject.valid?
          
          subject.errors[:base].should include(@message)
        end
      end
      
      context 'task with vacancy' do  
        it 'is valid' do
          subject.vacancies << FactoryGirl.build(:classified_advertisement_vacancy, task: subject)
          subject.valid?
          
          subject.errors[:base].should_not include(@message)
        end
      end
    end
  end
  
  describe '#vacancies_attributes=' do
    it 'creates, updates and destroys vacancies' do
      project = FactoryGirl.create(:classified_advertisement_project_with_story)
      subject = FactoryGirl.build(:classified_advertisement_task, story: project.stories.first)
      
      # create
      subject.attributes = { 
        vacancies_attributes: { 
          '0' => {name: 'Vacancy CA 1', text: 'Dummy', _destroy: '0'}
        }
      }
      subject.save
      
      subject.new_record?.should(be_false); vacancy = subject.vacancies.first
  
      vacancy_attributes = { id: vacancy.id, name: 'Vacancy 1.1', text: 'Vacancy 1.2' }
      
      # update
      subject.update_attributes vacancies_attributes: { '0' => vacancy_attributes }
      vacancy.reload
      
      subject.vacancies.count.should == 1
      vacancy_attributes.each {|attribute, value| vacancy.send(attribute).should == value }
      
      # destroy
      subject.update_attributes(vacancies_attributes: { '0' => vacancy_attributes.merge(_destroy: '1') })
      subject.errors[:base].should include(I18n.t('activerecord.errors.models.task.attributes.base.no_vacancies'))
      
      Vacancy.count.should == 0
    end
  end
  
  describe '#review' do
    it 'assigns resource to the task' do
      Factory.create(:classified_advertisement_story_with_one_vacancy, project: project)
      
      project = FactoryGirl.create(:project)
      raise "ok"
      project = FactoryGirl.create(:classified_advertisement_project_with_one_vacancy)
    end
  end
end

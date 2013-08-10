require 'spec_helper'

class Product::ClassifiedAdvertising::Story
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

class Product::ClassifiedAdvertising::Task
  def vacancies_attributes=(attributes = {})
    self.vacancies ||= []
    raise "ok2"
    attributes.each do |index, vacancy_attributes|
      destroy = vacancy_attributes.delete :_destroy
      vacancy_attributes[:task] = self
      
      vacancy = if vacancy_attributes[:id].present?
        vacancy_class.find(vacancy_attributes[:id]).update_attributes(vacancy_attributes)
      else
        raise "dummy"
        vacancy_class.new(vacancy_attributes)
      end
      
      if destroy && !vacancy.new_record?
        vacancy_class.destroy(vacancy.id)
      else
        self.vacancies << vacancy
        raise vacancies.first.name.inspect
        vacancies.select(&:valid?)
        raise "ok2:" + vacancies.first.errors.full_messages.inspect
      end
    end
  end
  
  def at_least_one_vacancy
    #raise vacancies.inspect
    unless vacancies.select(&:valid?).any?
      errors.add(:base, I18n.t('activerecord.errors.models.task.attributes.base.no_vacancies'))
    end
  end
end

class Product::ClassifiedAdvertising::Vacancy
  protected
  
  def set_defaults
    self.project ||= task.try(:story).try(:project)
    
    super
  end
end

class Vacancy < ActiveRecord::Base
  protected
  
  def set_defaults
    if project
      self.offeror_id = project.user_id
      self.author_id = project.user_id unless self.author_id.present?
      raise attributes.inspect
    end
  end
end

describe Product::ClassifiedAdvertising::Task do
  describe 'validations' do
    describe '#at_least_one_vacancy' do
      it 'principally works' do
        project = FactoryGirl.create(:classified_advertising_project_with_story)
        story = project.stories.first
        
        story.attributes = {
          tasks_attributes: { '0' => { name: 'Task 1', text: 'Dummy' } }
        }
        story.save; subject = story.tasks.first
        
        message = I18n.t('activerecord.errors.models.task.attributes.base.no_vacancies')
        subject.errors[:base].should include(message)
        
        story.attributes = {
          tasks_attributes: {
            '0' => {
              name: 'Task 1', text: 'Dummy', 
              vacancies_attributes: {
                '0' => {name: 'Vacancy CA 1', text: 'Dummy', _destroy: '0'}
              }
            }
          }
        }
        story.save; subject = story.tasks.first
        
        raise subject.errors.full_messages.inspect
        raise [subject.vacancies.length, subject.vacancies.first.attributes].inspect
        raise subject.vacancies.first.errors.full_messages.inspect
        subject.errors[:base].should_not include(message)
      end
    end
  end
end

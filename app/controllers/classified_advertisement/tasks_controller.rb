module ClassifiedAdvertisement
  class TasksController < ApplicationController
    def sign_up_form
      @task = Task.find(params[:id])
      @amount = @task.vacancy.candidatures.where(user_id: current_user.id).first.try(:amount)
      
      render layout: false
    end
    
    def sign_up
      task = Task.find(params[:id])
      params[:candidature] ||= {}
      @error = task.sign_up(current_user.id, params[:candidature][:amount])
      
      render layout: false
    end
    
    def sign_out
      task = Task.find(params[:id])
      @error = task.sign_out(current_user.id)
      
      render layout: false
    end
  end
end
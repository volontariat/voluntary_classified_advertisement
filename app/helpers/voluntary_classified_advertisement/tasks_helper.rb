module VoluntaryClassifiedAdvertisement
  module TasksHelper
    def tasks_with_candidatures(user)
      task_ids, vacancy_to_task_id = [], {}
      
      if user_signed_in?
        @tasks.each{|t| vacancy_to_task_id[t.vacancy_id] = t.id }
        
        Candidature.where(user_id: current_user.id, vacancy_id: @tasks.map(&:vacancy_id)).each do |candidature|
          task_ids << vacancy_to_task_id[candidature.vacancy_id]
        end
      end
      
      task_ids
    end
  end
end
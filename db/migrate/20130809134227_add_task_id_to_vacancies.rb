class AddTaskIdToVacancies < ActiveRecord::Migration
  def change
    add_column :vacancies, :task_id, :integer
  end
end

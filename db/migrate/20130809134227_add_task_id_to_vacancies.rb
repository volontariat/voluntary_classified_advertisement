class AddTaskIdToVacancies < ActiveRecord::Migration
  def change
    add_column :vacancies, :task_id, :string
  end
end
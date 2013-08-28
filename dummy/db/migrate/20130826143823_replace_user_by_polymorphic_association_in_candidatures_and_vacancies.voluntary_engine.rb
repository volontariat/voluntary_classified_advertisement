# This migration comes from voluntary_engine (originally 20130823190007)
class ReplaceUserByPolymorphicAssociationInCandidaturesAndVacancies < ActiveRecord::Migration
  def change
    remove_column :candidatures, :user_id
    add_column :candidatures, :resource_id, :integer
    add_column :candidatures, :resource_type, :string
    
    remove_column :vacancies, :user_id
    add_column :vacancies, :resource_id, :integer
    add_column :vacancies, :resource_type, :string
  end
end

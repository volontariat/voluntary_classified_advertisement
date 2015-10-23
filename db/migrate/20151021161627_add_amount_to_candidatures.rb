class AddAmountToCandidatures < ActiveRecord::Migration
  def change
    add_column :candidatures, :amount, :integer
  end
end

class AddClassifiedAdvertisementProduct < ActiveRecord::Migration
  def up
    product = Product.new(name: 'Classified Advertisement', text: 'Classified Advertisement')
    product.user_id = User.where(name: 'Master').first.id
    product.save!
  end
  
  def down
    Product.where(name: 'Classified Advertisement').first.destroy
  end
end
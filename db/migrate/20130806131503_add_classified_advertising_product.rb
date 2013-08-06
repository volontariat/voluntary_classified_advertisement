class AddClassifiedAdvertisingProduct < ActiveRecord::Migration
  def up
    product = Product.new(name: 'Classified Advertising', text: 'Classified Advertising')
    product.user_id = User.where(name: 'Master').first.id
    product.save!
  end
  
  def down
    Product.where(name: 'Classified Advertising').first.destroy
  end
end
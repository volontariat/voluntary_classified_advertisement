class AddClassifiedAdvertisementProduct < ActiveRecord::Migration
  def up
    product = Product.create(name: 'Classified Advertisement', text: 'Dummy')
  end
  
  def down
    Product.where(name: 'Classified Advertisement').first.destroy
  end
end
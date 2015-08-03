class AddClassifiedAdvertisementProduct < ActiveRecord::Migration
  def up
    product = Product::ClassifiedAdvertisement.create(name: 'Classified Advertisement', text: 'Dummy')
  end
  
  def down
    Product::ClassifiedAdvertisement.first.destroy
  end
end
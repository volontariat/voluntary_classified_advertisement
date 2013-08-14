# This migration comes from voluntary_classified_advertising_engine (originally 20130806131503)
class AddClassifiedAdvertisingProduct < ActiveRecord::Migration
  def up
    product = Product.create(name: 'Classified Advertising', text: 'Classified Advertising')
  end
  
  def down
    Product.where(name: 'Classified Advertising').first.destroy
  end
end
# This migration comes from voluntary_classified_advertisement_engine (originally 20130806131503)
class AddClassifiedAdvertisementProduct < ActiveRecord::Migration
  def up
    product = Product.create(name: 'Classified Advertisement', text: 'Classified Advertisement')
  end
  
  def down
    Product.where(name: 'Classified Advertisement').first.destroy
  end
end
# This migration comes from voluntary_classified_advertisement_engine (originally 20130806131503)
class AddClassifiedAdvertisementProduct < ActiveRecord::Migration
  def up
    product = Product::ClassifiedAdvertisement.create(name: 'Classified Advertisement', text: 'Dummy')
  end
  
  def down
    Product::ClassifiedAdvertisement.first.destroy
  end
end
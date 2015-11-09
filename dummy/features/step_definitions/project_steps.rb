Given /^a classified advertisement project$/ do
  product = Product::ClassifiedAdvertisement.create(name: 'Classified Advertisement')
  area = FactoryGirl.create(:area, name: 'Dummy')
  @project = FactoryGirl.create(:project, product_id: product.id, name: 'Dummy', text: 'Dummy', area_ids: [area.id], user_id: @me.id)
end
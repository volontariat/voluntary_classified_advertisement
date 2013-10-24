class Product::ClassifiedAdvertisement::Candidature < ::Candidature
  accepts_nested_attributes_for :resource
  
  attr_accessible :resource_attributes
  
  def resource_attributes=(attributes)
    self.resource = if attributes[:id].present?
      Asset.find(attributes[:id])
    else
      Asset.new
    end
    
    self.resource.attributes = attributes
    
    self.resource.save
  
    self.resource_type = 'Asset'
    self.resource_id = self.resource.id
  end
end
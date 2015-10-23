class Product::ClassifiedAdvertisement::Candidature < ::Candidature
  protected
  
  def validate_resource_id?
    resource_type == 'User' || vacancy.resource_type == 'User'
  end
end
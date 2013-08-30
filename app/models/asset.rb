class Asset < ActiveRecord::Base
  include ::Applicat::Mvc::Model::Resource::Base
  
  attr_accessible :text, :name
  has_many :candidatures, as: :resource
  
  validates :name, presence: true
  validates :text, presence: true
end

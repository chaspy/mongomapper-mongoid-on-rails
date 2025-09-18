class MdSharedItem
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Explicitly set collection name
  store_in collection: 'shared_items'
  
  field :title, type: String
  field :description, type: String
  field :price, type: Float
  field :odm_source, type: String, default: 'mongoid'
  
  validates :title, presence: true
  validates :price, numericality: { greater_than: 0 }, allow_nil: true
end
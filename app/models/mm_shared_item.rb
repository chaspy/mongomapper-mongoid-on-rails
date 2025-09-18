class MmSharedItem
  include MongoMapper::Document
  
  # Explicitly set collection name
  set_collection_name 'shared_items'
  
  key :title, String, required: true
  key :description, String
  key :price, Float
  key :created_at, Time, default: -> { Time.now }
  key :odm_source, String, default: 'mongo_mapper'
  
  validates :title, presence: true
  validates :price, numericality: { greater_than: 0 }, allow_nil: true
end
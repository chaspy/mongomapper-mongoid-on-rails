class MmUser
  include MongoMapper::Document
  
  key :name, String, required: true
  key :email, String, required: true
  key :age, Integer
  key :created_at, Time, default: -> { Time.now }
  
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :age, numericality: { greater_than: 0 }, allow_nil: true
end
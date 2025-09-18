if Rails.env.development? || Rails.env.test?
  MongoMapper.connection = Mongo::Client.new(['127.0.0.1:27017'])
  MongoMapper.database = Rails.env.development? ? "mongomapper_mongoid_development_mm" : "mongomapper_mongoid_test_mm"
elsif Rails.env.production?
  MongoMapper.connection = Mongo::Client.new(['127.0.0.1:27017'])
  MongoMapper.database = "mongomapper_mongoid_production_mm"
end
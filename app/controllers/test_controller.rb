class TestController < ApplicationController
  def index
    render json: { message: "MongoMapper and Mongoid coexistence test API" }
  end
  
  def create_mm_user
    mm_user = MmUser.new(
      name: params[:name] || "MongoMapper User",
      email: params[:email] || "mm@example.com",
      age: params[:age] || 25
    )
    
    if mm_user.save
      render json: { 
        success: true, 
        user: {
          id: mm_user.id.to_s,
          name: mm_user.name,
          email: mm_user.email,
          age: mm_user.age,
          created_at: mm_user.created_at,
          type: "MongoMapper"
        }
      }
    else
      render json: { success: false, errors: mm_user.errors.full_messages }
    end
  end
  
  def create_md_user
    md_user = MdUser.new(
      name: params[:name] || "Mongoid User",
      email: params[:email] || "md@example.com", 
      age: params[:age] || 30
    )
    
    if md_user.save
      render json: { 
        success: true, 
        user: {
          id: md_user.id.to_s,
          name: md_user.name,
          email: md_user.email,
          age: md_user.age,
          created_at: md_user.created_at,
          updated_at: md_user.updated_at,
          type: "Mongoid"
        }
      }
    else
      render json: { success: false, errors: md_user.errors.full_messages }
    end
  end
  
  def list_users
    mm_users = MmUser.all.map do |user|
      {
        id: user.id.to_s,
        name: user.name,
        email: user.email,
        age: user.age,
        created_at: user.created_at,
        type: "MongoMapper"
      }
    end
    
    md_users = MdUser.all.map do |user|
      {
        id: user.id.to_s,
        name: user.name,
        email: user.email,
        age: user.age,
        created_at: user.created_at,
        updated_at: user.updated_at,
        type: "Mongoid"
      }
    end
    
    render json: {
      mm_users: mm_users,
      md_users: md_users,
      total: mm_users.length + md_users.length
    }
  end
  
  # Shared collection tests
  def create_mm_shared_item
    mm_item = MmSharedItem.new(
      title: params[:title] || "MongoMapper Item",
      description: params[:description] || "Created via MongoMapper",
      price: params[:price]&.to_f
    )
    
    if mm_item.save
      render json: { 
        success: true, 
        item: {
          id: mm_item.id.to_s,
          title: mm_item.title,
          description: mm_item.description,
          price: mm_item.price,
          created_at: mm_item.created_at,
          odm_source: mm_item.odm_source,
          type: "MongoMapper"
        }
      }
    else
      render json: { success: false, errors: mm_item.errors.full_messages }
    end
  end
  
  def create_md_shared_item
    md_item = MdSharedItem.new(
      title: params[:title] || "Mongoid Item",
      description: params[:description] || "Created via Mongoid",
      price: params[:price]&.to_f
    )
    
    if md_item.save
      render json: { 
        success: true, 
        item: {
          id: md_item.id.to_s,
          title: md_item.title,
          description: md_item.description,
          price: md_item.price,
          created_at: md_item.created_at,
          updated_at: md_item.updated_at,
          odm_source: md_item.odm_source,
          type: "Mongoid"
        }
      }
    else
      render json: { success: false, errors: md_item.errors.full_messages }
    end
  end
  
  def list_shared_items
    mm_items = MmSharedItem.all.map do |item|
      {
        id: item.id.to_s,
        title: item.title,
        description: item.description,
        price: item.price,
        created_at: item.created_at,
        odm_source: item.odm_source,
        accessed_via: "MongoMapper"
      }
    end
    
    md_items = MdSharedItem.all.map do |item|
      {
        id: item.id.to_s,
        title: item.title,
        description: item.description,
        price: item.price,
        created_at: item.created_at,
        updated_at: item.updated_at,
        odm_source: item.odm_source,
        accessed_via: "Mongoid"
      }
    end
    
    render json: {
      mm_view: mm_items,
      md_view: md_items,
      total_from_mm: mm_items.length,
      total_from_md: md_items.length,
      message: "Both views should show the same items from shared collection"
    }
  end
end
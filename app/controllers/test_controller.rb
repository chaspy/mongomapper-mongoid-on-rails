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
end
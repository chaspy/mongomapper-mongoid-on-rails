# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Rails 8.0 API application that validates the coexistence of MongoMapper and Mongoid ODMs (Object Document Mappers) for MongoDB. The primary purpose is to prove that gradual migration from MongoMapper to Mongoid is possible within the same Rails application.

## Architecture

### Dual ODM Configuration
Both MongoMapper and Mongoid are configured to work with the same MongoDB database:
- **MongoMapper config**: `config/initializers/mongo_mapper.rb` - programmatic connection setup
- **Mongoid config**: `config/mongoid.yml` + `config/initializers/mongoid.rb` - YAML-based configuration
- **Database**: Both ODMs use `mongomapper_mongoid_development` (same database)

### Model Patterns
The application demonstrates two coexistence patterns:

#### 1. Separate Collections (Independent)
- `MmUser` (MongoMapper) → `mm_users` collection
- `MdUser` (Mongoid) → `md_users` collection  
- Used for initial testing of ODM independence

#### 2. Shared Collections (Migration Pattern)
- `MmSharedItem` (MongoMapper) → `shared_items` collection
- `MdSharedItem` (Mongoid) → `shared_items` collection
- Both models access the same collection using:
  - MongoMapper: `set_collection_name 'shared_items'`
  - Mongoid: `store_in collection: 'shared_items'`
- Critical for gradual migration scenarios

### API Structure
All endpoints are in `TestController` and follow this pattern:
- **Separate collection tests**: `/mm_users`, `/md_users`, `/users`
- **Shared collection tests**: `/mm_shared_items`, `/md_shared_items`, `/shared_items`
- **Cross-ODM validation**: The `/shared_items` endpoint queries both ODMs to verify they see the same data

## Common Development Commands

### Environment Setup
```bash
# Start MongoDB container (required)
docker run --name mongodb-test -p 27017:27017 -d mongo:latest

# Install dependencies
bundle install

# Start Rails server
rails server
```

### Development Tools
```bash
# Security analysis
bin/brakeman

# Code linting
bin/rubocop

# Rails console with both ODMs loaded
rails console
```

### Testing ODM Coexistence
```bash
# Test separate collections
curl -X POST http://localhost:3000/mm_users -H "Content-Type: application/json" -d '{"name":"MM User","email":"mm@test.com","age":25}'
curl -X POST http://localhost:3000/md_users -H "Content-Type: application/json" -d '{"name":"MD User","email":"md@test.com","age":30}'

# Test shared collection (migration scenario)
curl -X POST http://localhost:3000/mm_shared_items -H "Content-Type: application/json" -d '{"title":"Legacy Item","price":99.99}'
curl -X POST http://localhost:3000/md_shared_items -H "Content-Type: application/json" -d '{"title":"New Item","price":149.99}'

# Verify cross-ODM data access
curl http://localhost:3000/shared_items | jq
```

## Key Implementation Details

### MongoDB Connection Strategy
- **Same database**: Both ODMs connect to the same MongoDB database to enable data sharing
- **Separate connections**: Each ODM maintains its own connection pool to avoid conflicts
- **Collection targeting**: Models explicitly specify collection names to control data placement

### Migration Validation Points
- **Data persistence**: Items created via MongoMapper are readable by Mongoid models
- **Schema flexibility**: ODM-specific fields (like `updated_at`) gracefully handle null values
- **Concurrent operations**: Both ODMs can operate on the same collection simultaneously

### Field Mapping Considerations
- `odm_source` field tracks which ODM created each document
- MongoMapper uses `created_at` manually, Mongoid uses `Mongoid::Timestamps`
- Price validation exists in both models to demonstrate shared business rules

## Troubleshooting

### MongoDB Connection Issues
- Ensure MongoDB container is running on port 27017
- Check that both ODMs are configured with the same database name
- Verify no authentication is required for local development

### ODM Conflicts
- Models must use different class names even when sharing collections
- Avoid defining conflicting indexes in both ODMs for the same collection
- Be aware that each ODM handles validations independently
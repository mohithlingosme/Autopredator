# Data Model

This document describes the core data entities and relationships in the Autopredator platform.

## Core Entities

### User
- `id`: UUID
- `email`: String (unique)
- `name`: String
- `role`: Enum (user, admin, partner)
- `created_at`: Timestamp
- `updated_at`: Timestamp

### Vehicle
- `id`: UUID
- `manufacturer_id`: Foreign Key
- `model`: String
- `category`: Enum (bike, scooter, ev)
- `specs`: JSON (engine, dimensions, etc.)
- `created_at`: Timestamp

### Manufacturer
- `id`: UUID
- `name`: String
- `country`: String
- `website`: String

### Comparison
- `id`: UUID
- `user_id`: Foreign Key
- `vehicle_ids`: Array of UUIDs
- `notes`: Text
- `created_at`: Timestamp

## Relationships

- User has many Comparisons
- Manufacturer has many Vehicles
- Vehicle belongs to Manufacturer
- Comparison has many Vehicles (many-to-many)

## Data Validation Rules

- Email must be valid format
- Vehicle specs must include required fields based on category
- Comparisons limited to maximum 8 vehicles
- All timestamps use UTC

## Indexing Strategy

- Primary keys on all tables
- Index on User.email
- Index on Vehicle.manufacturer_id
- Index on Vehicle.category
- Composite index on Comparison.user_id + created_at

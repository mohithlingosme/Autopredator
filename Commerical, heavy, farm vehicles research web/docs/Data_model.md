# Data Model - AutoPredator FleetCommand

## Overview

FleetCommand uses a relational database design with PostgreSQL as the primary data store. The data model is designed for multi-tenant operations with strict data isolation between organizations.

## Core Principles

1. **Multi-Tenant Architecture**: All tables include `org_id` for data isolation
2. **Soft Deletes**: `deleted_at` timestamp for logical deletion
3. **Audit Trail**: All changes tracked in audit_logs table
4. **Data Integrity**: Foreign key constraints and validation rules
5. **Performance**: Proper indexing and query optimization

## Database Schema

### Organizations (orgs)

Root entity for multi-tenant isolation.

```sql
CREATE TABLE orgs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'inactive')),
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_orgs_status ON orgs(status);
CREATE INDEX idx_orgs_created_at ON orgs(created_at);
```

### Users (users)

User accounts with authentication data.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    email_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### User-Organization Memberships (user_org_memberships)

Many-to-many relationship between users and organizations with roles.

```sql
CREATE TABLE user_org_memberships (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Admin', 'Manager', 'Operator', 'Driver', 'Accountant', 'Viewer')),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    invited_by UUID REFERENCES users(id),
    invited_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    joined_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, org_id)
);

-- Indexes
CREATE INDEX idx_user_org_memberships_org_id ON user_org_memberships(org_id);
CREATE INDEX idx_user_org_memberships_user_id ON user_org_memberships(user_id);
CREATE INDEX idx_user_org_memberships_role ON user_org_memberships(role);
```

### Audit Logs (audit_logs)

Comprehensive audit trail for compliance and debugging.

```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    actor_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    old_values JSONB,
    new_values JSONB,
    metadata JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_audit_logs_org_id ON audit_logs(org_id);
CREATE INDEX idx_audit_logs_actor_user_id ON audit_logs(actor_user_id);
CREATE INDEX idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX idx_audit_logs_entity_id ON audit_logs(entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
```

## Fleet Management Entities

### Vehicles (vehicles)

Core fleet asset information.

```sql
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    vehicle_number VARCHAR(50) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL CHECK (vehicle_type IN ('truck', 'bus', 'van', 'car', 'motorcycle')),
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER CHECK (year >= 1900 AND year <= EXTRACT(YEAR FROM NOW()) + 1),
    registration_number VARCHAR(50) UNIQUE,
    chassis_number VARCHAR(100) UNIQUE,
    engine_number VARCHAR(100),
    fuel_type VARCHAR(50) CHECK (fuel_type IN ('diesel', 'petrol', 'electric', 'cng', 'lpg')),
    capacity_kg DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'inactive', 'sold')),
    purchase_date DATE,
    purchase_price DECIMAL(15,2),
    current_value DECIMAL(15,2),
    insurance_expiry DATE,
    fitness_expiry DATE,
    permit_expiry DATE,
    assigned_driver_id UUID REFERENCES users(id),
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE UNIQUE INDEX idx_vehicles_org_registration ON vehicles(org_id, registration_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_vehicles_org_id ON vehicles(org_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_vehicle_type ON vehicles(vehicle_type);
CREATE INDEX idx_vehicles_assigned_driver_id ON vehicles(assigned_driver_id);
CREATE INDEX idx_vehicles_created_at ON vehicles(created_at);
```

### Maintenance Records (maintenance_records)

Service and maintenance history.

```sql
CREATE TABLE maintenance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    maintenance_type VARCHAR(50) NOT NULL CHECK (maintenance_type IN ('service', 'repair', 'inspection', 'emergency')),
    description TEXT NOT NULL,
    scheduled_date DATE,
    completed_date DATE,
    odometer_reading INTEGER,
    cost DECIMAL(10,2),
    vendor_name VARCHAR(255),
    vendor_contact VARCHAR(255),
    parts_used JSONB DEFAULT '[]',
    status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'critical')),
    notes TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    assigned_to UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_maintenance_records_org_id ON maintenance_records(org_id);
CREATE INDEX idx_maintenance_records_vehicle_id ON maintenance_records(vehicle_id);
CREATE INDEX idx_maintenance_records_status ON maintenance_records(status);
CREATE INDEX idx_maintenance_records_scheduled_date ON maintenance_records(scheduled_date);
CREATE INDEX idx_maintenance_records_completed_date ON maintenance_records(completed_date);
```

### Fuel Logs (fuel_logs)

Fuel consumption tracking.

```sql
CREATE TABLE fuel_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    fuel_date DATE NOT NULL,
    odometer_reading INTEGER NOT NULL,
    fuel_type VARCHAR(50) NOT NULL,
    quantity_liters DECIMAL(8,2) NOT NULL,
    cost_per_liter DECIMAL(6,2),
    total_cost DECIMAL(10,2) NOT NULL,
    fuel_station VARCHAR(255),
    driver_id UUID REFERENCES users(id),
    notes TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_fuel_logs_org_id ON fuel_logs(org_id);
CREATE INDEX idx_fuel_logs_vehicle_id ON fuel_logs(vehicle_id);
CREATE INDEX idx_fuel_logs_fuel_date ON fuel_logs(fuel_date);
CREATE INDEX idx_fuel_logs_driver_id ON fuel_logs(driver_id);
```

### Trips (trips)

Trip and route management.

```sql
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES users(id),
    trip_number VARCHAR(50) UNIQUE NOT NULL,
    start_location VARCHAR(255) NOT NULL,
    end_location VARCHAR(255) NOT NULL,
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE,
    planned_distance_km DECIMAL(8,2),
    actual_distance_km DECIMAL(8,2),
    cargo_description TEXT,
    cargo_weight_kg DECIMAL(10,2),
    customer_name VARCHAR(255),
    customer_contact VARCHAR(255),
    revenue DECIMAL(12,2),
    expenses DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE UNIQUE INDEX idx_trips_org_trip_number ON trips(org_id, trip_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_trips_org_id ON trips(org_id);
CREATE INDEX idx_trips_vehicle_id ON trips(vehicle_id);
CREATE INDEX idx_trips_driver_id ON trips(driver_id);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_start_datetime ON trips(start_datetime);
```

## Data Relationships

```
orgs (1) ──── (M) user_org_memberships (M) ──── (1) users
  │
  ├── (1) ──── (M) audit_logs
  │
  ├── (1) ──── (M) vehicles
  │       │
  │       ├── (1) ──── (M) maintenance_records
  │       ├── (1) ──── (M) fuel_logs
  │       └── (1) ──── (M) trips
  │
  └── (1) ──── (M) [future entities: drivers, customers, etc.]
```

## Data Validation Rules

### Business Rules

1. **Organization Isolation**: All queries must filter by `org_id`
2. **Soft Delete**: Never hard delete records, use `deleted_at`
3. **Audit Trail**: Log all create/update/delete operations
4. **Data Integrity**: Maintain referential integrity with FKs
5. **Status Transitions**: Validate state changes (e.g., vehicle status)

### Validation Constraints

- Email format validation
- Date range validation (future dates where appropriate)
- Numeric range validation (positive values for costs, weights)
- String length limits
- Enum value restrictions

## Indexing Strategy

### Primary Indexes
- Primary keys on all tables (UUID)
- Unique constraints on business keys

### Foreign Key Indexes
- All foreign key columns indexed
- Composite indexes for common query patterns

### Performance Indexes
- Status columns (frequent filtering)
- Date columns (range queries)
- Text search indexes (GIN for JSONB)
- Partial indexes for active records

## Migration Strategy

### Alembic Setup

```python
# alembic/env.py
from app.db.base import Base
from app.models import *  # Import all models

# Migration commands
alembic revision --autogenerate -m "Add vehicles table"
alembic upgrade head
```

### Migration Best Practices

1. **Backward Compatible**: Design migrations that can be rolled back
2. **Data Migration**: Handle data transformation during schema changes
3. **Testing**: Test migrations on staging before production
4. **Documentation**: Document complex migrations

## Backup and Recovery

### Backup Strategy

- **Daily Full Backups**: Complete database dumps
- **Transaction Logs**: Point-in-time recovery capability
- **Retention**: 30 days for daily backups, 7 days for logs

### Recovery Procedures

1. **Point-in-Time Recovery**: Restore to specific timestamp
2. **Table-Level Recovery**: Restore individual tables if needed
3. **Failover**: Automated failover for high availability

## Performance Considerations

### Query Optimization

- Use `EXPLAIN ANALYZE` for query performance
- Avoid N+1 queries with proper joins
- Use pagination for large result sets
- Implement proper indexing

### Connection Pooling

- Use SQLAlchemy connection pooling
- Configure appropriate pool sizes
- Monitor connection usage

### Caching Strategy

- Cache frequently accessed data in Redis
- Use database query result caching
- Implement cache invalidation strategies

This data model provides a solid foundation for fleet management operations with proper multi-tenant isolation, audit capabilities, and performance optimizations.

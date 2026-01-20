# Data Model

This document describes the initial database schema for AutoPredator FleetCommand.

## Entity Relationship Diagram (Text)

```
┌─────────────────┐       ┌─────────────────┐
│   organizations │1─────*│      users      │
└─────────────────┘       └─────────────────┘
         │                           │
         │1                          │*
         │                           │
         ▼                           ▼
┌─────────────────┐       ┌─────────────────┐
│    locations    │1─────*│    vehicles     │
└─────────────────┘       └─────────────────┘
         ▲                           │
         │                           │*
         │                           │
         │1                          │
         │                           ▼
         │                   ┌─────────────────┐
         │                   │     drivers     │
         │                   └─────────────────┘
         │                           │
         │                           │*
         │                           │
         │1                          │
         ▼                           ▼
┌─────────────────┐       ┌─────────────────┐
│     depots      │       │      trips      │
└─────────────────┘       └─────────────────┘
                                   │
                                   │*
                                   │
                                   ▼
                           ┌─────────────────┐
                           │   fuel_logs     │
                           └─────────────────┘

Additional Entities:
- maintenance_jobs
- documents
- alerts
- audit_logs
```

## Core Tables

### organizations
Multi-tenant root entity.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Organization ID |
| name | VARCHAR(100) | NOT NULL | Company name |
| domain | VARCHAR(100) | UNIQUE | Company domain |
| address | TEXT | | Company address |
| phone | VARCHAR(20) | | Contact phone |
| email | VARCHAR(100) | | Contact email |
| gst_number | VARCHAR(15) | | GST number (India) |
| subscription_plan | VARCHAR(50) | DEFAULT 'basic' | Subscription tier |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

### users
Users within organizations.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | User ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| email | VARCHAR(100) | UNIQUE | User email |
| password_hash | VARCHAR(255) | NOT NULL | Hashed password |
| first_name | VARCHAR(50) | NOT NULL | First name |
| last_name | VARCHAR(50) | NOT NULL | Last name |
| role | user_role_enum | NOT NULL | User role |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| last_login | TIMESTAMP | | Last login time |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

### locations
Geographic locations/depots.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Location ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| name | VARCHAR(100) | NOT NULL | Location name |
| address | TEXT | NOT NULL | Full address |
| latitude | DECIMAL(10,8) | | GPS latitude |
| longitude | DECIMAL(11,8) | | GPS longitude |
| type | location_type_enum | DEFAULT 'depot' | Location type |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |

### vehicles
Fleet vehicles.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Vehicle ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| registration_number | VARCHAR(20) | UNIQUE | Vehicle number |
| chassis_number | VARCHAR(50) | | Chassis number |
| engine_number | VARCHAR(50) | | Engine number |
| vehicle_type | vehicle_type_enum | NOT NULL | Truck, tipper, etc. |
| make | VARCHAR(50) | | Manufacturer |
| model | VARCHAR(50) | | Model |
| year | INTEGER | | Manufacture year |
| fuel_type | fuel_type_enum | DEFAULT 'diesel' | Fuel type |
| capacity | DECIMAL(10,2) | | Load capacity (tons) |
| location_id | INTEGER | FK locations | Current location |
| insurance_expiry | DATE | | Insurance expiry |
| permit_expiry | DATE | | Permit expiry |
| fitness_expiry | DATE | | Fitness certificate expiry |
| puc_expiry | DATE | | PUC expiry |
| fastag_id | VARCHAR(20) | | FASTag ID |
| odometer_reading | DECIMAL(10,2) | DEFAULT 0 | Current odometer |
| status | vehicle_status_enum | DEFAULT 'active' | Vehicle status |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

### drivers
Vehicle drivers.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Driver ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| first_name | VARCHAR(50) | NOT NULL | First name |
| last_name | VARCHAR(50) | NOT NULL | Last name |
| license_number | VARCHAR(20) | UNIQUE | Driving license |
| license_expiry | DATE | NOT NULL | License expiry |
| phone | VARCHAR(15) | | Contact phone |
| address | TEXT | | Address |
| date_of_birth | DATE | | Date of birth |
| emergency_contact | VARCHAR(15) | | Emergency phone |
| status | driver_status_enum | DEFAULT 'active' | Driver status |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

### trips
Vehicle trips/journeys.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Trip ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| vehicle_id | INTEGER | FK vehicles | Assigned vehicle |
| driver_id | INTEGER | FK drivers | Assigned driver |
| trip_number | VARCHAR(20) | UNIQUE | Trip reference |
| start_location_id | INTEGER | FK locations | Starting point |
| end_location_id | INTEGER | FK locations | Destination |
| start_time | TIMESTAMP | | Trip start time |
| end_time | TIMESTAMP | | Trip end time |
| start_odometer | DECIMAL(10,2) | | Odometer at start |
| end_odometer | DECIMAL(10,2) | | Odometer at end |
| distance | DECIMAL(10,2) | | Distance traveled |
| cargo_type | VARCHAR(50) | | Type of cargo |
| cargo_weight | DECIMAL(10,2) | | Cargo weight |
| status | trip_status_enum | DEFAULT 'planned' | Trip status |
| notes | TEXT | | Additional notes |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

### fuel_logs
Fuel consumption records.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Fuel log ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| vehicle_id | INTEGER | FK vehicles | NOT NULL | Vehicle |
| trip_id | INTEGER | FK trips | | Associated trip |
| odometer_reading | DECIMAL(10,2) | NOT NULL | Odometer reading |
| fuel_quantity | DECIMAL(10,2) | NOT NULL | Liters filled |
| fuel_price | DECIMAL(10,2) | NOT NULL | Price per liter |
| total_cost | DECIMAL(10,2) | NOT NULL | Total cost |
| fuel_station | VARCHAR(100) | | Fuel station name |
| filled_at | TIMESTAMP | DEFAULT NOW() | Fill timestamp |
| filled_by | INTEGER | FK users | User who logged |
| notes | TEXT | | Additional notes |

### maintenance_jobs
Vehicle maintenance records.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Maintenance ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| vehicle_id | INTEGER | FK vehicles | NOT NULL | Vehicle |
| maintenance_type | maintenance_type_enum | NOT NULL | Service type |
| description | TEXT | NOT NULL | Work description |
| cost | DECIMAL(10,2) | | Maintenance cost |
| odometer_at_service | DECIMAL(10,2) | | Odometer reading |
| next_service_due | DATE | | Next service date |
| next_service_odometer | DECIMAL(10,2) | | Next service km |
| performed_by | VARCHAR(100) | | Service provider |
| performed_at | TIMESTAMP | DEFAULT NOW() | Service timestamp |
| performed_by_user | INTEGER | FK users | User who logged |
| status | maintenance_status_enum | DEFAULT 'completed' | Status |

### documents
Uploaded documents.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Document ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| vehicle_id | INTEGER | FK vehicles | | Associated vehicle |
| document_type | document_type_enum | NOT NULL | Document type |
| file_name | VARCHAR(255) | NOT NULL | Original filename |
| file_path | VARCHAR(500) | NOT NULL | Storage path |
| file_size | INTEGER | NOT NULL | File size in bytes |
| mime_type | VARCHAR(100) | NOT NULL | MIME type |
| expiry_date | DATE | | Document expiry |
| uploaded_by | INTEGER | FK users | Uploader |
| uploaded_at | TIMESTAMP | DEFAULT NOW() | Upload timestamp |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |

### alerts
System-generated alerts.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Alert ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| alert_type | alert_type_enum | NOT NULL | Alert category |
| title | VARCHAR(200) | NOT NULL | Alert title |
| message | TEXT | NOT NULL | Alert description |
| severity | alert_severity_enum | DEFAULT 'medium' | Alert priority |
| related_entity_type | VARCHAR(50) | | Related entity |
| related_entity_id | INTEGER | | Related entity ID |
| is_read | BOOLEAN | DEFAULT FALSE | Read status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |

### audit_logs
Audit trail for all changes.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Audit ID |
| organization_id | INTEGER | FK organizations | Tenant ID |
| user_id | INTEGER | FK users | User who performed action |
| action | VARCHAR(50) | NOT NULL | Action performed |
| table_name | VARCHAR(50) | NOT NULL | Affected table |
| record_id | INTEGER | NOT NULL | Affected record |
| old_values | JSONB | | Previous values |
| new_values | JSONB | | New values |
| ip_address | INET | | Client IP |
| user_agent | TEXT | | User agent |
| created_at | TIMESTAMP | DEFAULT NOW() | Action timestamp |

## Enums

### user_role_enum
- admin
- manager
- operator
- driver
- accountant
- viewer

### vehicle_type_enum
- truck
- tipper
- excavator
- tractor
- bus
- car
- other

### fuel_type_enum
- diesel
- petrol
- cng
- electric

### vehicle_status_enum
- active
- maintenance
- inactive
- sold

### driver_status_enum
- active
- suspended
- terminated

### trip_status_enum
- planned
- started
- completed
- cancelled

### maintenance_type_enum
- preventive
- corrective
- breakdown
- inspection

### maintenance_status_enum
- scheduled
- in_progress
- completed
- cancelled

### document_type_enum
- rc (Registration Certificate)
- insurance
- permit
- fitness
- puc (Pollution Under Control)
- other

### alert_type_enum
- expiry_warning
- expiry_critical
- maintenance_due
- fuel_anomaly
- system_alert

### alert_severity_enum
- low
- medium
- high
- critical

### location_type_enum
- depot
- branch
- warehouse
- other

## Indexes

Critical indexes for performance:
- organizations: domain
- users: organization_id, email, role
- vehicles: organization_id, registration_number, status
- drivers: organization_id, license_number, status
- trips: organization_id, vehicle_id, driver_id, status, start_time
- fuel_logs: organization_id, vehicle_id, filled_at
- maintenance_jobs: organization_id, vehicle_id, performed_at
- documents: organization_id, vehicle_id, document_type, expiry_date
- alerts: organization_id, is_read, created_at
- audit_logs: organization_id, user_id, created_at, table_name

This schema provides a solid foundation for fleet management with proper multi-tenant isolation and comprehensive tracking capabilities.

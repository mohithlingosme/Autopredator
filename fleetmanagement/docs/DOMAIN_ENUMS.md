# Domain Enums and Constants

## Vehicle Types
- TRUCK
- BUS
- CAR
- MOTORCYCLE
- TRACTOR
- CONSTRUCTION_EQUIPMENT
- OTHER

## Fuel Types
- DIESEL
- PETROL
- CNG
- ELECTRIC
- HYBRID

## Trip Status
- PLANNED
- IN_PROGRESS
- COMPLETED
- CANCELLED
- DELAYED

## Document Types (Compliance)
- INSURANCE
- PERMIT
- PUC_CERTIFICATE
- FITNESS_CERTIFICATE
- TAX_RECEIPT
- DRIVER_LICENSE
- VEHICLE_REGISTRATION
- MAINTENANCE_RECORD

## User Roles
- ADMIN
- MANAGER
- OPERATOR
- DRIVER
- ACCOUNTANT
- VIEWER

## Maintenance Types
- SCHEDULED_SERVICE
- REPAIR
- EMERGENCY_REPAIR
- INSPECTION
- TYRE_CHANGE
- BATTERY_REPLACEMENT

## Alert Types
- COMPLIANCE_EXPIRY
- MAINTENANCE_DUE
- FUEL_ANOMALY
- TRIP_DEVIATION
- DOCUMENT_MISSING

## Currency
- INR (only supported currency)

## Compliance Reminder Types
- INSURANCE_EXPIRY (30 days)
- PERMIT_EXPIRY (15 days)
- PUC_EXPIRY (7 days)
- FITNESS_EXPIRY (30 days)
- DRIVER_LICENSE_EXPIRY (60 days)

## Notes
- All enums must remain stable once deployed to production
- Changes require migration planning for existing data
- Enums used in reporting and analytics should be versioned
- New enum values can be added but existing values cannot be removed or renamed
